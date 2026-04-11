//
//  CalendarMonthView.swift
//  Monthly calendar grid; tap date -> detail.
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct CalendarMonthView: View {
    @Environment(\.appThemeColors) private var theme
    @Environment(\.locale) private var locale
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var noteStore: NoteStore
    @State private var year: Int
    @State private var month: Int
    @State private var holidaySheet: Holiday?
    @State private var holidayReminderFailure: HolidayReminderFailure?
    @State private var holidayReminderScheduled = false
    @State private var solarDaysWithHolidayReminders: Set<SolarDate> = []
    private let engine = LunarEngine()
    private let holidayService = HolidayService()
    private let reminderService = ReminderService()

    private static var today: (year: Int, month: Int, day: Int) {
        let c = Calendar.current
        let d = Date()
        return (c.component(.year, from: d), c.component(.month, from: d), c.component(.day, from: d))
    }

    init() {
        let t = Self.today
        _year = State(initialValue: t.year)
        _month = State(initialValue: t.month)
    }

    private var upcomingHolidays: [Holiday] {
        holidayService.getUpcomingHolidays(from: Date())
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                monthStepper
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        weekdayHeader
                        calendarGrid
                        VStack(alignment: .leading, spacing: 6) {
                            UpcomingHolidayCard(
                                holidays: upcomingHolidays,
                                service: holidayService,
                                onRemind: { scheduleHolidayReminder(for: $0) },
                                onView: { holidaySheet = $0 }
                            )

                            NavigationLink {
                                HolidayListView(service: holidayService) {
                                    Task { await refreshPendingHolidaySolarDays() }
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(theme.primary)
                                    Text("holiday_see_all")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                    Spacer(minLength: 8)
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(theme.primary.opacity(colorScheme == .dark ? 0.35 : 0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemBackground),
                        (colorScheme == .dark ? Color.black : theme.cardBackground).opacity(0.88),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle(Text("calendar_title"))
            .navigationBarTitleDisplayMode(.inline)
            .task(id: year * 100 + month) {
                await refreshPendingHolidaySolarDays()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task { await refreshPendingHolidaySolarDays() }
            }
            .sheet(item: $holidaySheet) { holiday in
                NavigationStack {
                    HolidayDetailView(
                        holiday: holiday,
                        service: holidayService,
                        onReminderSuccess: {
                            Task { await refreshPendingHolidaySolarDays() }
                        },
                        onDismiss: { holidaySheet = nil }
                    )
                }
            }
            .alert(
                "holiday_reminder_alert_title",
                isPresented: Binding(
                    get: { holidayReminderFailure != nil },
                    set: { if !$0 { holidayReminderFailure = nil } }
                )
            ) {
                if case .denied = holidayReminderFailure {
                    Button("holiday_reminder_open_settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                        holidayReminderFailure = nil
                    }
                }
                Button("home_close", role: .cancel) {
                    holidayReminderFailure = nil
                }
            } message: {
                switch holidayReminderFailure {
                case .denied:
                    Text("holiday_reminder_denied_message")
                case .noOccurrence:
                    Text("holiday_reminder_no_occurrence")
                case .none:
                    EmptyView()
                }
            }
            .alert(
                "holiday_reminder_scheduled_title",
                isPresented: $holidayReminderScheduled
            ) {
                Button("home_close") { holidayReminderScheduled = false }
            } message: {
                Text("holiday_reminder_scheduled_message")
            }
        }
    }

    private enum HolidayReminderFailure {
        case denied
        case noOccurrence
    }

    private func scheduleHolidayReminder(for holiday: Holiday) {
        Task {
            let result = await holidayService.scheduleHolidayReminder(holiday: holiday)
            await MainActor.run {
                switch result {
                case .scheduled:
                    holidayReminderScheduled = true
                case .denied:
                    holidayReminderFailure = .denied
                case .noOccurrence:
                    holidayReminderFailure = .noOccurrence
                }
            }
            if result == .scheduled {
                await refreshPendingHolidaySolarDays()
            }
        }
    }

    private func refreshPendingHolidaySolarDays() async {
        let set = await reminderService.pendingHolidayReminderSolarDates()
        await MainActor.run {
            solarDaysWithHolidayReminders = set
        }
    }

    private var monthStepper: some View {
        HStack(spacing: 16) {
            Button {
                if month == 1 { year -= 1; month = 12 } else { month -= 1 }
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title2)
                    .foregroundStyle(theme.primary)
            }
            Spacer()
            VStack(spacing: 2) {
                Text(monthName(month, year: year))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                Text("\(year)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                if month == 12 { year += 1; month = 1 } else { month += 1 }
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(theme.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(uiColor: .secondarySystemBackground))
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Array(weekdayLabels().enumerated()), id: \.offset) { index, d in
                Text(d)
                    .frame(maxWidth: .infinity)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(index == 6 ? theme.weekend : .secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemBackground).opacity(0.95))
    }

    private var calendarGrid: some View {
        let days = daysInMonth()
        let firstWeekday = firstWeekdayOfMonth()
        let empty = (firstWeekday + 6) % 7
        let rows = (empty + days.count + 6) / 7
        let t = Self.today

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 10) {
            ForEach(0..<(rows * 7), id: \.self) { i in
                if i < empty {
                    Color.clear
                        .frame(height: 52)
                } else if i - empty < days.count {
                    let d = days[i - empty]
                    let solar = SolarDate(year: year, month: month, day: d)
                    let isToday = year == t.year && month == t.month && d == t.day
                    let isHoangDao = engine.isHoangDao(date: solar)
                    let hasNotes = noteStore.hasNotes(on: toDate(from: solar))
                    let hasReminder = noteStore.hasReminders(on: toDate(from: solar))
                    let hasHolidayReminder = solarDaysWithHolidayReminders.contains(solar)
                    NavigationLink(destination: DetailView(solar: solar, engine: engine)) {
                        dayCell(
                            day: d,
                            solar: solar,
                            isToday: isToday,
                            isHoangDao: isHoangDao,
                            hasNotes: hasNotes,
                            hasReminder: hasReminder,
                            hasHolidayReminder: hasHolidayReminder
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear
                        .frame(height: 52)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
    }

    @available(iOS 16.0, *)
    private func dayCell(
        day: Int,
        solar: SolarDate,
        isToday: Bool,
        isHoangDao: Bool,
        hasNotes: Bool,
        hasReminder: Bool,
        hasHolidayReminder: Bool
    ) -> some View {
        let ringColor: Color = {
            if isToday { return theme.todayRing }
            if hasReminder { return .orange }
            if hasHolidayReminder { return theme.primary }
            return .clear
        }()
        let ringWidth: CGFloat = {
            if isToday { return 2 }
            if hasReminder || hasHolidayReminder { return 2 }
            return 0
        }()

        return HStack(alignment: .center, spacing: 2) {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    if #available(iOS 16.0, *) {
                        Text("\(day)")
                            .font(.system(.body, design: .rounded, weight: isToday ? .bold : .medium))
                            .foregroundStyle(isToday ? theme.primary : .primary)
                    } else {
                        // Fallback on earlier versions
                    }
                    if isHoangDao {
                        Circle()
                            .fill(theme.hoangDao)
                            .frame(width: 5, height: 5)
                            .offset(x: 2, y: -2)
                    }
                }
                Text("\(engine.solarToLunar(date: solar).day)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.secondary)
                if hasNotes {
                    Circle()
                        .fill(theme.primary)
                        .frame(width: 5, height: 5)
                } else {
                    Color.clear.frame(width: 5, height: 5)
                }
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 3) {
                if hasHolidayReminder {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(theme.primary)
                        .accessibilityLabel(Text("calendar_holiday_reminder_a11y"))
                }
                if hasReminder {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.orange)
                        .accessibilityLabel(Text("notes_enable_reminder"))
                }
            }
            .frame(width: 14, alignment: .center)
        }
        .padding(.leading, 6)
        .padding(.trailing, 4)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ringColor, lineWidth: ringWidth)
        )
        .shadow(color: .black.opacity(isToday ? 0.08 : 0.04), radius: isToday ? 4 : 2, x: 0, y: 1)
    }

    private func weekdayLabels() -> [String] {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = locale
        let s = cal.shortWeekdaySymbols
        let fallback = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
        guard s.count >= 7 else { return fallback }
        // Monday-first column order; `shortWeekdaySymbols` is Sun…Sat (indices 0…6).
        let order = [1, 2, 3, 4, 5, 6, 0]
        return order.map { i in (i < s.count ? s[i] : nil) ?? fallback[i] }
    }

    private func monthName(_ m: Int, year: Int) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = locale
        guard let date = cal.date(from: DateComponents(year: year, month: m, day: 1)) else {
            return "\(m)"
        }
        let f = DateFormatter()
        f.locale = locale
        f.dateFormat = "LLLL"
        return f.string(from: date).capitalized(with: locale)
    }

    private func daysInMonth() -> [Int] {
        let n = engine.daysInSolarMonth(year: year, month: month)
        return Array(1...n)
    }

    private func firstWeekdayOfMonth() -> Int {
        engine.firstWeekdayOfMonth(year: year, month: month)
    }

    private func toDate(from solar: SolarDate) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = LunarReminderConverter.vietnamTimeZone
        let comps = DateComponents(year: solar.year, month: solar.month, day: solar.day, hour: 12, minute: 0)
        return cal.date(from: comps) ?? Date()
    }
}
