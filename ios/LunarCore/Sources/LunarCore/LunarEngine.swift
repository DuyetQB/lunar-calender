//
//  LunarEngine.swift
//  LunarCore
//
//  Main facade: Vietnamese Lunar Calendar engine.
//  All calculations offline, GMT+7, 1900–2100.
//

import Foundation

public final class LunarEngine: @unchecked Sendable {

    public static let vietnamTimezoneOffsetHours = 7
    public static let supportedYearRange = 1900...2100

    public init() {}

    // MARK: - Conversion

    /// Convert solar (Gregorian) date to lunar date.
    public func solarToLunar(date: SolarDate) -> LunarDate {
        LunarConverter.solarToLunar(date)
    }

    /// Convert lunar date to solar (first occurrence).
    public func lunarToSolar(date: LunarDate) -> SolarDate {
        LunarConverter.lunarToSolar(date)
    }

    // MARK: - Can Chi

    /// Can Chi of day for the given solar date (noon used for day boundary).
    public func canChiOfDay(date: SolarDate) -> String {
        let jdn = JulianDateConverter.jdnFromGregorian(year: date.year, month: date.month, day: date.day)
        return CanChiCalculator.canChiOfDay(jdn: jdn, hour: 12)
    }

    /// Full Can Chi string: day, month, year pillars.
    public func canChi(date: SolarDate) -> (day: String, month: String, year: String) {
        let lunar = solarToLunar(date: date)
        let jdn = JulianDateConverter.jdnFromGregorian(year: date.year, month: date.month, day: date.day)
        let dayStr = CanChiCalculator.canChiOfDay(jdn: jdn, hour: 12)
        let monthStr = CanChiCalculator.canChiOfMonth(lunarYear: lunar.year, lunarMonth: lunar.month)
        let yearStr = CanChiCalculator.canChiOfYear(lunarYear: lunar.year)
        return (dayStr, monthStr, yearStr)
    }

    // MARK: - Solar term

    /// Current solar term (Tiết Khí) for the date.
    public func tietKhi(date: SolarDate) -> String {
        TietKhiCalculator.currentTermName(solarYear: date.year, month: date.month, day: date.day)
    }

    // MARK: - Hoàng Đạo

    /// Whether the day is Hoàng Đạo (lucky) or Hắc Đạo.
    public func isHoangDao(date: SolarDate) -> Bool {
        let jdn = JulianDateConverter.jdnFromGregorian(year: date.year, month: date.month, day: date.day)
        return HoangDaoCalculator.isHoangDaoDay(jdn: jdn, hour: 12)
    }

    /// Good hours (Giờ Hoàng Đạo) for the day.
    public func goodHours(date: SolarDate) -> [String] {
        let jdn = JulianDateConverter.jdnFromGregorian(year: date.year, month: date.month, day: date.day)
        return HoangDaoCalculator.goodHours(jdn: jdn, hour: 12)
    }

    /// Number of days in the given solar month (1–12). For calendar grid.
    public func daysInSolarMonth(year: Int, month: Int) -> Int {
        JulianDateConverter.daysInGregorianMonth(year: year, month: month)
    }

    /// Weekday of the first day of the month: 0 = Monday, 6 = Sunday.
    public func firstWeekdayOfMonth(year: Int, month: Int) -> Int {
        let jdn = JulianDateConverter.jdnFromGregorian(year: year, month: month, day: 1)
        return ((jdn + 1) % 7 + 7) % 7
    }

    // MARK: - Simple evaluation

    /// Good for / avoid suggestions (rule-based).
    public func evaluation(date: SolarDate) -> (goodFor: [String], avoidFor: [String]) {
        let hoangDao = isHoangDao(date: date)
        let term = tietKhi(date: date)
        var goodFor: [String] = []
        var avoidFor: [String] = []
        if hoangDao {
            goodFor.append("wedding")
            goodFor.append("groundbreaking")
            goodFor.append("opening business")
        } else {
            avoidFor.append("wedding")
            avoidFor.append("groundbreaking")
            avoidFor.append("opening business")
        }
        let avoidTerms = ["Đại Hàn", "Tiểu Hàn", "Thu Phân", "Hạ Chí", "Đông Chí"]
        if avoidTerms.contains(term) {
            avoidFor.append("funeral")
            avoidFor.append("travel")
            avoidFor.append("construction")
        } else if hoangDao {
            goodFor.append("travel")
            goodFor.append("construction")
        } else {
            avoidFor.append("travel")
            avoidFor.append("construction")
        }
        return (goodFor, avoidFor)
    }
}
