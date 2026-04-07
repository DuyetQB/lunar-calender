//
//  TietKhiCalculator.swift
//  LunarCore
//
//  24 Solar Terms (Tiết Khí). Longitude steps of 15° from 0° (Xuân Phân).
//  Principal terms (odd indices) define lunar months: 315°, 345°, 15°, ...
//

import Foundation

enum TietKhiCalculator {

    /// Vietnamese names for 24 terms (longitude 0, 15, 30, ... 345).
    static let termNames: [String] = [
        "Xuân Phân",      // 0
        "Thanh Minh",     // 15
        "Cốc Vũ",         // 30
        "Lập Hạ",         // 45
        "Tiểu Mãn",       // 60
        "Mang Chủng",     // 75
        "Hạ Chí",         // 90
        "Tiểu Thử",       // 105
        "Đại Thử",        // 120
        "Lập Thu",        // 135
        "Xử Thử",         // 150
        "Bạch Lộ",        // 165
        "Thu Phân",       // 180
        "Hàn Lộ",         // 195
        "Sương Giáng",    // 210
        "Lập Đông",       // 225
        "Tiểu Tuyết",     // 240
        "Đại Tuyết",      // 255
        "Đông Chí",       // 270
        "Tiểu Hàn",       // 285
        "Đại Hàn",        // 300
        "Lập Xuân",       // 315
        "Vũ Thủy",        // 330
        "Kinh Trập"       // 345
    ]

    /// Principal term longitudes (every 30°, starting 315°) for lunar month definition.
    static let principalLongitudes: [Double] = [315, 345, 15, 45, 75, 105, 135, 165, 195, 225, 255, 285]

    /// Index of term at given longitude (0–23). Longitude in [0, 360).
    static func termIndex(longitude: Double) -> Int {
        let i = Int(round(longitude / 15.0)) % 24
        return i < 0 ? i + 24 : i
    }

    /// Name of solar term at given longitude.
    static func termName(longitude: Double) -> String {
        termNames[termIndex(longitude: longitude)]
    }

    /// JD (noon UT) when sun reaches given longitude in the approximate year of `jd`.
    /// Binary search refinement.
    static func jdForLongitude(_ targetLong: Double, near jd: Double) -> Double {
        var jdApprox = jd
        for _ in 0..<10 {
            let long = SunLongitudeCalculator.sunLongitudeAccurate(jd: jdApprox)
            var diff = AstronomicalCalculator.norm360(targetLong - long)
            if diff > 180 { diff -= 360 }
            if abs(diff) < 0.01 { return jdApprox }
            jdApprox += diff / 0.9856474
        }
        return jdApprox
    }

    /// Principal term JD for year (solar). Index 0 = 315° (Lập Xuân), 1 = 345°, ... 11 = 285°.
    static func principalTermJD(solarYear y: Int, termIndex i: Int) -> Double {
        let long = principalLongitudes[i]
        let approxJD = JulianDateConverter.jdNoon(year: y, month: 2, day: 5) + Double(i) * 30.4
        return jdForLongitude(long, near: approxJD)
    }

    /// Current term name for a solar date.
    static func currentTermName(solarYear y: Int, month m: Int, day d: Int) -> String {
        let jd = JulianDateConverter.jdNoon(year: y, month: m, day: d)
        let long = SunLongitudeCalculator.sunLongitudeAccurate(jd: jd)
        return termName(longitude: long)
    }
}
