//
//  JulianDateConverter.swift
//  LunarCore
//
//  Converts between Gregorian calendar (GMT+7) and Julian Day Number.
//  JDN is at 0h UT; for a Vietnam calendar date we use that date's JDN at 0h UT
//  (the calendar date is interpreted as the same nominal date in Vietnam).
//

import Foundation

enum JulianDateConverter {

    private static let minYear = 1900
    private static let maxYear = 2100

    /// Returns Julian Day Number (integer) for 0h UT of the given Gregorian date.
    /// Date is interpreted as calendar date (valid for GMT+7 display).
    static func jdnFromGregorian(year y: Int, month m: Int, day d: Int) -> Int {
        var yy = y
        var mm = m
        if mm <= 2 {
            yy -= 1
            mm += 12
        }
        let a = yy / 100
        let b = 2 - a + (a / 4)
        let jdn = (1461 * (yy + 4716)) / 4 + (153 * mm - 457) / 5 + d + b - 1524
        return jdn
    }

    /// Returns (year, month, day) in Gregorian for the given JDN (0h UT).
    static func gregorianFromJDN(_ jdn: Int) -> (year: Int, month: Int, day: Int) {
        let a = (4 * jdn + 6884474) / 146097
        let b = jdn + (3 * a) / 4 - (146097 * a + 3) / 4
        let c = (4 * b + 3) / 1461
        let d = b - (1461 * c) / 4
        var e = (5 * d + 2) / 153
        let day = d - (153 * e + 2) / 5 + 1
        var month = e + 2
        var year = c - 4716 + (e / 10)
        if month > 12 {
            month -= 12
            year += 1
        }
        return (year, month, day)
    }

    /// JDN for noon UT of the given date (for solar longitude etc.). Returns Double.
    static func jdNoon(year: Int, month: Int, day: Int) -> Double {
        Double(jdnFromGregorian(year: year, month: month, day: day)) + 0.5
    }

    static func isValidSolar(year: Int, month: Int, day: Int) -> Bool {
        guard year >= minYear, year <= maxYear else { return false }
        guard month >= 1, month <= 12 else { return false }
        let daysInMonth = daysInGregorianMonth(year: year, month: month)
        return day >= 1 && day <= daysInMonth
    }

    static func daysInGregorianMonth(year: Int, month: Int) -> Int {
        let d: [Int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        var n = d[month - 1]
        if month == 2 && isLeapYear(year) { n += 1 }
        return n
    }

    static func isLeapYear(_ y: Int) -> Bool {
        (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
    }
}
