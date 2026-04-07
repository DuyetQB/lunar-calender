//
//  AstronomicalCalculator.swift
//  LunarCore
//
//  Shared constants and helpers for astronomical calculations.
//

import Foundation

enum AstronomicalCalculator {

    /// Synodic month in days (new moon to new moon).
    static let synodicMonth = 29.530588853

    /// Reference: JDN (0h UT) of a known new moon. New moon of 2000-01-06 (approx).
    /// Lunation 0 = 2000-01-06.
    static let newMoonRefJDN = 2451556

    /// JD of reference new moon (at 0h UT of that day, so integer).
    static let newMoonRefJD = Double(newMoonRefJDN)

    /// Degrees to radians.
    static func rad(_ deg: Double) -> Double { deg * .pi / 180.0 }
    static func deg(_ rad: Double) -> Double { rad * 180.0 / .pi }

    /// Normalize angle to [0, 360).
    static func norm360(_ d: Double) -> Double {
        var x = d
        while x >= 360 { x -= 360 }
        while x < 0 { x += 360 }
        return x
    }
}
