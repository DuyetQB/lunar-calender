package com.lunarcore

internal object CanChiCalculator {

    val canNames = listOf("Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý")
    val chiNames = listOf("Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi")

    fun canChiOfDay(jdn: Int, hour: Int): String {
        val dayJDN = if (hour >= 23) jdn + 1 else jdn
        val stem = (dayJDN + 9) % 10
        val branch = (dayJDN + 1) % 12
        return "${canNames[stem]} ${chiNames[branch]}"
    }

    fun canChiOfMonth(lunarYear: Int, lunarMonth: Int): String {
        val x = (lunarYear * 12 + lunarMonth + 12) % 60
        return "${canNames[x % 10]} ${chiNames[x % 12]}"
    }

    fun canChiOfYear(lunarYear: Int): String {
        val x = (lunarYear - 4) % 60
        val stem = ((x % 10) + 10) % 10
        val branch = ((x % 12) + 12) % 12
        return "${canNames[stem]} ${chiNames[branch]}"
    }
}
