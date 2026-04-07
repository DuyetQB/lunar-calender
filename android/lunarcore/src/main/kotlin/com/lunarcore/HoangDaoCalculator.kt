package com.lunarcore

internal object HoangDaoCalculator {

    val hourNames = listOf("Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi")

    private val hoangDaoHours = listOf(
        listOf(0, 3, 5, 6, 8, 11),
        listOf(1, 4, 6, 7, 9, 0),
        listOf(2, 5, 7, 8, 10, 1),
        listOf(3, 6, 8, 9, 11, 2),
        listOf(4, 7, 9, 10, 0, 3),
        listOf(5, 8, 10, 11, 1, 4),
        listOf(6, 9, 11, 0, 2, 5),
        listOf(7, 10, 0, 1, 3, 6),
        listOf(8, 11, 1, 2, 4, 7),
        listOf(9, 0, 2, 3, 5, 8),
        listOf(10, 1, 3, 4, 6, 9),
        listOf(11, 2, 4, 5, 7, 10)
    )

    fun dayChiIndex(jdn: Int, hour: Int): Int {
        val d = if (hour >= 23) jdn + 1 else jdn
        return (d + 1) % 12
    }

    fun isHoangDaoDay(jdn: Int, hour: Int): Boolean {
        val chi = dayChiIndex(jdn, hour)
        return chi in listOf(0, 2, 4, 6, 8, 10)
    }

    fun goodHours(jdn: Int, hour: Int): List<String> {
        val chi = dayChiIndex(jdn, hour)
        val indices = hoangDaoHours[(chi + 12) % 12]
        return indices.map { i ->
            val start = (i * 2 + 23) % 24
            val end = (start + 2) % 24
            "${hourNames[i]} (${start}h-${end}h)"
        }
    }
}
