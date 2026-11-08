package com.https1121.overdrive.companion

import android.graphics.SurfaceTexture
import android.media.MediaCodec
import android.media.MediaFormat
import android.os.Handler
import android.os.HandlerThread
import android.view.Surface
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okio.ByteString
import java.nio.ByteBuffer
import java.util.concurrent.ArrayBlockingQueue
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.min

/** Annex-B H.264 over `/ws?token=` — mirrors upstream bare-NAL WebSocket messages. */
class H264StreamPlugin(
    messenger: io.flutter.plugin.common.BinaryMessenger,
    private val textures: TextureRegistry,
) {
    private val methodChannel = MethodChannel(messenger, "overdrive/h264")
    private val eventChannel = EventChannel(messenger, "overdrive/h264_events")
    private var eventSink: EventChannel.EventSink? = null
    private var session: StreamSession? = null

    init {
        methodChannel.setMethodCallHandler(::onMethodCall)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    private val mainHandler = Handler(android.os.Looper.getMainLooper())

    private fun emit(event: Map<String, Any?>) {
        mainHandler.post { eventSink?.success(event) }
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                val wsUrl = call.argument<String>("wsUrl")
                if (wsUrl.isNullOrBlank()) {
                    result.error("arg", "wsUrl required", null)
                    return
                }
                session?.stop()
                val entry = textures.createSurfaceTexture()
                session = StreamSession(
                    wsUrl = wsUrl,
                    surfaceEntry = entry,
                    emit = ::emit,
                )
                session?.start()
                result.success(entry.id())
            }
            "stop", "dispose" -> {
                session?.stop()
                session = null
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        fun register(engine: FlutterEngine) {
            H264StreamPlugin(engine.dartExecutor.binaryMessenger, engine.renderer)
        }
    }
}

private class StreamSession(
    private val wsUrl: String,
    private val surfaceEntry: TextureRegistry.SurfaceTextureEntry,
    private val emit: (Map<String, Any?>) -> Unit,
) {
    private val client = OkHttpClient.Builder()
        .pingInterval(15, TimeUnit.SECONDS)
        .build()

    private val codecThread = HandlerThread("h264-decode").also { it.start() }
    private val codecHandler = Handler(codecThread.looper)

    private var surface: Surface? = null
    private var codec: MediaCodec? = null
    private var configured = false
    private var stopping = AtomicBoolean(false)

    private val queue = ArrayBlockingQueue<Frame>(60)
    private var skipping = false

    private var webSocket: WebSocket? = null
    private var reconnectAttempt = 0

    data class Frame(val bytes: ByteArray, val isKey: Boolean, val isConfig: Boolean)

    fun start() {
        stopping.set(false)
        emit(mapOf("state" to "connecting", "textureId" to surfaceEntry.id()))
        connectWs()
        codecHandler.post { initDecoder() }
        codecHandler.post { drainLoop() }
    }

    fun stop() {
        stopping.set(true)
        webSocket?.close(1000, "stop")
        webSocket = null
        codecHandler.post { releaseCodec() }
        queue.clear()
        surface?.release()
        surface = null
        surfaceEntry.release()
        codecThread.quitSafely()
    }

    private fun connectWs() {
        if (stopping.get()) return
        val request = Request.Builder().url(wsUrl).build()
        webSocket = client.newWebSocket(request, object : WebSocketListener() {
            override fun onOpen(webSocket: WebSocket, response: Response) {
                reconnectAttempt = 0
                emit(mapOf("state" to "connected", "textureId" to surfaceEntry.id()))
            }

            override fun onMessage(webSocket: WebSocket, bytes: ByteString) {
                val data = bytes.toByteArray()
                if (data.isEmpty()) return
                offerFrame(
                    Frame(
                        bytes = data,
                        isKey = isKeyframeAnnexB(data),
                        isConfig = isConfigAnnexB(data),
                    ),
                )
            }

            override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
                emit(mapOf("state" to "closed", "code" to code))
                scheduleReconnect()
            }

            override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                emit(mapOf("state" to "error", "message" to (t.message ?: "ws failure")))
                scheduleReconnect()
            }
        })
    }

    private fun scheduleReconnect() {
        if (stopping.get()) return
        reconnectAttempt++
        val delayMs = min(30_000L, 2000L * reconnectAttempt)
        emit(mapOf("state" to "reconnecting", "attempt" to reconnectAttempt, "delayMs" to delayMs))
        codecHandler.postDelayed({
            if (!stopping.get()) connectWs()
        }, delayMs)
    }

    private fun offerFrame(frame: Frame) {
        if (queue.remainingCapacity() == 0) {
            skipping = true
            queue.clear()
        }
        if (skipping && !frame.isKey && !frame.isConfig) return
        if (frame.isKey) skipping = false
        queue.offer(frame)
    }

    private fun initDecoder() {
        if (surface != null) return
        val st: SurfaceTexture = surfaceEntry.surfaceTexture()
        surface = Surface(st)
        try {
            codec = MediaCodec.createDecoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
            val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, 1280, 720)
            codec?.configure(format, surface, null, 0)
            codec?.start()
            configured = true
            emit(mapOf("state" to "decoderReady"))
        } catch (e: Exception) {
            emit(mapOf("state" to "decoderError", "message" to e.message))
        }
    }

    private fun releaseCodec() {
        try {
            codec?.stop()
        } catch (_: Exception) {
        }
        try {
            codec?.release()
        } catch (_: Exception) {
        }
        codec = null
        configured = false
    }

    private fun drainLoop() {
        if (stopping.get()) return
        val frame = queue.poll()
        if (frame != null && configured) {
            feedCodec(frame)
        }
        codecHandler.postDelayed({ drainLoop() }, if (frame == null) 5 else 0)
    }

    private fun feedCodec(frame: Frame) {
        val c = codec ?: return
        try {
            val inIndex = c.dequeueInputBuffer(10_000)
            if (inIndex >= 0) {
                val buf: ByteBuffer? = c.getInputBuffer(inIndex)
                buf?.clear()
                buf?.put(frame.bytes)
                val flags = if (frame.isKey) MediaCodec.BUFFER_FLAG_KEY_FRAME else 0
                c.queueInputBuffer(inIndex, 0, frame.bytes.size, 0, flags)
            }
            drainOutput(c)
        } catch (e: Exception) {
            emit(mapOf("state" to "decodeError", "message" to e.message))
        }
    }

    private fun drainOutput(c: MediaCodec) {
        val info = MediaCodec.BufferInfo()
        var outIndex = c.dequeueOutputBuffer(info, 0)
        while (outIndex >= 0) {
            c.releaseOutputBuffer(outIndex, info.size > 0)
            outIndex = c.dequeueOutputBuffer(info, 0)
        }
    }
}

private fun isConfigAnnexB(data: ByteArray): Boolean {
    var i = 0
    while (i + 4 < data.size) {
        val nal = nalType(data, i)
        if (nal == 7 || nal == 8) return true
        i = nextStart(data, i + 1)
        if (i < 0) break
    }
    return false
}

private fun isKeyframeAnnexB(data: ByteArray): Boolean {
    var i = 0
    while (i + 4 < data.size) {
        if (nalType(data, i) == 5) return true
        i = nextStart(data, i + 1)
        if (i < 0) break
    }
    return false
}

private fun nalType(data: ByteArray, start: Int): Int {
    var i = start
    if (i + 3 < data.size && data[i] == 0.toByte() && data[i + 1] == 0.toByte()) {
        if (data[i + 2] == 1.toByte()) i += 3
        else if (i + 2 < data.size && data[i + 2] == 0.toByte() && data[i + 3] == 1.toByte()) i += 4
    }
    return if (i < data.size) data[i].toInt() and 0x1F else -1
}

private fun nextStart(data: ByteArray, from: Int): Int {
    for (i in from until data.size - 3) {
        if (data[i] == 0.toByte() && data[i + 1] == 0.toByte() &&
            (data[i + 2] == 1.toByte() || (i + 3 < data.size && data[i + 2] == 0.toByte() && data[i + 3] == 1.toByte()))
        ) {
            return i
        }
    }
    return -1
}
