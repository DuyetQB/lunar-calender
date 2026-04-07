package com.lunarcore

import kotlin.test.Test
import kotlin.test.assertEquals

class TetConversionTests {

    @Test
    fun tet2024() {
        val engine = LunarEngine()
        val lunar = LunarDate(2024, 1, 1, false)
        val solar = engine.lunarToSolar(lunar)
        assertEquals(2024, solar.year)
        assertEquals(2, solar.month)
        assertEquals(10, solar.day)
    }

    @Test
    fun tet2025() {
        val engine = LunarEngine()
        val lunar = LunarDate(2025, 1, 1, false)
        val solar = engine.lunarToSolar(lunar)
        assertEquals(2025, solar.year)
        assertEquals(1, solar.month)
        assertEquals(29, solar.day)
    }

    @Test
    fun roundTripTet2024() {
        val engine = LunarEngine()
        val solar = SolarDate(2024, 2, 10)
        val lunar = engine.solarToLunar(solar)
        assertEquals(2024, lunar.year)
        assertEquals(1, lunar.month)
        assertEquals(1, lunar.day)
        val back = engine.lunarToSolar(lunar)
        assertEquals(solar.year, back.year)
        assertEquals(solar.month, back.month)
        assertEquals(solar.day, back.day)
    }
}
