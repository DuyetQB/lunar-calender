package com.lunarcore.app.notes

import java.util.UUID

data class CalendarNote(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val content: String,
    val solarYear: Int,
    val solarMonth: Int,
    val solarDay: Int,
    val lunarYear: Int? = null,
    val lunarMonth: Int? = null,
    val lunarDay: Int? = null,
    val lunarLeap: Boolean = false,
    val hasReminder: Boolean = false,
    val reminderAtMillis: Long? = null,
    val isLunarRepeat: Boolean = false,
    val createdAtMillis: Long = System.currentTimeMillis()
)
