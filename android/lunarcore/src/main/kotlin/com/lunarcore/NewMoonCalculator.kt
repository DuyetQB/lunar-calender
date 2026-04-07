package com.lunarcore

internal object NewMoonCalculator {

    fun lunationBeforeOrAt(jdn: Int): Int {
        val ref = AstronomicalCalculator.newMoonRefJD
        val month = AstronomicalCalculator.synodicMonth
        return ((jdn - AstronomicalCalculator.newMoonRefJDN) / month).toInt()
    }

    fun newMoonJDN(lunation: Int): Int {
        val jd = AstronomicalCalculator.newMoonRefJD + lunation * AstronomicalCalculator.synodicMonth
        return kotlin.math.floor(jd).toInt()
    }

    fun newMoonJD(lunation: Int): Double =
        AstronomicalCalculator.newMoonRefJD + lunation * AstronomicalCalculator.synodicMonth
}
