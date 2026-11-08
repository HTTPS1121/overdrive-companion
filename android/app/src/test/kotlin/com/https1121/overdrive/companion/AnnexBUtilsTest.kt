package com.https1121.overdrive.companion

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AnnexBUtilsTest {
    @Test
    fun detectsIdrAndSps() {
        val idr = byteArrayOf(0, 0, 0, 1, 0x65, 0x88.toByte())
        val sps = byteArrayOf(0, 0, 0, 1, 0x67, 0x42.toByte())
        assertTrue(AnnexBUtils.isKeyframeAnnexB(idr))
        assertTrue(AnnexBUtils.isConfigAnnexB(sps))
        assertFalse(AnnexBUtils.isKeyframeAnnexB(sps))
    }
}
