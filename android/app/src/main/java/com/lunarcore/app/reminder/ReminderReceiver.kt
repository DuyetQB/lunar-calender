package com.lunarcore.app.reminder

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import androidx.core.app.NotificationCompat
import com.lunarcore.app.MainActivity
import com.lunarcore.app.R
import com.lunarcore.app.notes.NoteStore
import android.app.PendingIntent

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val noteId = intent.getStringExtra("note_id") ?: return
        val store = NoteStore(context)
        val note = store.load().firstOrNull { it.id == noteId } ?: return

        val openIntent = Intent(context, MainActivity::class.java).apply {
            putExtra("open_note_id", note.id)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingOpen = PendingIntent.getActivity(
            context,
            note.id.hashCode(),
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(note.title)
            .setContentText(if (note.content.isBlank()) "You have a note reminder." else note.content)
            .setStyle(NotificationCompat.BigTextStyle().bigText(note.content))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingOpen)

        when (ReminderScheduler.soundPreference(context)) {
            ReminderSound.DEFAULT -> builder.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION))
            ReminderSound.RINGTONE -> builder.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE))
            ReminderSound.SILENT -> builder.setSilent(true)
        }

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(note.id.hashCode(), builder.build())

        if (note.isLunarRepeat) {
            ReminderScheduler(context).schedule(note)
        }
    }

    companion object {
        const val CHANNEL_ID = "calendar_reminders"
    }
}
