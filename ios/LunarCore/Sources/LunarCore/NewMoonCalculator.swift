//
//  NewMoonCalculator.swift
//  LunarCore
//
//  Mean new moon calculation. Returns JDN of new moon for a given lunation index.
//  Lunation 0 = reference new moon (2000-01-06).
//

import Foundation

enum NewMoonCalculator {

    /// Lunation index such that `newMoonJDN(k) <= jdn < newMoonJDN(k + 1)` (mean new moons).
    ///
    /// The estimate `floor((jdn - ref) / synodicMonth)` can disagree with `floor(ref + k * synodicMonth)`,
    /// which breaks `jdn - newMoonJDN(k) + 1` and can confuse any logic that maps `k` back to a calendar year.
    static func lunation(beforeOrAt jdn: Int) -> Int {
        let ref = Double(AstronomicalCalculator.newMoonRefJDN)
        let month = AstronomicalCalculator.synodicMonth
        let n = (Double(jdn) - ref) / month
        var k = Int(floor(n))
        while newMoonJDN(lunation: k) > jdn {
            k -= 1
        }
        while newMoonJDN(lunation: k + 1) <= jdn {
            k += 1
        }
        return k
    }

    /// JDN (integer, 0h UT) of the day containing the mean new moon for lunation `k`.
    /// Uses mean formula; no periodic terms (deterministic, fast).
    static func newMoonJDN(lunation k: Int) -> Int {
        let jd = AstronomicalCalculator.newMoonRefJD + Double(k) * AstronomicalCalculator.synodicMonth
        return Int(floor(jd))
    }

    /// Fractional JD of mean new moon (for ordering vs solar terms).
    static func newMoonJD(lunation k: Int) -> Double {
        AstronomicalCalculator.newMoonRefJD + Double(k) * AstronomicalCalculator.synodicMonth
    }
}
