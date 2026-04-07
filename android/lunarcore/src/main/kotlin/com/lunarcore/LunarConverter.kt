package com.lunarcore

internal object LunarConverter {

    fun solarToLunar(solar: SolarDate): LunarDate {
        val jdn = JulianDateConverter.jdnFromGregorian(solar.year, solar.month, solar.day)
        val k = NewMoonCalculator.lunationBeforeOrAt(jdn)
        val newMoonDay = NewMoonCalculator.newMoonJDN(k)
        val lunarDay = jdn - newMoonDay + 1
        val (ly, lm, isLeap) = lunarYearMonth(k, jdn)
        return LunarDate(year = ly, month = lm, day = lunarDay, isLeapMonth = isLeap)
    }

    fun lunarToSolar(lunar: LunarDate): SolarDate {
        val k = lunationForLunarYear(lunar.year, lunar.month, lunar.isLeapMonth)
        val newMoonDay = NewMoonCalculator.newMoonJDN(k)
        val jdn = newMoonDay + lunar.day - 1
        val (y, m, d) = JulianDateConverter.gregorianFromJDN(jdn)
        return SolarDate(y, m, d)
    }

    private fun lunationOfMonth1(lunarYear: Int): Int {
        val jd315 = TietKhiCalculator.jdForLongitude(
            315.0,
            JulianDateConverter.jdNoon(lunarYear, 2, 5)
        )
        return NewMoonCalculator.lunationBeforeOrAt(kotlin.math.floor(jd315).toInt())
    }

    private fun lunationForLunarYear(lunarYear: Int, month: Int, isLeap: Boolean): Int {
        val k0 = lunationOfMonth1(lunarYear)
        val principalJDs = (0..11).map { TietKhiCalculator.principalTermJD(lunarYear, it) }
        var nextNormalMonth = 1
        for (i in 0..12) {
            val nm1 = NewMoonCalculator.newMoonJD(k0 + i)
            val nm2 = NewMoonCalculator.newMoonJD(k0 + i + 1)
            val termsIn = principalJDs.filter { it >= nm1 && it < nm2 }
            if (termsIn.isEmpty()) {
                if (isLeap && nextNormalMonth == month) return k0 + i
            } else {
                val normalNum = principalJDs.indexOfFirst { it >= nm1 && it < nm2 } + 1
                if (!isLeap && normalNum == month) return k0 + i
                nextNormalMonth = normalNum + 1
            }
        }
        return k0 + maxOf(0, month - 1)
    }

    private fun lunarYearMonth(k: Int, jdn: Int): Triple<Int, Int, Boolean> {
        val solarYear = JulianDateConverter.gregorianFromJDN(NewMoonCalculator.newMoonJDN(k)).first
        for (y in listOf(solarYear - 1, solarYear, solarYear + 1)) {
            val k0 = lunationOfMonth1(y)
            if (k < k0) continue
            val principalJDs = (0..11).map { TietKhiCalculator.principalTermJD(y, it) }
            var nextNormalMonth = 1
            for (i in 0..12) {
                val nm1 = NewMoonCalculator.newMoonJD(k0 + i)
                val nm2 = NewMoonCalculator.newMoonJD(k0 + i + 1)
                val termsIn = principalJDs.filter { it >= nm1 && it < nm2 }
                if (k0 + i == k) {
                    return if (termsIn.isEmpty()) {
                        Triple(y, nextNormalMonth, true)
                    } else {
                        val termIdx = principalJDs.indexOfFirst { it >= nm1 && it < nm2 }
                        Triple(y, termIdx + 1, false)
                    }
                }
                if (termsIn.isNotEmpty()) {
                    nextNormalMonth = principalJDs.indexOfFirst { it >= nm1 && it < nm2 } + 2
                }
            }
        }
        return Triple(solarYear, 1, false)
    }
}
