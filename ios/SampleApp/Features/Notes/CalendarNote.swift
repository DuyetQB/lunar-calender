import Foundation

struct CalendarNote: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String

    var solarDate: Date
    var lunarDate: LunarDate?

    var hasReminder: Bool
    var reminderDate: Date?

    var isLunarRepeat: Bool

    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        solarDate: Date,
        lunarDate: LunarDate? = nil,
        hasReminder: Bool = false,
        reminderDate: Date? = nil,
        isLunarRepeat: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.solarDate = solarDate
        self.lunarDate = lunarDate
        self.hasReminder = hasReminder
        self.reminderDate = reminderDate
        self.isLunarRepeat = isLunarRepeat
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case solarDate
        case lunarDay
        case lunarMonth
        case lunarYear
        case lunarIsLeapMonth
        case hasReminder
        case reminderDate
        case isLunarRepeat
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        solarDate = try container.decode(Date.self, forKey: .solarDate)
        hasReminder = try container.decode(Bool.self, forKey: .hasReminder)
        reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
        isLunarRepeat = try container.decode(Bool.self, forKey: .isLunarRepeat)
        createdAt = try container.decode(Date.self, forKey: .createdAt)

        if let day = try container.decodeIfPresent(Int.self, forKey: .lunarDay),
           let month = try container.decodeIfPresent(Int.self, forKey: .lunarMonth),
           let year = try container.decodeIfPresent(Int.self, forKey: .lunarYear) {
            let isLeap = try container.decodeIfPresent(Bool.self, forKey: .lunarIsLeapMonth) ?? false
            lunarDate = LunarDate(year: year, month: month, day: day, isLeapMonth: isLeap)
        } else {
            lunarDate = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(solarDate, forKey: .solarDate)
        try container.encode(hasReminder, forKey: .hasReminder)
        try container.encodeIfPresent(reminderDate, forKey: .reminderDate)
        try container.encode(isLunarRepeat, forKey: .isLunarRepeat)
        try container.encode(createdAt, forKey: .createdAt)

        if let lunarDate {
            try container.encode(lunarDate.day, forKey: .lunarDay)
            try container.encode(lunarDate.month, forKey: .lunarMonth)
            try container.encode(lunarDate.year, forKey: .lunarYear)
            try container.encode(lunarDate.isLeapMonth, forKey: .lunarIsLeapMonth)
        }
    }
}
