//
//  Models.swift
//  LunarCore
//
//  Vietnamese Lunar Calendar — Solar and Lunar date types.
//  All dates in GMT+7 (Vietnam). No UIKit dependency.
//

import Foundation

// MARK: - Solar Date (Gregorian)

/// Gregorian calendar date in Vietnam timezone (GMT+7).
/// Year range supported: 1900–2100.
public struct SolarDate: Sendable, Equatable, Hashable, Identifiable {
    public var year: Int
    public var month: Int   // 1–12
    public var day: Int     // 1–31

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// Hour in 0–23 (GMT+7). Used for day-boundary (Can Chi day starts at 23:00).
    public func hourForCanChi() -> Int {
        12
    }

    public var id: String { "\(year)-\(month)-\(day)" }
}

// MARK: - Lunar Date

/// Vietnamese lunar calendar date.
/// Month 1 is the month containing Lập Xuân (Beginning of Spring).
public struct LunarDate: Sendable, Equatable, Hashable, Codable {
    public var year: Int
    public var month: Int   // 1–12 (sometimes 1–13 with leap)
    public var day: Int     // 1–29 or 1–30
    /// True if this day is in the leap month (tháng nhuận).
    public var isLeapMonth: Bool

    public init(year: Int, month: Int, day: Int, isLeapMonth: Bool = false) {
        self.year = year
        self.month = month
        self.day = day
        self.isLeapMonth = isLeapMonth
    }
}
