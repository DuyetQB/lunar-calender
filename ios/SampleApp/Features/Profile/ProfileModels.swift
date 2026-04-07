//
//  ProfileModels.swift
//  Lunar Profile & Compatibility models.
//

import Foundation

/// Profile-specific lunar model to avoid naming conflict with LunarCore's `LunarDate`.
struct ProfileLunarDate: Codable, Equatable, Sendable {
    let day: Int
    let month: Int
    let year: Int
}

enum Element: String, CaseIterable, Codable, Sendable {
    case kim = "Kim"
    case moc = "Mộc"
    case thuy = "Thủy"
    case hoa = "Hỏa"
    case tho = "Thổ"
}

struct ElementProfile: Equatable, Sendable {
    let element: Element
    let description: String
    let personalityTraits: [String]
    let strengths: [String]
    let weaknesses: [String]
    let compatibleWith: [Element]
    let incompatibleWith: [Element]
    let suggestions: [String]
}

struct NapAm: Equatable, Sendable {
    let name: String
    let element: Element
}

struct UserProfile: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var birthDateSolar: Date
    var birthDateLunar: ProfileLunarDate
    var zodiac: String
    var element: Element

    init(
        id: UUID = UUID(),
        name: String,
        birthDateSolar: Date,
        birthDateLunar: ProfileLunarDate,
        zodiac: String,
        element: Element
    ) {
        self.id = id
        self.name = name
        self.birthDateSolar = birthDateSolar
        self.birthDateLunar = birthDateLunar
        self.zodiac = zodiac
        self.element = element
    }

    // Backward-compatible decode for previously stored String elements.
    private enum CodingKeys: String, CodingKey {
        case id, name, birthDateSolar, birthDateLunar, zodiac, element
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        birthDateSolar = try c.decode(Date.self, forKey: .birthDateSolar)
        birthDateLunar = try c.decode(ProfileLunarDate.self, forKey: .birthDateLunar)
        zodiac = try c.decode(String.self, forKey: .zodiac)
        if let typed = try? c.decode(Element.self, forKey: .element) {
            element = typed
        } else if let legacy = try? c.decode(String.self, forKey: .element),
                  let mapped = Element(rawValue: legacy) {
            element = mapped
        } else {
            element = .tho
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(birthDateSolar, forKey: .birthDateSolar)
        try c.encode(birthDateLunar, forKey: .birthDateLunar)
        try c.encode(zodiac, forKey: .zodiac)
        try c.encode(element, forKey: .element)
    }
}

enum HeavenlyStem: Int, CaseIterable, Codable, Sendable {
    case giap = 0, at, binh, dinh, mau, ky, canh, tan, nham, quy
}

enum EarthlyBranch: Int, CaseIterable, Codable, Sendable {
    case ty = 0, suu, dan, mao, thin, ty2, ngo, mui, than, dau, tuat, hoi
}

struct CanChi: Equatable, Sendable {
    let stem: HeavenlyStem
    let branch: EarthlyBranch
}

struct CompatibilityScore: Equatable, Sendable {
    let total: Int
    let stemScore: Int
    let branchScore: Int
    let elementScore: Int
    let summary: String
}

struct CompatibilityResult: Equatable, Sendable {
    let score: Int // 0...100
    let stemScore: Int
    let branchScore: Int
    let elementScore: Int
    let summary: String
    let explanation: String
    let insights: [String]
    let strengths: [String]
    let weaknesses: [String]
}
