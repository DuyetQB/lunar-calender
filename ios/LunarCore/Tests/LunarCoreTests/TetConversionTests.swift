//
//  TetConversionTests.swift
//  LunarCoreTests
//
//  Tet (Vietnamese New Year) is lunar 1/1. Verify solar <-> lunar for known Tet dates.
//

import Testing
import LunarCore

@Suite("Tet conversion")
struct TetConversionTests {

    @Test("Tet 2024: lunar 1/1 -> solar")
    func tet2024() {
        let engine = LunarEngine()
        let lunar = LunarDate(year: 2024, month: 1, day: 1, isLeapMonth: false)
        let solar = engine.lunarToSolar(date: lunar)
        #expect(solar.year == 2024)
        #expect(solar.month == 2)
        #expect(solar.day == 10)
    }

    @Test("Tet 2025: lunar 1/1")
    func tet2025() {
        let engine = LunarEngine()
        let lunar = LunarDate(year: 2025, month: 1, day: 1, isLeapMonth: false)
        let solar = engine.lunarToSolar(date: lunar)
        #expect(solar.year == 2025)
        #expect(solar.month == 1)
        #expect(solar.day == 29)
    }

    @Test("Tet 2023: lunar 1/1")
    func tet2023() {
        let engine = LunarEngine()
        let lunar = LunarDate(year: 2023, month: 1, day: 1, isLeapMonth: false)
        let solar = engine.lunarToSolar(date: lunar)
        #expect(solar.year == 2023)
        #expect(solar.month == 1)
        #expect(solar.day == 22)
    }

    @Test("Solar to lunar round-trip on Tet 2024")
    func roundTripTet2024() {
        let engine = LunarEngine()
        let solar = SolarDate(year: 2024, month: 2, day: 10)
        let lunar = engine.solarToLunar(date: solar)
        #expect(lunar.year == 2024)
        #expect(lunar.month == 1)
        #expect(lunar.day == 1)
        let back = engine.lunarToSolar(date: lunar)
        #expect(back.year == solar.year && back.month == solar.month && back.day == solar.day)
    }
}
