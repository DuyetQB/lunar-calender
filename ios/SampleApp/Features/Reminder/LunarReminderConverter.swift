//
//  LunarReminderConverter.swift
//  Maps spec: lunarConverter.ts — lunar ↔ solar using LunarCore + Vietnam timezone (offline).
//

import Foundation

enum LunarReminderConverter {
    /// Vietnam civil dates for notification fire times.
    static var vietnamTimeZone: TimeZone {
        TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
    }

    private static var vietnamCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = vietnamTimeZone
        return c
    }

    // MARK: - Public API (matches requested `convertLunarToSolar` semantics)

    /// Converts Vietnamese lunar calendar date to a `Date` at **default reminder hour** (08:00) in Vietnam.
    static func convertLunarToSolar(
        lunarDay: Int,
        lunarMonth: Int,
        year: Int,
        isLeapMonth: Bool = false,
        hour: Int = 8,
        minute: Int = 0,
        engine: LunarEngine = LunarEngine()
    ) -> Date? {
        guard LunarEngine.supportedYearRange.contains(year),
              lunarMonth >= 1, lunarMonth <= 12,
              lunarDay >= 1, lunarDay <= 30 else { return nil }
        let lunar = LunarDate(year: year, month: lunarMonth, day: lunarDay, isLeapMonth: isLeapMonth)
        let solar = engine.lunarToSolar(date: lunar)
        return date(from: solar, hour: hour, minute: minute)
    }

    /// `SolarDate` + clock in Vietnam → `Date`.
    static func date(from solar: SolarDate, hour: Int, minute: Int) -> Date? {
        var comps = DateComponents()
        comps.calendar = vietnamCalendar
        comps.timeZone = vietnamTimeZone
        comps.year = solar.year
        comps.month = solar.month
        comps.day = solar.day
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        return vietnamCalendar.date(from: comps)
    }

    // MARK: - Scan solar year for lunar day (handles leap months via engine)

    /// All solar dates in **[solarYear]-01-01 … [solarYear]-12-31** (Vietnam) whose lunar day equals `lunarDay`,
    /// optionally filtered by `lunarMonth` and `isLeapMonth` when provided.
    static func solarOccurrences(
        lunarDay: Int,
        lunarMonth: Int?,
        isLeapMonth: Bool?,
        solarYear: Int,
        engine: LunarEngine = LunarEngine()
    ) -> [SolarDate] {
        guard LunarEngine.supportedYearRange.contains(solarYear) else { return [] }
        var cal = vietnamCalendar
        guard let start = cal.date(from: DateComponents(year: solarYear, month: 1, day: 1)),
              let end = cal.date(from: DateComponents(year: solarYear, month: 12, day: 31)) else { return [] }

        var out: [SolarDate] = []
        var d = start
        while true {
            if d > end { break }
            let y = cal.component(.year, from: d)
            let m = cal.component(.month, from: d)
            let day = cal.component(.day, from: d)
            let solar = SolarDate(year: y, month: m, day: day)
            let lunar = engine.solarToLunar(date: solar)
            var match = lunar.day == lunarDay
            if let lm = lunarMonth { match = match && lunar.month == lm }
            if let leap = isLeapMonth { match = match && lunar.isLeapMonth == leap }
            if match { out.append(solar) }
            guard let next = cal.date(byAdding: .day, value: 1, to: d) else { break }
            d = next
        }
        return out
    }
}
