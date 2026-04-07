//
//  CanChiCalculator.swift
//  LunarCore
//
//  Thiên Can (Heavenly Stems) and Địa Chi (Earthly Branches).
//  Day boundary for "day pillar": 23:00 GMT+7 (start of hour Tý).
//

import Foundation

enum CanChiCalculator {

    static let canNames = ["Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ", "Canh", "Tân", "Nhâm", "Quý"]
    static let chiNames = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"]

    /// Can Chi of day. Day boundary at 23:00 GMT+7: after 23:00 use next calendar day for pillar.
    static func canChiOfDay(jdn: Int, hour: Int) -> String {
        let dayJDN = hour >= 23 ? jdn + 1 : jdn
        // Swift `%` can be negative; indices must be 0..<10 and 0..<12.
        let stem = ((dayJDN + 9) % 10 + 10) % 10
        let branch = ((dayJDN + 1) % 12 + 12) % 12
        return canNames[stem] + " " + chiNames[branch]
    }

    /// Can Chi of month (lunar month). Uses standard formula: (year*12 + month + 12) % 60, then stem/branch.
    static func canChiOfMonth(lunarYear: Int, lunarMonth: Int) -> String {
        let raw = lunarYear * 12 + lunarMonth + 12
        let x = ((raw % 60) + 60) % 60
        return canNames[x % 10] + " " + chiNames[x % 12]
    }

    /// Can Chi of year (lunar year).
    static func canChiOfYear(lunarYear: Int) -> String {
        let x = (lunarYear - 4) % 60
        let stem = (x % 10 + 10) % 10
        let branch = (x % 12 + 12) % 12
        return canNames[stem] + " " + chiNames[branch]
    }

    /// Full Can Chi string: "Ngày X, Tháng Y, Năm Z".
    static func fullCanChi(day: String, month: String, year: String) -> String {
        "Ngày \(day), Tháng \(month), Năm \(year)"
    }
}
