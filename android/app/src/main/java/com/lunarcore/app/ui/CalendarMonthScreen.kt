package com.lunarcore.app.ui

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.lunarcore.LunarEngine
import com.lunarcore.SolarDate

@Composable
fun CalendarMonthScreen() {
    val navController = rememberNavController()
    val engine = remember { LunarEngine() }
    NavHost(navController = navController, startDestination = "calendar") {
        composable("calendar") {
            CalendarGridScreen(engine = engine, onDateClick = { date ->
                navController.navigate("detail/${date.year}/${date.month}/${date.day}")
            })
        }
        composable("detail/{y}/{m}/{d}") { backStackEntry ->
            val y = backStackEntry.arguments?.getString("y")?.toIntOrNull() ?: 2024
            val m = backStackEntry.arguments?.getString("m")?.toIntOrNull() ?: 3
            val d = backStackEntry.arguments?.getString("d")?.toIntOrNull() ?: 15
            DetailScreen(solar = SolarDate(y, m, d), engine = engine) {
                navController.popBackStack()
            }
        }
    }
}

@Composable
fun CalendarGridScreen(
    engine: LunarEngine,
    onDateClick: (SolarDate) -> Unit
) {
    var year by remember { mutableIntStateOf(2024) }
    var month by remember { mutableIntStateOf(3) }

    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Lịch Âm") })
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
                        Surface(
                            modifier = Modifier
                                .size(40.dp)
                                .clickable { onDateClick(solar) },
                            shape = RoundedCornerShape(8.dp),
                            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                        ) {
                            Column(
                                Modifier.fillMaxSize(),
                                verticalArrangement = Arrangement.Center,
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Text("$day", style = MaterialTheme.typography.bodyMedium)
                                Text("${lunar.day}", style = MaterialTheme.typography.labelSmall)
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
    onBack: () -> Unit
) {
    val lunar = engine.solarToLunar(solar)
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
