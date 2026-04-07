package com.lunarcore

internal object AstronomicalCalculator {
    const val synodicMonth = 29.530588853
    const val newMoonRefJDN = 2451556
    val newMoonRefJD: Double = newMoonRefJDN.toDouble()

    fun rad(deg: Double) = deg * Math.PI / 180.0
    fun deg(rad: Double) = rad * 180.0 / Math.PI

    fun norm360(d: Double): Double {
        var x = d
        while (x >= 360) x -= 360
        while (x < 0) x += 360
        return x
    }
}
