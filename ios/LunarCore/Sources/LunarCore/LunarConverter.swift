//
//  LunarConverter.swift
//  LunarCore
//
//  Solar <-> Lunar conversion using new moons and principal solar terms.
//  Lunar month 1 = month containing Lập Xuân (315°).
//

import Foundation

enum LunarConverter {

    /// Solar date -> Lunar date.
    static func solarToLunar(_ solar: SolarDate) -> LunarDate {
        guard JulianDateConverter.isValidSolar(year: solar.year, month: solar.month, day: solar.day) else {
            return LunarDate(year: solar.year, month: 1, day: 1, isLeapMonth: false)
        }
        let jdn = JulianDateConverter.jdnFromGregorian(year: solar.year, month: solar.month, day: solar.day)
        let k = NewMoonCalculator.lunation(beforeOrAt: jdn)
        let newMoonDay = NewMoonCalculator.newMoonJDN(lunation: k)
        let lunarDay = max(1, jdn - newMoonDay + 1)
        let (ly, lm, isLeap) = lunarYearMonth(lunation: k, jdn: jdn, solarYear: solar.year)
        return LunarDate(year: ly, month: lm, day: lunarDay, isLeapMonth: isLeap)
    }

    /// Lunar date -> Solar date (first occurrence; no disambiguation for leap).
    static func lunarToSolar(_ lunar: LunarDate) -> SolarDate {
        let k = lunationForLunarYear(lunar.year, month: lunar.month, isLeap: lunar.isLeapMonth)
        let newMoonDay = NewMoonCalculator.newMoonJDN(lunation: k)
        let jdn = newMoonDay + lunar.day - 1
        let (y, m, d) = JulianDateConverter.gregorianFromJDN(jdn)
        return SolarDate(year: y, month: m, day: d)
    }

    /// Lunation index that starts lunar month `month` of lunar `year` (isLeap for leap month).
    private static func lunationForLunarYear(_ lunarYear: Int, month: Int, isLeap: Bool) -> Int {
        let k0 = lunationOfMonth1(lunarYear: lunarYear)
        let principalJDs = (0..<12).map { TietKhiCalculator.principalTermJD(solarYear: lunarYear, termIndex: $0) }
        var nextNormalMonth = 1
        for i in 0..<13 {
            let nm1 = NewMoonCalculator.newMoonJD(lunation: k0 + i)
            let nm2 = NewMoonCalculator.newMoonJD(lunation: k0 + i + 1)
            let termsIn = principalJDs.filter { $0 >= nm1 && $0 < nm2 }
            if termsIn.isEmpty {
                if isLeap && nextNormalMonth == month { return k0 + i }
            } else {
                let normalNum = principalJDs.firstIndex(where: { $0 >= nm1 && $0 < nm2 })! + 1
                if !isLeap && normalNum == month { return k0 + i }
                nextNormalMonth = normalNum + 1
            }
        }
        return k0 + max(0, month - 1)
    }

    /// Lunation index that starts lunar month 1 of given lunar year (month containing Lập Xuân).
    private static func lunationOfMonth1(lunarYear: Int) -> Int {
        let jd315 = TietKhiCalculator.jdForLongitude(315.0, near: JulianDateConverter.jdNoon(year: lunarYear, month: 2, day: 5))
        return NewMoonCalculator.lunation(beforeOrAt: Int(floor(jd315)))
    }

    /// For lunation k, return (lunar year, lunar month 1..12, isLeapMonth).
    ///
    /// Anchor the search on **`solarYear`** (the Gregorian year of the solar date), not
    /// `gregorianFromJDN(jdn).year`. Rounding / edge cases in JDN ↔ Gregorian can otherwise produce
    /// impossible years (e.g. large negative values) while day/month still look plausible.
    private static func lunarYearMonth(lunation k: Int, jdn: Int, solarYear: Int) -> (year: Int, month: Int, isLeap: Bool) {
        let yMin = LunarEngine.supportedYearRange.lowerBound
        let yMax = LunarEngine.supportedYearRange.upperBound
        let anchor = min(max(solarYear, yMin), yMax)
        for y in [anchor - 1, anchor, anchor + 1] {
            guard y >= yMin, y <= yMax else { continue }
            let k0 = lunationOfMonth1(lunarYear: y)
            if k < k0 { continue }
            let principalJDs = (0..<12).map { TietKhiCalculator.principalTermJD(solarYear: y, termIndex: $0) }
            var nextNormalMonth = 1
            for i in 0..<13 {
                let nm1 = NewMoonCalculator.newMoonJD(lunation: k0 + i)
                let nm2 = NewMoonCalculator.newMoonJD(lunation: k0 + i + 1)
                let termsIn = principalJDs.filter { $0 >= nm1 && $0 < nm2 }
                if k0 + i == k {
                    if termsIn.isEmpty {
                        return (y, nextNormalMonth, true)
                    } else {
                        let termIdx = principalJDs.firstIndex { $0 >= nm1 && $0 < nm2 }!
                        return (y, termIdx + 1, false)
                    }
                }
                if !termsIn.isEmpty {
                    nextNormalMonth = principalJDs.firstIndex { $0 >= nm1 && $0 < nm2 }! + 2
                }
            }
        }
        return (anchor, 1, false)
    }
}
