//
//  HoangDaoCalculator.swift
//  LunarCore
//
//  Hoàng Đạo / Hắc Đạo. Six "good" two-hour periods per day based on day's Chi.
//  Order of good hours depends on day branch (Tý, Sửu, ...).
//

import Foundation

enum HoangDaoCalculator {

    /// Hour names (12 two-hour periods): Tý 23-1, Sửu 1-3, Dần 3-5, ...
    static let hourNames = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"]

    /// For each day Chi (0..12), the 6 Hoàng Đạo hour indices. Traditional order.
    /// Day Chi index -> indices of good hours (0=23h-1h, 1=1h-3h, ...).
    private static let hoangDaoHours: [[Int]] = [
        [0, 3, 5, 6, 8, 11],   // Tý
        [1, 4, 6, 7, 9, 0],    // Sửu
        [2, 5, 7, 8, 10, 1],   // Dần
        [3, 6, 8, 9, 11, 2],   // Mão
        [4, 7, 9, 10, 0, 3],   // Thìn
        [5, 8, 10, 11, 1, 4],  // Tỵ
        [6, 9, 11, 0, 2, 5],   // Ngọ
        [7, 10, 0, 1, 3, 6],   // Mùi
        [8, 11, 1, 2, 4, 7],   // Thân
        [9, 0, 2, 3, 5, 8],    // Dậu
        [10, 1, 3, 4, 6, 9],   // Tuất
        [11, 2, 4, 5, 7, 10]   // Hợi
    ]

    /// Day Chi index from JDN (day pillar: use 23h boundary). Always in `0..<12` (Swift `%` can be negative).
    static func dayChiIndex(jdn: Int, hour: Int) -> Int {
        let d = hour >= 23 ? jdn + 1 : jdn
        return ((d + 1) % 12 + 12) % 12
    }

    /// Is this solar date a Hoàng Đạo day? (Based on day Chi: some Chis are Hoàng Đạo days.)
    /// Traditional: days with Chi Tý, Sửu, Dần, Mão, Thìn, Tỵ are often considered one set; the rest Hắc Đạo. Actually it's the opposite in many sources: 6 branches are Hoàng Đạo, 6 are Hắc Đạo. Pattern: Tý, Dần, Thìn, Ngọ, Thân, Tuất = 6 Yang = Hoàng Đạo; Sửu, Mão, Tỵ, Mùi, Dậu, Hợi = 6 Yin = Hắc Đạo (or vice versa depending on tradition). Common: Hoàng Đạo days = Tý, Dần, Thìn, Ngọ, Thân, Tuất (even indices 0,2,4,6,8,10).
    static func isHoangDaoDay(jdn: Int, hour: Int) -> Bool {
        let chi = dayChiIndex(jdn: jdn, hour: hour)
        return [0, 2, 4, 6, 8, 10].contains(chi)
    }

    /// Good hours (Giờ Hoàng Đạo) for the day. Returns hour names like "Tý (23h-1h)", "Dần (3h-5h)".
    static func goodHours(jdn: Int, hour: Int) -> [String] {
        let chi = dayChiIndex(jdn: jdn, hour: hour)
        let indices = hoangDaoHours[chi]
        return indices.map { i in
            let start = (i * 2 + 23) % 24
            let end = (start + 2) % 24
            return "\(hourNames[i]) (\(start)h-\(end)h)"
        }
    }
}
