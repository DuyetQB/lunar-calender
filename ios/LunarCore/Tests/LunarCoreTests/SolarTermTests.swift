//
//  SolarTermTests.swift
//  LunarCoreTests
//
//  Solar term (Tiết Khí) correctness.
//

import Testing
import LunarCore

@Suite("Solar terms")
struct SolarTermTests {

    @Test("Tiết Khí returns non-empty name")
    func tietKhiNonEmpty() {
        let engine = LunarEngine()
        let solar = SolarDate(year: 2024, month: 3, day: 20)
        let term = engine.tietKhi(date: solar)
        #expect(!term.isEmpty)
    }

    @Test("Around Xuân Phân (March ~20)")
    func xuanPhan() {
        let engine = LunarEngine()
        let solar = SolarDate(year: 2024, month: 3, day: 20)
        let term = engine.tietKhi(date: solar)
        #expect(term == "Xuân Phân" || term == "Thanh Minh" || term == "Cốc Vũ")
    }

    @Test("Around Lập Xuân (Feb ~4)")
    func lapXuan() {
        let engine = LunarEngine()
        let solar = SolarDate(year: 2024, month: 2, day: 4)
        let term = engine.tietKhi(date: solar)
        #expect(term == "Lập Xuân" || term == "Vũ Thủy" || term == "Đại Hàn")
    }
}
