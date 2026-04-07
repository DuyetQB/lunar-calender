//
//  WidgetDataModels.swift
//  Maps spec: WidgetData + ZodiacDaily (+ SunTimes pair for API symmetry).
//

import Foundation

/// Aggregated payload for home-screen widgets (offline).
struct WidgetData: Equatable, Sendable {
    var lunarDate: String
    var solarDate: String
    var goodHours: [String]
    var quote: String
    var zodiacScore: Int?
    var zodiacSummary: String?
    var sunrise: String?
    var sunset: String?
}

/// Lightweight “Tử vi nhẹ” row for a lunar year animal (12 Chi).
struct ZodiacDaily: Equatable, Sendable {
    /// 0 = Tý … 11 = Hợi
    var branchIndex: Int
    var animalName: String
    /// 1…5 (demo heuristic from calendar noise).
    var score: Int
    var summary: String
}

/// Sunrise / sunset strings (local mean solar time from longitude).
struct SunTimes: Equatable, Sendable {
    var sunrise: String
    var sunset: String
}
