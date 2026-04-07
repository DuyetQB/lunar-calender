package com.lunarcore

internal object SunLongitudeCalculator {

    fun sunLongitude(jd: Double): Double {
        val n = jd - 2451545.0
        val L = 280.466 + 0.9856474 * n
        return AstronomicalCalculator.norm360(L)
    }

    fun sunLongitudeAccurate(jd: Double): Double {
        val n = jd - 2451545.0
        val meanLong = AstronomicalCalculator.norm360(280.466 + 0.9856474 * n)
        val meanAnom = AstronomicalCalculator.norm360(357.528 + 0.9856003 * n)
        val rad = AstronomicalCalculator.rad(meanAnom)
        val center = 1.915 * kotlin.math.sin(rad) + 0.020 * kotlin.math.sin(2 * rad)
        val lambda = meanLong + center
        return AstronomicalCalculator.norm360(lambda)
    }
}
