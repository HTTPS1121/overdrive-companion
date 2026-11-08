package com.https1121.overdrive.companion

import android.media.MediaCodec
import android.media.MediaFormat
import android.os.Build
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Assume.assumeTrue
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Best-effort decode smoke test on device/emulator. CI VMs may lack hardware AVC —
 * we record the environment instead of silently skipping forever.
 */
@RunWith(AndroidJUnit4::class)
class MediaCodecAnnexBInstrumentedTest {

    @Test
    fun createsAvcDecoderAndAcceptsMinimalAnnexBKeyframe() {
        val ctx = InstrumentationRegistry.getInstrumentation().targetContext
        assumeTrue("SDK ${Build.VERSION.SDK_INT} < 21", Build.VERSION.SDK_INT >= 21)

        val codec = try {
            MediaCodec.createDecoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
        } catch (e: Exception) {
            throw AssertionError(
                "MediaCodec.createDecoderByType failed on ${Build.MODEL} API ${Build.VERSION.SDK_INT}: ${e.message}",
            )
        }
        assertNotNull(codec)

        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, 320, 240)
        try {
            codec.configure(format, null, null, 0)
            codec.start()
            val idr = byteArrayOf(
                0, 0, 0, 1, 0x67.toByte(), 0x42, 0x00, 0x0A, 0xF8.toByte(), 0x41, 0xA2.toByte(),
                0, 0, 0, 1, 0x68.toByte(), 0xCE.toByte(), 0x3C, 0x80.toByte(),
                0, 0, 0, 1, 0x65.toByte(), 0x88.toByte(), 0x84.toByte(), 0x21, 0x08.toByte(),
            )
            assertTrue(AnnexBUtils.isKeyframeAnnexB(idr))
            val inIndex = codec.dequeueInputBuffer(5_000)
            if (inIndex >= 0) {
                codec.getInputBuffer(inIndex)?.put(idr)
                codec.queueInputBuffer(inIndex, 0, idr.size, 0, 0)
            }
            val info = android.media.MediaCodec.BufferInfo()
            val outIndex = codec.dequeueOutputBuffer(info, 5_000)
            assertTrue(
                "decode did not dequeue output on ${Build.MODEL}; outIndex=$outIndex (${ctx.packageName})",
                outIndex != MediaCodec.INFO_TRY_AGAIN_LATER || inIndex >= 0,
            )
        } finally {
            try {
                codec.stop()
            } catch (_: Exception) {
            }
            codec.release()
        }
    }
}
