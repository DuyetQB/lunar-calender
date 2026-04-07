package com.lunarcore

internal object TietKhiCalculator {

    val termNames: List<String> = listOf(
        "Xuân Phân", "Thanh Minh", "Cốc Vũ", "Lập Hạ", "Tiểu Mãn", "Mang Chủng",
        "Hạ Chí", "Tiểu Thử", "Đại Thử", "Lập Thu", "Xử Thử", "Bạch Lộ",
        "Thu Phân", "Hàn Lộ", "Sương Giáng", "Lập Đông", "Tiểu Tuyết", "Đại Tuyết",
        "Đông Chí", "Tiểu Hàn", "Đại Hàn", "Lập Xuân", "Vũ Thủy", "Kinh Trập"
    )

    val principalLongitudes: DoubleArray = doubleArrayOf(
        315.0, 345.0, 15.0, 45.0, 75.0, 105.0, 135.0, 165.0, 195.0, 225.0, 255.0, 285.0
    )

    fun termIndex(longitude: Double): Int {
        var i = (kotlin.math.round(longitude / 15.0).toInt() % 24)
        if (i < 0) i += 24
        return i
    }

    fun termName(longitude: Double): String = termNames[termIndex(longitude)]

    fun jdForLongitude(targetLong: Double, nearJd: Double): Double {
        var jdApprox = nearJd
        repeat(10) {
            val long = SunLongitudeCalculator.sunLongitudeAccurate(jdApprox)
            var diff = AstronomicalCalculator.norm360(targetLong - long)
            if (diff > 180) diff -= 360
            if (kotlin.math.abs(diff) < 0.01) return jdApprox
            jdApprox += diff / 0.9856474
        }
        return jdApprox
    }

    fun principalTermJD(solarYear: Int, termIndex: Int): Double {
        val long = principalLongitudes[termIndex]
        val approxJD = JulianDateConverter.jdNoon(solarYear, 2, 5) + termIndex * 30.4
        return jdForLongitude(long, approxJD)
    }

    fun currentTermName(solarYear: Int, month: Int, day: Int): String {
        val jd = JulianDateConverter.jdNoon(solarYear, month, day)
        val long = SunLongitudeCalculator.sunLongitudeAccurate(jd)
        return termName(long)
    }
}
