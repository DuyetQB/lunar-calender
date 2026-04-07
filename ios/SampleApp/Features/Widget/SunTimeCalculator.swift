//
//  SunTimeCalculator.swift
//  Simple solar position / sunrise–sunset (offline). Uses local mean time from longitude.
//

import Foundation

enum SunTimeCalculator {
    private static let rad = Double.pi / 180

    /// Approximate sunrise & sunset for the given **calendar** day (`year`/`month`/`day`).
    /// Times are formatted as `HH:mm` in a time zone with offset `longitude × 4` minutes (local mean time).
    /// Returns `nil` if the sun does not rise or set (polar cases).
    static func sunTimes(latitude: Double, longitude: Double, year: Int, month: Int, day: Int) -> SunTimes? {
        let latR = latitude * rad
        let n = dayOfYear(year: year, month: month, day: day)
        let decl = declinationRadians(dayOfYear: n)
        let cosH = (cos(zenithRad) - sin(latR) * sin(decl)) / (cos(latR) * cos(decl))
        guard cosH >= -1, cosH <= 1 else { return nil }
        let h = acos(cosH)
        let hHours = h * 180 / .pi / 15
        let eot = equationOfTimeHours(dayOfYear: n)
        let solarNoon = 12.0 - longitude / 15.0 - eot
        let rise = solarNoon - hHours
        let set = solarNoon + hHours
        let offsetSec = Int(round(longitude * 240))
        guard let tz = TimeZone(secondsFromGMT: offsetSec) else { return nil }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz
        guard let base = cal.date(from: DateComponents(year: year, month: month, day: day, hour: 0, minute: 0)) else { return nil }
        guard let riseDate = cal.date(byAdding: .second, value: Int(rise * 3600), to: base),
              let setDate = cal.date(byAdding: .second, value: Int(set * 3600), to: base) else { return nil }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.timeZone = tz
        fmt.dateFormat = "HH:mm"
        return SunTimes(sunrise: fmt.string(from: riseDate), sunset: fmt.string(from: setDate))
    }

    private static var zenithRad: Double { (90.833) * rad }

    private static func declinationRadians(dayOfYear n: Int) -> Double {
        asin(sin(23.45 * rad) * sin(2 * Double.pi * Double(284 + n) / 365))
    }

    /// Equation of time in hours (approximation).
    private static func equationOfTimeHours(dayOfYear n: Int) -> Double {
        let b = 2 * Double.pi * (Double(n) - 81) / 364
        let minutes = 9.87 * sin(2 * b) - 7.53 * cos(b) - 1.5 * sin(b)
        return minutes / 60
    }

    private static func dayOfYear(year: Int, month: Int, day: Int) -> Int {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        guard let d = cal.date(from: DateComponents(year: year, month: month, day: day)) else { return 1 }
        return cal.ordinality(of: .day, in: .year, for: d) ?? 1
    }
}
