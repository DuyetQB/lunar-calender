package com.lunarcore

/**
 * Converts between Gregorian calendar (GMT+7) and Julian Day Number.
 */
internal object JulianDateConverter {

    fun jdnFromGregorian(year: Int, month: Int, day: Int): Int {
        var yy = year
        var mm = month
        if (mm <= 2) {
            yy -= 1
            mm += 12
        }
        val a = yy / 100
        val b = 2 - a + (a / 4)
        return (1461 * (yy + 4716)) / 4 + (153 * mm - 457) / 5 + day + b - 1524
    }

    fun gregorianFromJDN(jdn: Int): Triple<Int, Int, Int> {
        val a = (4 * jdn + 6884474) / 146097
        val b = jdn + (3 * a) / 4 - (146097 * a + 3) / 4
        val c = (4 * b + 3) / 1461
        val d = b - (1461 * c) / 4
        var e = (5 * d + 2) / 153
        val day = d - (153 * e + 2) / 5 + 1
        var month = e + 2
        var year = c - 4716 + (e / 10)
        if (month > 12) {
            month -= 12
            year += 1
        }
        return Triple(year, month, day)
    }

    fun jdNoon(year: Int, month: Int, day: Int): Double =
        jdnFromGregorian(year, month, day) + 0.5

    fun daysInGregorianMonth(year: Int, month: Int): Int {
        val d = intArrayOf(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
        var n = d[month - 1]
        if (month == 2 && isLeapYear(year)) n += 1
        return n
    }

    fun isLeapYear(y: Int): Boolean =
        (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
}
