//
//  RandomDateTests.swift
//  LunarCoreTests
//
//  Random date conversion and round-trip.
//

import Testing
import LunarCore

@Suite("Random date conversion")
struct RandomDateTests {

    @Test("Round-trip solar -> lunar -> solar")
    func roundTrip() {
        let engine = LunarEngine()
        let dates: [(Int, Int, Int)] = [
            (1990, 5, 15),
            (2000, 12, 31),
            (1985, 3, 8),
            (2010, 7, 20),
        ]
        for (y, m, d) in dates {
            let solar = SolarDate(year: y, month: m, day: d)
            let lunar = engine.solarToLunar(date: solar)
            let back = engine.lunarToSolar(date: lunar)
            #expect(back.year == solar.year)
            #expect(back.month == solar.month)
            #expect(back.day == solar.day)
        }
    }

    @Test("Lunar day in range 1-30")
    func lunarDayRange() {
        let engine = LunarEngine()
        let solar = SolarDate(year: 2020, month: 6, day: 15)
        let lunar = engine.solarToLunar(date: solar)
        #expect(lunar.day >= 1 && lunar.day <= 30)
        #expect(lunar.month >= 1 && lunar.month <= 12)
    }
}
