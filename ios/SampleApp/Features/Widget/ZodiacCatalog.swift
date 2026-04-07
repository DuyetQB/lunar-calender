//
//  ZodiacCatalog.swift
//  Loads demo JSON (12 Chi animals); summaries in EN/VI.
//

import Foundation

private struct ZodiacJSONRow: Decodable {
    let branchIndex: Int
    let animalEn: String
    let animalVi: String
    let summariesEn: [String]
    let summariesVi: [String]
}

enum ZodiacCatalog {
    private static var cached: [ZodiacJSONRow]?

    private static func rows() -> [ZodiacJSONRow] {
        if let cached { return cached }
        let decoded: [ZodiacJSONRow]
        if let url = Bundle.main.url(forResource: "zodiacData", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let r = try? JSONDecoder().decode([ZodiacJSONRow].self, from: data) {
            decoded = r.sorted { $0.branchIndex < $1.branchIndex }
        } else {
            decoded = Self.fallbackRows
        }
        cached = decoded
        return decoded
    }

    private static func row(branchIndex: Int) -> ZodiacJSONRow? {
        rows().first { $0.branchIndex == ((branchIndex % 12) + 12) % 12 }
    }

    /// Lunar year branch (same convention as `CanChiCalculator.canChiOfYear`).
    static func yearBranchIndex(lunarYear: Int) -> Int {
        let x = (lunarYear - 4) % 60
        return ((x % 12) + 12) % 12
    }

    static func animalName(branchIndex: Int, languageCode: String) -> String {
        guard let r = row(branchIndex: branchIndex) else { return "—" }
        return languageCode == "vi" ? r.animalVi : r.animalEn
    }

    static func summary(branchIndex: Int, languageCode: String, variantIndex: Int) -> String {
        guard let r = row(branchIndex: branchIndex) else { return "" }
        let list = languageCode == "vi" ? r.summariesVi : r.summariesEn
        guard !list.isEmpty else { return "" }
        let i = ((variantIndex % list.count) + list.count) % list.count
        return list[i]
    }

    private static let fallbackRows: [ZodiacJSONRow] = (0 ..< 12).map { i in
        ZodiacJSONRow(
            branchIndex: i,
            animalEn: "Sign \(i)",
            animalVi: "Cung \(i)",
            summariesEn: ["A calm, balanced day."],
            summariesVi: ["Ngày bình an, cân bằng."]
        )
    }
}
