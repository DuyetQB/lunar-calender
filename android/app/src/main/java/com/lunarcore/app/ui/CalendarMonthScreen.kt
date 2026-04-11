package com.lunarcore.app.ui

import android.app.TimePickerDialog
import androidx.compose.foundation.background
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.Alignment
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.lunarcore.LunarDate
import com.lunarcore.LunarEngine
import com.lunarcore.SolarDate
import com.lunarcore.app.notes.CalendarNote
import com.lunarcore.app.notes.NoteStore
import com.lunarcore.app.reminder.ReminderScheduler
import com.lunarcore.app.reminder.ReminderSound
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneId

@Composable
fun CalendarMonthScreen() {
    val navController = rememberNavController()
    val engine = remember { LunarEngine() }
    val context = LocalContext.current
    val noteStore = remember { NoteStore(context) }
    val scheduler = remember { ReminderScheduler(context) }
    var version by remember { mutableIntStateOf(0) }

    fun refresh() {
        version++
    }

    NavHost(navController = navController, startDestination = "calendar") {
        composable("calendar") {
            CalendarGridScreen(
                engine = engine,
                noteStore = noteStore,
                refreshVersion = version,
                onDateClick = { date ->
                navController.navigate("detail/${date.year}/${date.month}/${date.day}")
            },
                onOpenSettings = { navController.navigate("settings") }
            )
        }
        composable("detail/{y}/{m}/{d}") { backStackEntry ->
            val y = backStackEntry.arguments?.getString("y")?.toIntOrNull() ?: 2024
            val m = backStackEntry.arguments?.getString("m")?.toIntOrNull() ?: 3
            val d = backStackEntry.arguments?.getString("d")?.toIntOrNull() ?: 15
            DetailScreen(
                solar = SolarDate(y, m, d),
                engine = engine,
                noteStore = noteStore,
                scheduler = scheduler,
                refreshVersion = version,
                onChanged = { refresh() },
                onBack = { navController.popBackStack() }
            )
        }
        composable("settings") {
            SettingsScreen(onBack = { navController.popBackStack() }, scheduler = scheduler)
        }
    }
}

@Composable
fun CalendarGridScreen(
    engine: LunarEngine,
    noteStore: NoteStore,
    refreshVersion: Int,
    onDateClick: (SolarDate) -> Unit,
    onOpenSettings: () -> Unit
) {
    val now = LocalDate.now()
    var year by remember { mutableIntStateOf(2024) }
    var month by remember { mutableIntStateOf(3) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Lich am") },
                actions = { TextButton(onClick = onOpenSettings) { Text("Settings") } }
            )
        }
    ) { padding ->
        Column(Modifier.padding(padding)) {
            Row(
                Modifier.fillMaxWidth().padding(8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                TextButton(onClick = {
                    if (month == 1) { year -= 1; month = 12 } else month -= 1
                }) { Text("−") }
                Text("$month/$year", style = MaterialTheme.typography.titleMedium)
                TextButton(onClick = {
                    if (month == 12) { year += 1; month = 1 } else month += 1
                }) { Text("+") }
            }
            MonthGrid(
                year = year,
                month = month,
                engine = engine,
                noteStore = noteStore,
                today = SolarDate(now.year, now.monthValue, now.dayOfMonth),
                onDateClick = onDateClick
            )
        }
    }
}

@Composable
fun MonthGrid(
    year: Int,
    month: Int,
    engine: LunarEngine,
    noteStore: NoteStore,
    today: SolarDate,
    onDateClick: (SolarDate) -> Unit
) {
    val days = (1..engine.daysInSolarMonth(year, month)).toList()
    val firstWeekday = engine.firstWeekdayOfMonth(year, month)
    val empty = (firstWeekday + 6) % 7
    val totalCells = empty + days.size
    val rows = (totalCells + 6) / 7
    val weekdays = listOf("T2", "T3", "T4", "T5", "T6", "T7", "CN")

    Column(Modifier.padding(8.dp)) {
        Row(
            Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            weekdays.forEach { Text(it, style = MaterialTheme.typography.labelSmall) }
        }
        Spacer(Modifier.height(8.dp))
        val grid = List(rows * 7) { i ->
            if (i < empty) null
            else if (i - empty < days.size) days[i - empty]
            else null
        }
        grid.chunked(7).forEach { row ->
            Row(
                Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                row.forEach { day ->
                    if (day == null) {
                        Spacer(Modifier.size(40.dp))
                    } else {
                        val solar = SolarDate(year, month, day)
                        val lunar = engine.solarToLunar(solar)
                        val hasNotes = noteStore.hasNotesOn(year, month, day)
                        val hasReminder = noteStore.hasRemindersOn(year, month, day)
                        val isToday = solar == today
                        Surface(
                            modifier = Modifier
                                .size(40.dp)
                                .clickable { onDateClick(solar) },
                            shape = RoundedCornerShape(8.dp),
                            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
                            border = if (hasReminder) BorderStroke(1.dp, Color(0xFFD17A00)) else null
                        ) {
                            Row(
                                Modifier.fillMaxSize().padding(horizontal = 2.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(
                                    modifier = Modifier.weight(1f),
                                    verticalArrangement = Arrangement.Center,
                                    horizontalAlignment = Alignment.CenterHorizontally
                                ) {
                                    Text(
                                        "$day",
                                        style = MaterialTheme.typography.bodyMedium,
                                        fontWeight = if (isToday) FontWeight.Bold else FontWeight.Normal,
                                        color = if (isToday) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface
                                    )
                                    Text("${lunar.day}", style = MaterialTheme.typography.labelSmall)
                                    Box(
                                        modifier = Modifier
                                            .padding(top = 2.dp)
                                            .size(5.dp)
                                            .background(
                                                if (hasNotes) MaterialTheme.colorScheme.primary else Color.Transparent,
                                                RoundedCornerShape(100)
                                            )
                                    )
                                }
                                if (hasReminder) {
                                    Text(
                                        "🔔",
                                        style = MaterialTheme.typography.labelSmall,
                                        modifier = Modifier.width(10.dp)
                                    )
                                }
                            }
                        }
                    }
                }
            }
            Spacer(Modifier.height(4.dp))
        }
    }
}

@Composable
fun DetailScreen(
    solar: SolarDate,
    engine: LunarEngine,
    noteStore: NoteStore,
    scheduler: ReminderScheduler,
    refreshVersion: Int,
    onChanged: () -> Unit,
    onBack: () -> Unit
) {
    val lunar = engine.solarToLunar(solar)
    val notes = remember(refreshVersion, solar.year, solar.month, solar.day) {
        noteStore.notesForDate(solar.year, solar.month, solar.day)
    }
    var showEditor by remember { mutableStateOf(false) }
    var editing by remember { mutableStateOf<CalendarNote?>(null) }
    val (dayCc, monthCc, yearCc) = engine.canChi(solar)
    val hoangDao = engine.isHoangDao(solar)
    val hours = engine.goodHours(solar)
    val (goodFor, avoidFor) = engine.evaluation(solar)
    val term = engine.tietKhi(solar)

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("${solar.day}/${solar.month}/${solar.year}") },
                navigationIcon = {
                    TextButton(onClick = onBack) { Text("←") }
                },
                actions = {
                    TextButton(onClick = {
                        editing = null
                        showEditor = true
                    }) { Text("Note +") }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                SectionTitle("Notes")
                if (notes.isEmpty()) {
                    Text("No note for this date. Tap Note + to add.")
                } else {
                    notes.forEach { note ->
                        Card(
                            modifier = Modifier.fillMaxWidth().padding(top = 6.dp),
                            shape = RoundedCornerShape(12.dp)
                        ) {
                            Column(Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                Text(note.title, fontWeight = FontWeight.SemiBold)
                                if (note.content.isNotBlank()) {
                                    Text(note.content, style = MaterialTheme.typography.bodySmall)
                                }
                                if (note.hasReminder && note.reminderAtMillis != null) {
                                    val dateTime = LocalDateTime.ofInstant(
                                        Instant.ofEpochMilli(note.reminderAtMillis),
                                        ZoneId.systemDefault()
                                    )
                                    Text(
                                        "🔔 ${dateTime.toLocalDate()} ${dateTime.toLocalTime()}${if (note.isLunarRepeat) " • Lunar yearly" else ""}",
                                        style = MaterialTheme.typography.labelSmall,
                                        color = Color(0xFFD17A00)
                                    )
                                }
                                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                    TextButton(onClick = {
                                        editing = note
                                        showEditor = true
                                    }) { Text("Edit") }
                                    TextButton(onClick = {
                                        noteStore.deleteNote(note.id)
                                        scheduler.cancel(note)
                                        onChanged()
                                    }) { Text("Delete") }
                                }
                            }
                        }
                    }
                }
            }
            item {
                SectionTitle("Ngày Dương")
                Text("${solar.day}/${solar.month}/${solar.year}")
            }
            item {
                SectionTitle("Ngày Âm")
                Text("${lunar.day}/${lunar.month}/${lunar.year}" + if (lunar.isLeapMonth) " (nhuận)" else "")
            }
            item {
                SectionTitle("Tiết Khí")
                Text(term)
            }
            item {
                SectionTitle("Can Chi")
                Text("Ngày $dayCc\nTháng $monthCc\nNăm $yearCc")
            }
            item {
                SectionTitle("Hoàng Đạo")
                Text(if (hoangDao) "Có" else "Không (Hắc Đạo)")
            }
            item {
                SectionTitle("Giờ Hoàng Đạo")
                hours.forEach { Text(it) }
            }
            item {
                SectionTitle("Nên")
                Text(goodFor.joinToString(", "))
            }
            item {
                SectionTitle("Kiêng kỵ")
                Text(avoidFor.joinToString(", "))
            }
        }
    }

    if (showEditor) {
        NoteEditorDialog(
            solar = solar,
            lunar = lunar,
            existing = editing,
            onDismiss = { showEditor = false },
            onSave = { note ->
                if (editing == null) noteStore.addNote(note) else noteStore.updateNote(note)
                scheduler.cancel(note)
                if (note.hasReminder) scheduler.schedule(note)
                onChanged()
                showEditor = false
            }
        )
    }
}

@Composable
fun SectionTitle(title: String) {
    Text(
        title,
        style = MaterialTheme.typography.titleSmall,
        color = MaterialTheme.colorScheme.onSurfaceVariant
    )
    Spacer(Modifier.height(4.dp))
}

@Composable
private fun NoteEditorDialog(
    solar: SolarDate,
    lunar: LunarDate,
    existing: CalendarNote?,
    onDismiss: () -> Unit,
    onSave: (CalendarNote) -> Unit
) {
    var title by remember(existing) { mutableStateOf(existing?.title ?: "") }
    var content by remember(existing) { mutableStateOf(existing?.content ?: "") }
    var hasReminder by remember(existing) { mutableStateOf(existing?.hasReminder ?: false) }
    var isLunarRepeat by remember(existing) { mutableStateOf(existing?.isLunarRepeat ?: false) }
    val initialMillis = existing?.reminderAtMillis ?: LocalDateTime.of(solar.year, solar.month, solar.day, 8, 0)
        .atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
    var reminderMillis by remember(existing) { mutableLongStateOf(initialMillis) }
    val context = LocalContext.current

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(if (existing == null) "New note" else "Edit note") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(value = title, onValueChange = { title = it }, label = { Text("Title") })
                OutlinedTextField(value = content, onValueChange = { content = it }, label = { Text("Content") })
                Text("Solar: ${solar.day}/${solar.month}/${solar.year}")
                Text("Lunar: ${lunar.day}/${lunar.month}/${lunar.year}${if (lunar.isLeapMonth) " (leap)" else ""}")
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Checkbox(checked = hasReminder, onCheckedChange = { hasReminder = it })
                    Text("Enable reminder")
                }
                if (hasReminder) {
                    val time = LocalDateTime.ofInstant(Instant.ofEpochMilli(reminderMillis), ZoneId.systemDefault()).toLocalTime()
                    TextButton(onClick = {
                        TimePickerDialog(
                            context,
                            { _, hour, minute ->
                                val d = LocalDate.of(solar.year, solar.month, solar.day)
                                reminderMillis = LocalDateTime.of(d, LocalTime.of(hour, minute))
                                    .atZone(ZoneId.systemDefault())
                                    .toInstant()
                                    .toEpochMilli()
                            },
                            time.hour,
                            time.minute,
                            true
                        ).show()
                    }) { Text("Reminder time: ${time.hour.toString().padStart(2, '0')}:${time.minute.toString().padStart(2, '0')}") }

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Checkbox(checked = isLunarRepeat, onCheckedChange = { isLunarRepeat = it })
                        Text("Repeat by lunar date yearly")
                    }
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    val base = existing ?: CalendarNote(
                        title = "",
                        content = "",
                        solarYear = solar.year,
                        solarMonth = solar.month,
                        solarDay = solar.day,
                        lunarYear = lunar.year,
                        lunarMonth = lunar.month,
                        lunarDay = lunar.day,
                        lunarLeap = lunar.isLeapMonth
                    )
                    onSave(
                        base.copy(
                            title = title.trim(),
                            content = content,
                            hasReminder = hasReminder,
                            reminderAtMillis = if (hasReminder) reminderMillis else null,
                            isLunarRepeat = if (hasReminder) isLunarRepeat else false
                        )
                    )
                },
                enabled = title.isNotBlank()
            ) { Text("Save") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}

@Composable
private fun SettingsScreen(
    onBack: () -> Unit,
    scheduler: ReminderScheduler
) {
    var sound by remember { mutableStateOf(ReminderScheduler.soundPreference(LocalContext.current)) }
    val context = LocalContext.current
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                navigationIcon = { TextButton(onClick = onBack) { Text("←") } }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text("Reminder sound", fontWeight = FontWeight.SemiBold)
            ReminderSound.entries.forEach { option ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable {
                            sound = option
                            ReminderScheduler.setSoundPreference(context, option)
                            scheduler.rescheduleAll()
                        }
                        .padding(vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    RadioButton(selected = sound == option, onClick = {
                        sound = option
                        ReminderScheduler.setSoundPreference(context, option)
                        scheduler.rescheduleAll()
                    })
                    Text(
                        when (option) {
                            ReminderSound.DEFAULT -> "Default notification"
                            ReminderSound.RINGTONE -> "Default ringtone"
                            ReminderSound.SILENT -> "Silent"
                        }
                    )
                }
            }
        }
    }
}
