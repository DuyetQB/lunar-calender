package com.lunarcore.app.reminder

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import com.lunarcore.LunarEngine
import com.lunarcore.SolarDate
import com.lunarcore.app.notes.CalendarNote
import com.lunarcore.app.notes.NoteStore
import com.lunarcore.app.notes.toLunarDateOrNull
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneId

enum class ReminderSound(val raw: String) {
    DEFAULT("default"),
    RINGTONE("ringtone"),
    SILENT("silent");

    companion object {
        fun from(raw: String): ReminderSound = entries.firstOrNull { it.raw == raw } ?: DEFAULT
    }
}

class ReminderScheduler(private val context: Context) {
    private val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    private val engine = LunarEngine()

    fun requestPermissionIfNeeded() {
        ensureChannel()
    }

    fun schedule(note: CalendarNote) {
        if (!note.hasReminder) return
        val next = nextReminderMillis(note) ?: return
        val intent = Intent(context, ReminderReceiver::class.java).apply {
            putExtra("note_id", note.id)
        }
        val pending = PendingIntent.getBroadcast(
            context,
            note.id.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, next, pending)
    }

    fun cancel(note: CalendarNote) {
        val intent = Intent(context, ReminderReceiver::class.java)
        val pending = PendingIntent.getBroadcast(
            context,
            note.id.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pending)
    }

    fun rescheduleAll() {
        val notes = NoteStore(context).load()
        notes.filter { it.hasReminder }.forEach { note ->
            cancel(note)
            schedule(note)
        }
    }

    private fun nextReminderMillis(note: CalendarNote): Long? {
        val base = note.reminderAtMillis ?: return null
        if (!note.isLunarRepeat) return base.takeIf { it > System.currentTimeMillis() }

        val lunar = note.toLunarDateOrNull() ?: return base.takeIf { it > System.currentTimeMillis() }
        val baseDateTime = LocalDateTime.ofInstant(Instant.ofEpochMilli(base), ZoneId.systemDefault())
        val now = LocalDateTime.now()
        for (year in now.year..(now.year + 3)) {
            val solar = engine.lunarToSolar(lunar.copy(year = year))
            val candidate = LocalDateTime.of(
                solar.year,
                solar.month,
                solar.day,
                baseDateTime.hour,
                baseDateTime.minute
            )
            if (candidate.isAfter(now)) {
                return candidate.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
            }
        }
        return null
    }

    private fun ensureChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            ReminderReceiver.CHANNEL_ID,
            "Calendar reminders",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Notes and lunar reminders"
            enableVibration(true)
        }
        manager.createNotificationChannel(channel)
    }

    companion object {
        fun soundPreference(context: Context): ReminderSound {
            val prefs = context.getSharedPreferences("app_settings", Context.MODE_PRIVATE)
            return ReminderSound.from(prefs.getString("reminder_sound", ReminderSound.DEFAULT.raw) ?: ReminderSound.DEFAULT.raw)
        }

        fun setSoundPreference(context: Context, value: ReminderSound) {
            context.getSharedPreferences("app_settings", Context.MODE_PRIVATE)
                .edit()
                .putString("reminder_sound", value.raw)
                .apply()
        }
    }
}
