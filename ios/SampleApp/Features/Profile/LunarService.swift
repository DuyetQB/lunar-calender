//
//  LunarService.swift
//  Core lunar helpers for year/stem/branch calculations.
//

import Foundation

enum LunarService {
    static var vietnamCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return c
    }

    /// Required formula: (year + 6) % 10
    static func getHeavenlyStem(year: Int) -> HeavenlyStem {
        HeavenlyStem(rawValue: ((year + 6) % 10 + 10) % 10) ?? .giap
    }

    /// Existing Can-Chi formula used across this app.
    static func getEarthlyBranch(year: Int) -> EarthlyBranch {
        EarthlyBranch(rawValue: ((year + 8) % 12 + 12) % 12) ?? .ty
    }

    static func getCanChi(year: Int) -> CanChi {
        CanChi(stem: getHeavenlyStem(year: year), branch: getEarthlyBranch(year: year))
    }

    // MARK: - Accurate Solar -> Lunar (Vietnam GMT+7)

    /// Accurate Vietnamese lunar conversion (astronomical method, leap-month aware, offline).
    static func convertSolarToLunar(date: Date) -> LunarDate {
        let c = vietnamCalendar
        let dd = c.component(.day, from: date)
        let mm = c.component(.month, from: date)
        let yy = c.component(.year, from: date)
        let tz = 7.0

        let dayNumber = jdFromDate(dd, mm, yy)
        let k = Int(floor((Double(dayNumber) - 2415021.076998695) / 29.530588853))
        var monthStart = getNewMoonDay(k + 1, timeZone: tz)
        if monthStart > dayNumber {
            monthStart = getNewMoonDay(k, timeZone: tz)
        }

        var a11 = getLunarMonth11(yy, timeZone: tz)
        var b11 = a11
        var lunarYear: Int
        if a11 >= monthStart {
            lunarYear = yy
            a11 = getLunarMonth11(yy - 1, timeZone: tz)
        } else {
            lunarYear = yy + 1
            b11 = getLunarMonth11(yy + 1, timeZone: tz)
        }

        let lunarDay = dayNumber - monthStart + 1
        let diff = Int(floor(Double(monthStart - a11) / 29.0))
        var lunarLeap = false
        var lunarMonth = diff + 11

        if b11 - a11 > 365 {
            let leapMonthDiff = getLeapMonthOffset(a11, timeZone: tz)
            if diff >= leapMonthDiff {
                lunarMonth = diff + 10
                if diff == leapMonthDiff {
                    lunarLeap = true
                }
            }
        }
        if lunarMonth > 12 { lunarMonth -= 12 }
        if lunarMonth >= 11, diff < 4 { lunarYear -= 1 }

        let out = LunarDate(year: lunarYear, month: lunarMonth, day: lunarDay, isLeapMonth: lunarLeap)
        print("[LunarService] solar=\(dd)/\(mm)/\(yy) -> lunar=\(out.day)/\(out.month)/\(out.year) leap=\(out.isLeapMonth)")
        return out
    }

    /// Edge-case hook:
    /// If a date is before Lunar New Year, the lunar year should be previous year.
    /// This is intentionally a mock boundary for now and can be replaced later by accurate LNY conversion.
    static func adjustYearForLunar(date: Date) -> Int {
        let c = vietnamCalendar
        let y = c.component(.year, from: date)
        // Mock: treat Feb 4 as lunar new year boundary.
        let boundary = c.date(from: DateComponents(year: y, month: 2, day: 4)) ?? date
        return date < boundary ? (y - 1) : y
    }

    // MARK: - Validation tests

    static func runValidationTests() {
        func mk(_ d: Int, _ m: Int, _ y: Int) -> Date {
            vietnamCalendar.date(from: DateComponents(year: y, month: m, day: d)) ?? Date()
        }
        let a = convertSolarToLunar(date: mk(1, 8, 2002))
        assert(a.day == 23 && a.month == 6 && a.year == 2002, "01/08/2002 should be 23/06/2002")

        let b = convertSolarToLunar(date: mk(29, 4, 2001))
        assert(b.day == 7 && b.month == 4 && b.year == 2001, "29/04/2001 should be 07/04/2001")

        let c = convertSolarToLunar(date: mk(1, 1, 2024))
        assert(c.day == 20 && c.month == 11 && c.year == 2023, "01/01/2024 should be 20/11/2023")
    }

    // MARK: - Astronomical helpers (Ho Ngoc Duc algorithm)

    private static func jdFromDate(_ dd: Int, _ mm: Int, _ yy: Int) -> Int {
        let a = (14 - mm) / 12
        let y = yy + 4800 - a
        let m = mm + 12 * a - 3
        var jd = dd + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
        if jd < 2299161 {
            jd = dd + (153 * m + 2) / 5 + 365 * y + y / 4 - 32083
        }
        return jd
    }

    private static func getNewMoonDay(_ k: Int, timeZone: Double) -> Int {
        let T = Double(k) / 1236.85
        let T2 = T * T
        let T3 = T2 * T
        let dr = Double.pi / 180

        var jd1 = 2415020.75933 + 29.53058868 * Double(k) + 0.0001178 * T2 - 0.000000155 * T3
        jd1 += 0.00033 * sin((166.56 + 132.87 * T - 0.009173 * T2) * dr)

        let m = 359.2242 + 29.10535608 * Double(k) - 0.0000333 * T2 - 0.00000347 * T3
        let mpr = 306.0253 + 385.81691806 * Double(k) + 0.0107306 * T2 + 0.00001236 * T3
        let f = 21.2964 + 390.67050646 * Double(k) - 0.0016528 * T2 - 0.00000239 * T3

        var c1 = (0.1734 - 0.000393 * T) * sin(m * dr) + 0.0021 * sin(2 * dr * m)
        c1 -= 0.4068 * sin(mpr * dr) + 0.0161 * sin(dr * 2 * mpr)
        c1 -= 0.0004 * sin(dr * 3 * mpr)
        c1 += 0.0104 * sin(dr * 2 * f) - 0.0051 * sin(dr * (m + mpr))
        c1 -= 0.0074 * sin(dr * (m - mpr)) + 0.0004 * sin(dr * (2 * f + m))
        c1 -= 0.0004 * sin(dr * (2 * f - m)) - 0.0006 * sin(dr * (2 * f + mpr))
        c1 += 0.0010 * sin(dr * (2 * f - mpr)) + 0.0005 * sin(dr * (2 * mpr + m))

        let deltat: Double = T < -11
            ? 0.001 + 0.000839 * T + 0.0002261 * T2 - 0.00000845 * T3 - 0.000000081 * T * T3
            : -0.000278 + 0.000265 * T + 0.000262 * T2

        let jdNew = jd1 + c1 - deltat
        return Int(floor(jdNew + 0.5 + timeZone / 24))
    }

    private static func getSunLongitude(_ jdn: Int, timeZone: Double) -> Int {
        let T = (Double(jdn) - 2451545.5 - timeZone / 24) / 36525
        let T2 = T * T
        let dr = Double.pi / 180
        let m = 357.52910 + 35999.05030 * T - 0.0001559 * T2 - 0.00000048 * T * T2
        let l0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2
        var dl = (1.914600 - 0.004817 * T - 0.000014 * T2) * sin(dr * m)
        dl += (0.019993 - 0.000101 * T) * sin(dr * 2 * m) + 0.000290 * sin(dr * 3 * m)
        var l = l0 + dl
        l = l * dr
        l = l - Double.pi * 2 * floor(l / (Double.pi * 2))
        return Int(floor(l / Double.pi * 6))
    }

    private static func getLunarMonth11(_ yy: Int, timeZone: Double) -> Int {
        let off = jdFromDate(31, 12, yy) - 2415021
        let k = Int(floor(Double(off) / 29.530588853))
        var nm = getNewMoonDay(k, timeZone: timeZone)
        let sunLong = getSunLongitude(nm, timeZone: timeZone)
        if sunLong >= 9 {
            nm = getNewMoonDay(k - 1, timeZone: timeZone)
        }
        return nm
    }

    private static func getLeapMonthOffset(_ a11: Int, timeZone: Double) -> Int {
        let k = Int(floor(Double(a11 - 2415021) / 29.530588853 + 0.5))
        var i = 1
        var arc = getSunLongitude(getNewMoonDay(k + i, timeZone: timeZone), timeZone: timeZone)
        var last = arc
        repeat {
            i += 1
            last = arc
            arc = getSunLongitude(getNewMoonDay(k + i, timeZone: timeZone), timeZone: timeZone)
        } while arc != last && i < 14
        return i - 1
    }
}
