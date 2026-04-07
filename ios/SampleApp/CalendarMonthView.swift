//
//  CalendarMonthView.swift
//  Monthly calendar grid; tap date -> detail.
//

import SwiftUI

@available(iOS 16.0, *)
struct CalendarMonthView: View {
    @Environment(\.appThemeColors) private var theme
    @Environment(\.locale) private var locale
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var noteStore: NoteStore
    @State private var year: Int
    @State private var month: Int
    private let engine = LunarEngine()

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

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                monthStepper
                weekdayHeader
                calendarGrid
                Spacer(minLength: 0)
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
                    NavigationLink(destination: DetailView(solar: solar, engine: engine)) {
                        dayCell(day: d, solar: solar, isToday: isToday, isHoangDao: isHoangDao, hasNotes: hasNotes, hasReminder: hasReminder)
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
    private func dayCell(day: Int, solar: SolarDate, isToday: Bool, isHoangDao: Bool, hasNotes: Bool, hasReminder: Bool) -> some View {
        HStack(alignment: .center, spacing: 2) {
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

            if hasReminder {
                Image(systemName: "bell.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.orange)
                    .frame(width: 14, alignment: .center)
                    .accessibilityLabel(Text("notes_enable_reminder"))
            }
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
                .stroke(isToday ? theme.todayRing : (hasReminder ? Color.orange : Color.clear), lineWidth: hasReminder ? 2 : 0)
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
