package com.lunarcore

import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class SolarTermTests {

    @Test
    fun tietKhiNonEmpty() {
        val engine = LunarEngine()
        val solar = SolarDate(2024, 3, 20)
        val term = engine.tietKhi(solar)
        assertFalse(term.isEmpty())
    }

    @Test
    fun aroundLapXuan() {
        val engine = LunarEngine()
        val solar = SolarDate(2024, 2, 4)
        val term = engine.tietKhi(solar)
        assertTrue(
            term == "Lập Xuân" || term == "Vũ Thủy" || term == "Đại Hàn"
        )
    }
}
