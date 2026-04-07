//
//  PerformanceTests.swift
//  LunarCoreTests
//
//  Conversion must complete under 1ms.
//

import Testing
import LunarCore

@Suite("Performance")
struct PerformanceTests {

    @Test("Solar to lunar under 1ms")
    func solarToLunarPerf() throws {
        let engine = LunarEngine()
        let solar = SolarDate(year: 2024, month: 6, day: 15)
        let iterations = 1000
        let start = ContinuousClock.now
        for _ in 0..<iterations {
            _ = engine.solarToLunar(date: solar)
        }
        let elapsed = ContinuousClock.now - start
        let perCall = elapsed / iterations
        #expect(perCall < .milliseconds(1))
    }

    @Test("Lunar to solar under 1ms")
    func lunarToSolarPerf() throws {
        let engine = LunarEngine()
        let lunar = LunarDate(year: 2024, month: 5, day: 10)
        let iterations = 1000
        let start = ContinuousClock.now
        for _ in 0..<iterations {
            _ = engine.lunarToSolar(date: lunar)
        }
        let elapsed = ContinuousClock.now - start
        let perCall = elapsed / iterations
        #expect(perCall < .milliseconds(1))
    }
}
