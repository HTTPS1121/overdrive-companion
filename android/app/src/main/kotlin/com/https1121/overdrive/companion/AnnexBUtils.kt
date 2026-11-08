package com.https1121.overdrive.companion

object AnnexBUtils {
    fun isConfigAnnexB(data: ByteArray): Boolean {
        var i = 0
        while (i + 4 < data.size) {
            val nal = nalType(data, i)
            if (nal == 7 || nal == 8) return true
            i = nextStart(data, i + 1)
            if (i < 0) break
        }
        return false
    }

    fun isKeyframeAnnexB(data: ByteArray): Boolean {
        var i = 0
        while (i + 4 < data.size) {
            if (nalType(data, i) == 5) return true
            i = nextStart(data, i + 1)
            if (i < 0) break
        }
        return false
    }

    fun nalType(data: ByteArray, start: Int): Int {
        var i = start
        if (i + 3 < data.size && data[i] == 0.toByte() && data[i + 1] == 0.toByte()) {
            if (data[i + 2] == 1.toByte()) i += 3
            else if (i + 2 < data.size && data[i + 2] == 0.toByte() && data[i + 3] == 1.toByte()) i += 4
        }
        return if (i < data.size) data[i].toInt() and 0x1F else -1
    }

    fun nextStart(data: ByteArray, from: Int): Int {
        for (i in from until data.size - 3) {
            if (data[i] == 0.toByte() && data[i + 1] == 0.toByte() &&
                (data[i + 2] == 1.toByte() || (i + 3 < data.size && data[i + 2] == 0.toByte() && data[i + 3] == 1.toByte()))
            ) {
                return i
            }
        }
        return -1
    }
}
