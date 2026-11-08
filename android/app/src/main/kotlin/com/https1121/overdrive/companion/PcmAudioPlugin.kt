package com.https1121.overdrive.companion

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PcmAudioPlugin : MethodChannel.MethodCallHandler {
    private var track: AudioTrack? = null
    private var sampleRate = 48000

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                stopTrack()
                sampleRate = call.argument<Int>("sampleRate") ?: 48000
                val min = AudioTrack.getMinBufferSize(
                    sampleRate,
                    AudioFormat.CHANNEL_OUT_MONO,
                    AudioFormat.ENCODING_PCM_16BIT,
                )
                track = AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                            .build(),
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setSampleRate(sampleRate)
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .build(),
                    )
                    .setBufferSizeInBytes(min.coerceAtLeast(sampleRate / 10 * 2))
                    .setTransferMode(AudioTrack.MODE_STREAM)
                    .build()
                track?.play()
                result.success(null)
            }
            "write" -> {
                val data = call.argument<ByteArray>("data")
                if (data == null || data.isEmpty()) {
                    result.success(null)
                    return
                }
                val t = track
                if (t == null) {
                    result.error("no_track", "PCM playback not started", null)
                    return
                }
                t.write(data, 0, data.size)
                result.success(null)
            }
            "stop" -> {
                stopTrack()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun stopTrack() {
        try {
            track?.pause()
            track?.flush()
            track?.release()
        } catch (_: Throwable) {
        }
        track = null
    }

    companion object {
        private const val CHANNEL = "com.https1121.overdrive.companion/pcm_audio"

        fun register(flutterEngine: FlutterEngine) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler(PcmAudioPlugin())
        }
    }
}
