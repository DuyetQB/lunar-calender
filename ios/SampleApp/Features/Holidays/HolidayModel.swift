//
//  HolidayModel.swift
//  Vietnamese traditional holidays — core types (offline, Codable).
//

import Foundation

enum HolidayCategory: String, Codable, CaseIterable, Identifiable, Hashable {
    case traditional
    case spiritual
    case national

    var id: String { rawValue }
}

struct Holiday: Identifiable, Codable, Hashable {
    let id: UUID
    /// Display name (Vietnamese).
    let name: String
    /// Anchor for fixed solar holidays (month/day in Vietnam; year ignored for templates).
    let solarDate: Date?
    let lunarDay: Int?
    let lunarMonth: Int?
    let isLunar: Bool
    let shortDescription: String
    let meaning: String
    let activities: [String]
    let history: String
    let funFact: String
    let category: HolidayCategory
    let icon: String

    init(
        id: UUID,
        name: String,
        solarDate: Date?,
        lunarDay: Int?,
        lunarMonth: Int?,
        isLunar: Bool,
        shortDescription: String,
        meaning: String,
        activities: [String],
        history: String,
        funFact: String,
        category: HolidayCategory,
        icon: String
    ) {
        self.id = id
        self.name = name
        self.solarDate = solarDate
        self.lunarDay = lunarDay
        self.lunarMonth = lunarMonth
        self.isLunar = isLunar
        self.shortDescription = shortDescription
        self.meaning = meaning
        self.activities = activities
        self.history = history
        self.funFact = funFact
        self.category = category
        self.icon = icon
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, solarDate, lunarDay, lunarMonth, isLunar
        case shortDescription, meaning, activities, history, funFact, category, icon
        case lunarDate
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        solarDate = try c.decodeIfPresent(Date.self, forKey: .solarDate)
        isLunar = try c.decode(Bool.self, forKey: .isLunar)
        shortDescription = try c.decodeIfPresent(String.self, forKey: .shortDescription) ?? ""
        meaning = try c.decodeIfPresent(String.self, forKey: .meaning) ?? ""
        activities = try c.decodeIfPresent([String].self, forKey: .activities) ?? []
        history = try c.decodeIfPresent(String.self, forKey: .history) ?? ""
        funFact = try c.decodeIfPresent(String.self, forKey: .funFact) ?? ""
        category = try c.decode(HolidayCategory.self, forKey: .category)
        icon = try c.decode(String.self, forKey: .icon)

        if let ld = try c.decodeIfPresent(LunarDate.self, forKey: .lunarDate) {
            lunarDay = ld.day
            lunarMonth = ld.month
        } else {
            lunarDay = try c.decodeIfPresent(Int.self, forKey: .lunarDay)
            lunarMonth = try c.decodeIfPresent(Int.self, forKey: .lunarMonth)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encodeIfPresent(solarDate, forKey: .solarDate)
        try c.encodeIfPresent(lunarDay, forKey: .lunarDay)
        try c.encodeIfPresent(lunarMonth, forKey: .lunarMonth)
        try c.encode(isLunar, forKey: .isLunar)
        try c.encode(shortDescription, forKey: .shortDescription)
        try c.encode(meaning, forKey: .meaning)
        try c.encode(activities, forKey: .activities)
        try c.encode(history, forKey: .history)
        try c.encode(funFact, forKey: .funFact)
        try c.encode(category, forKey: .category)
        try c.encode(icon, forKey: .icon)
    }
}

enum HolidayShareText {
    static func plain(holiday: Holiday) -> String {
        let footer = NSLocalizedString("holiday_share_footer", bundle: .main, comment: "")
        return "\(holiday.name)\n\n\(holiday.shortDescription)\n\n\(holiday.meaning)\n\n—\n\(footer)"
    }

    static func deep(holiday: Holiday) -> String {
        let histTitle = NSLocalizedString("holiday_detail_deep_history", bundle: .main, comment: "")
        let ffTitle = NSLocalizedString("holiday_fun_fact_heading", bundle: .main, comment: "")
        return plain(holiday: holiday) + "\n\n\(histTitle)\n\(holiday.history)\n\n\(ffTitle)\n\(holiday.funFact)"
    }
}
