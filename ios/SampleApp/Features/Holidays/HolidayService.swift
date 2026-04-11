//
//  HolidayService.swift
//  Upcoming holidays, lunar↔solar (offline), and local notifications.
//

import Foundation

enum HolidayReminderScheduleResult: Equatable {
    case scheduled
    case denied
    case noOccurrence
}

final class HolidayService {
    private let engine = LunarEngine()
    private let reminderService: ReminderService

    init(reminderService: ReminderService = ReminderService()) {
        self.reminderService = reminderService
    }

    /// Full static catalog (Vietnamese traditional + national solar holidays).
    func getAllHolidays() -> [Holiday] {
        HolidayData.allHolidays
    }

    /// Nearest upcoming occurrences after `date`, sorted soonest first.
    func getUpcomingHolidays(from date: Date) -> [Holiday] {
        HolidayData.allHolidays
            .compactMap { h -> (Holiday, Date)? in
                guard let next = nextOccurrence(of: h, from: date) else { return nil }
                return (h, next)
            }
            .sorted { $0.1 < $1.1 }
            .prefix(24)
            .map(\.0)
    }

    /// Solar `Date` (08:00 Vietnam) for `holiday` in the given year.
    /// - Lunar holidays: `year` is **lunar year**.
    /// - Solar holidays: `year` is **Gregorian year**.
    func getHolidayDate(holiday: Holiday, year: Int) -> Date {
        if holiday.isLunar, let day = holiday.lunarDay, let month = holiday.lunarMonth {
            let lunar = LunarDate(year: year, month: month, day: day, isLeapMonth: false)
            let solar = engine.lunarToSolar(date: lunar)
            return LunarReminderConverter.date(from: solar, hour: 8, minute: 0) ?? Date()
        }
        guard let anchor = holiday.solarDate else { return Date() }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = LunarReminderConverter.vietnamTimeZone
        let m = cal.component(.month, from: anchor)
        let d = cal.component(.day, from: anchor)
        return cal.date(from: DateComponents(year: year, month: m, day: d, hour: 8, minute: 0)) ?? Date()
    }

    /// Thin wrapper around `LunarReminderConverter.convertLunarToSolar` (replaceable / testable).
    func convertLunarToSolar(day: Int, month: Int, year: Int) -> Date? {
        LunarReminderConverter.convertLunarToSolar(
            lunarDay: day,
            lunarMonth: month,
            year: year,
            isLeapMonth: false,
            hour: 8,
            minute: 0,
            engine: engine
        )
    }

    /// Next occurrence strictly after `from` (08:00 Vietnam), within supported engine years.
    func nextOccurrence(of holiday: Holiday, from: Date) -> Date? {
        if holiday.isLunar, let day = holiday.lunarDay, let month = holiday.lunarMonth {
            let anchorSolar = solarDate(from: from)
            let rawLunarYear = engine.solarToLunar(date: anchorSolar).year
            // Include previous lunar year so we never skip the next Tết when the engine’s lunar
            // year label flips just before the solar Tết date.
            let startLunarYear = max(LunarEngine.supportedYearRange.lowerBound, rawLunarYear - 1)
            let upperLunar = min(startLunarYear + 12, LunarEngine.supportedYearRange.upperBound)
            for lunarYear in startLunarYear...upperLunar where LunarEngine.supportedYearRange.contains(lunarYear) {
                let ld = LunarDate(year: lunarYear, month: month, day: day, isLeapMonth: false)
                let solar = engine.lunarToSolar(date: ld)
                guard let fire = LunarReminderConverter.date(from: solar, hour: 8, minute: 0) else { continue }
                if fire > from { return fire }
            }
            return nil
        }
        guard !holiday.isLunar, let anchor = holiday.solarDate else { return nil }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = LunarReminderConverter.vietnamTimeZone
        let mo = cal.component(.month, from: anchor)
        let da = cal.component(.day, from: anchor)
        let rawGregYear = cal.component(.year, from: from)
        let startYear = max(LunarEngine.supportedYearRange.lowerBound, rawGregYear - 1)
        let upperGreg = min(startYear + 5, LunarEngine.supportedYearRange.upperBound)
        for y in startYear...upperGreg where LunarEngine.supportedYearRange.contains(y) {
            guard let fire = cal.date(from: DateComponents(year: y, month: mo, day: da, hour: 8, minute: 0)) else { continue }
            if fire > from { return fire }
        }
        return nil
    }

    /// Schedules the next occurrence (replaces any prior pending request for this holiday id).
    @discardableResult
    func scheduleHolidayReminder(holiday: Holiday) async -> HolidayReminderScheduleResult {
        let holiday = HolidayData.allHolidays.first(where: { $0.id == holiday.id }) ?? holiday
        // Snapshot before awaiting permission so the “next” date matches what the UI showed; if the
        // user returns from the system sheet after that instant passes, re-resolve from `Date()`.
        let referenceFrom = Date()
        let authorized = await reminderService.requestNotificationPermission()
        guard authorized else { return .denied }
        let now = Date()

        guard let fireAfterReference = nextOccurrence(of: holiday, from: referenceFrom) else {
            return .noOccurrence
        }
        let fire: Date
        if fireAfterReference > now {
            fire = fireAfterReference
        } else if let fireAfterNow = nextOccurrence(of: holiday, from: now) {
            fire = fireAfterNow
        } else {
            return .noOccurrence
        }

        guard fire > now else { return .noOccurrence }
        reminderService.scheduleHolidayNotification(holiday: holiday, fireDate: fire, now: now)
        return .scheduled
    }

    func daysRemaining(from: Date, to: Date) -> Int? {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = LunarReminderConverter.vietnamTimeZone
        let s1 = cal.startOfDay(for: from)
        let s2 = cal.startOfDay(for: to)
        return cal.dateComponents([.day], from: s1, to: s2).day
    }

    private func solarDate(from date: Date) -> SolarDate {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = LunarReminderConverter.vietnamTimeZone
        let y = cal.component(.year, from: date)
        let m = cal.component(.month, from: date)
        let d = cal.component(.day, from: date)
        return SolarDate(year: y, month: m, day: d)
    }

    func lunarLine(at date: Date) -> String {
        let solar = solarDate(from: date)
        let lunar = engine.solarToLunar(date: solar)
        var s = "\(lunar.day)/\(lunar.month)/\(lunar.year)"
        if lunar.isLeapMonth { s += " \(String(localized: "detail_leap_suffix"))" }
        return s
    }

    func solarLunarCaption(at date: Date) -> String {
        let solar = solarDate(from: date)
        let lunar = engine.solarToLunar(date: solar)
        let lunarLine = "\(lunar.day)/\(lunar.month)/\(lunar.year)" + (lunar.isLeapMonth ? " \(String(localized: "detail_leap_suffix"))" : "")
        return String(
            format: String(localized: "holiday_date_line_format"),
            solar.day,
            solar.month,
            solar.year,
            lunarLine
        )
    }
}
