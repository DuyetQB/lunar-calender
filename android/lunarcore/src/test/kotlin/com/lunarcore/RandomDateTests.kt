package com.lunarcore

import kotlin.test.Test
import kotlin.test.assertTrue

class RandomDateTests {

    @Test
    fun roundTrip() {
        val engine = LunarEngine()
        val dates = listOf(
            Triple(1990, 5, 15),
            Triple(2000, 12, 31),
            Triple(1985, 3, 8),
            Triple(2010, 7, 20)
        )
        for ((y, m, d) in dates) {
            val solar = SolarDate(y, m, d)
            val lunar = engine.solarToLunar(solar)
            val back = engine.lunarToSolar(lunar)
            assertTrue(back.year == solar.year && back.month == solar.month && back.day == solar.day)
        }
    }

    @Test
    fun lunarDayInRange() {
        val engine = LunarEngine()
        val solar = SolarDate(2020, 6, 15)
        val lunar = engine.solarToLunar(solar)
        assertTrue(lunar.day in 1..30)
        assertTrue(lunar.month in 1..12)
    }
}
