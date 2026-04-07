//
//  SunLongitudeCalculator.swift
//  LunarCore
//
//  Sun's ecliptic longitude from Julian Day (at noon UT).
//  Used for 24 solar terms (Tiết Khí). Formula: mean longitude + correction.
//

import Foundation

enum SunLongitudeCalculator {

    /// Sun's mean longitude at JD (noon UT). Simple formula for 1900–2100.
    static func sunLongitude(jd: Double) -> Double {
        let n = jd - 2451545.0
        let L = 280.466 + 0.9856474 * n
        return AstronomicalCalculator.norm360(L)
    }

    /// More accurate: mean anomaly and equation of center for ecliptic longitude.
    /// Returns longitude in degrees [0, 360).
    static func sunLongitudeAccurate(jd: Double) -> Double {
        let n = jd - 2451545.0
        let meanLong = AstronomicalCalculator.norm360(280.466 + 0.9856474 * n)
        let meanAnom = AstronomicalCalculator.norm360(357.528 + 0.9856003 * n)
        let rad = AstronomicalCalculator.rad(meanAnom)
        let center = 1.915 * sin(rad) + 0.020 * sin(2 * rad)
        let lambda = meanLong + center
        return AstronomicalCalculator.norm360(lambda)
    }
}
