package com.lunarcore.app.notes

import android.content.Context
import com.lunarcore.LunarDate
import org.json.JSONArray
import org.json.JSONObject

class NoteStore(private val context: Context) {
    private val prefs = context.getSharedPreferences("calendar_notes_store", Context.MODE_PRIVATE)
    private val key = "notes_json"

    fun load(): List<CalendarNote> {
        val raw = prefs.getString(key, null) ?: return emptyList()
        return runCatching {
            val arr = JSONArray(raw)
            buildList {
                for (i in 0 until arr.length()) add(arr.getJSONObject(i).toNote())
            }
        }.getOrDefault(emptyList())
    }

    fun save(notes: List<CalendarNote>) {
        val arr = JSONArray()
        notes.forEach { arr.put(it.toJson()) }
        prefs.edit().putString(key, arr.toString()).apply()
    }

    fun addNote(note: CalendarNote) {
        val notes = load().toMutableList()
        notes.add(note)
        save(notes)
    }

    fun deleteNote(id: String) {
        save(load().filterNot { it.id == id })
    }

    fun updateNote(note: CalendarNote) {
        val notes = load().toMutableList()
        val idx = notes.indexOfFirst { it.id == note.id }
        if (idx >= 0) {
            notes[idx] = note
            save(notes)
        }
    }

    fun notesForDate(year: Int, month: Int, day: Int): List<CalendarNote> =
        load()
            .filter { it.solarYear == year && it.solarMonth == month && it.solarDay == day }
            .sortedByDescending { it.createdAtMillis }

    fun hasNotesOn(year: Int, month: Int, day: Int): Boolean =
        load().any { it.solarYear == year && it.solarMonth == month && it.solarDay == day }

    fun hasRemindersOn(year: Int, month: Int, day: Int): Boolean =
        load().any {
            it.solarYear == year && it.solarMonth == month && it.solarDay == day &&
                it.hasReminder && it.reminderAtMillis != null
        }

    private fun CalendarNote.toJson(): JSONObject = JSONObject().apply {
        put("id", id)
        put("title", title)
        put("content", content)
        put("solarYear", solarYear)
        put("solarMonth", solarMonth)
        put("solarDay", solarDay)
        put("lunarYear", lunarYear)
        put("lunarMonth", lunarMonth)
        put("lunarDay", lunarDay)
        put("lunarLeap", lunarLeap)
        put("hasReminder", hasReminder)
        put("reminderAtMillis", reminderAtMillis)
        put("isLunarRepeat", isLunarRepeat)
        put("createdAtMillis", createdAtMillis)
    }

    private fun JSONObject.toNote(): CalendarNote = CalendarNote(
        id = optString("id"),
        title = optString("title"),
        content = optString("content"),
        solarYear = optInt("solarYear"),
        solarMonth = optInt("solarMonth"),
        solarDay = optInt("solarDay"),
        lunarYear = if (has("lunarYear") && !isNull("lunarYear")) optInt("lunarYear") else null,
        lunarMonth = if (has("lunarMonth") && !isNull("lunarMonth")) optInt("lunarMonth") else null,
        lunarDay = if (has("lunarDay") && !isNull("lunarDay")) optInt("lunarDay") else null,
        lunarLeap = optBoolean("lunarLeap", false),
        hasReminder = optBoolean("hasReminder", false),
        reminderAtMillis = if (has("reminderAtMillis") && !isNull("reminderAtMillis")) optLong("reminderAtMillis") else null,
        isLunarRepeat = optBoolean("isLunarRepeat", false),
        createdAtMillis = optLong("createdAtMillis", System.currentTimeMillis())
    )
}

fun CalendarNote.toLunarDateOrNull(): LunarDate? {
    val y = lunarYear ?: return null
    val m = lunarMonth ?: return null
    val d = lunarDay ?: return null
    return LunarDate(year = y, month = m, day = d, isLeapMonth = lunarLeap)
}
