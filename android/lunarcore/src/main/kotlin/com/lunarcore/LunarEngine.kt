package com.lunarcore

/**
 * Main facade: Vietnamese Lunar Calendar engine.
 * All calculations offline, GMT+7, 1900–2100.
 */
class LunarEngine {

    fun solarToLunar(date: SolarDate): LunarDate = LunarConverter.solarToLunar(date)
    fun lunarToSolar(date: LunarDate): SolarDate = LunarConverter.lunarToSolar(date)

    fun canChiOfDay(date: SolarDate): String {
        val jdn = JulianDateConverter.jdnFromGregorian(date.year, date.month, date.day)
        return CanChiCalculator.canChiOfDay(jdn, 12)
    }

    fun canChi(date: SolarDate): Triple<String, String, String> {
        val lunar = solarToLunar(date)
        val jdn = JulianDateConverter.jdnFromGregorian(date.year, date.month, date.day)
        val dayStr = CanChiCalculator.canChiOfDay(jdn, 12)
        val monthStr = CanChiCalculator.canChiOfMonth(lunar.year, lunar.month)
        val yearStr = CanChiCalculator.canChiOfYear(lunar.year)
        return Triple(dayStr, monthStr, yearStr)
    }

    fun tietKhi(date: SolarDate): String =
        TietKhiCalculator.currentTermName(date.year, date.month, date.day)

    fun isHoangDao(date: SolarDate): Boolean {
        val jdn = JulianDateConverter.jdnFromGregorian(date.year, date.month, date.day)
        return HoangDaoCalculator.isHoangDaoDay(jdn, 12)
    }

    fun goodHours(date: SolarDate): List<String> {
        val jdn = JulianDateConverter.jdnFromGregorian(date.year, date.month, date.day)
        return HoangDaoCalculator.goodHours(jdn, 12)
    }

    fun daysInSolarMonth(year: Int, month: Int): Int =
        JulianDateConverter.daysInGregorianMonth(year, month)

    fun firstWeekdayOfMonth(year: Int, month: Int): Int {
        val jdn = JulianDateConverter.jdnFromGregorian(year, month, 1)
        return (jdn + 1) % 7
    }

    fun evaluation(date: SolarDate): Pair<List<String>, List<String>> {
        val hoangDao = isHoangDao(date)
        val term = tietKhi(date)
        val goodFor = mutableListOf<String>()
        val avoidFor = mutableListOf<String>()
        if (hoangDao) {
            goodFor.addAll(listOf("wedding", "groundbreaking", "opening business"))
        } else {
            avoidFor.addAll(listOf("wedding", "groundbreaking", "opening business"))
        }
        val avoidTerms = listOf("Đại Hàn", "Tiểu Hàn", "Thu Phân", "Hạ Chí", "Đông Chí")
        if (term in avoidTerms) {
            avoidFor.addAll(listOf("funeral", "travel", "construction"))
        } else if (hoangDao) {
            goodFor.addAll(listOf("travel", "construction"))
        } else {
            avoidFor.addAll(listOf("travel", "construction"))
        }
        return goodFor to avoidFor
    }
}
