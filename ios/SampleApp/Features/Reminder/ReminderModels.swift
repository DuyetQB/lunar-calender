//
//  ReminderModels.swift
//  Data model (maps to reminder schema from product spec).
//

import Foundation

/// `lunar_fixed` = built-in patterns (mùng 1, rằm); `user_event` = giỗ / personal lunar events.
enum ReminderType: String, Codable, CaseIterable, Identifiable {
    case lunar_fixed
    case user_event
    var id: String { rawValue }
}

enum ReminderRepeat: String, Codable, CaseIterable, Identifiable {
    case monthly
    case yearly
    var id: String { rawValue }
}

struct Reminder: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var type: ReminderType
    /// For `lunar_fixed` defaults: day in lunar month (1 = mùng 1, 15 = rằm). For `user_event`: required.
    var lunarDay: Int?
    /// If `nil` with `monthly` + `lunar_fixed`, every lunar month’s that day in the solar year window.
    var lunarMonth: Int?
    /// Optional ISO8601 date string (yyyy-MM-dd) for one-shot or anchor; used when set for `user_event`.
    var solarDate: String?
    var `repeat`: ReminderRepeat
    var notifyBeforeMinutes: Int?
    /// When scheduling a specific lunar month that can be leap, set true for the leap month instance.
    var isLeapMonth: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        type: ReminderType,
        lunarDay: Int? = nil,
        lunarMonth: Int? = nil,
        solarDate: String? = nil,
        repeat: ReminderRepeat,
        notifyBeforeMinutes: Int? = nil,
        isLeapMonth: Bool = false
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.lunarDay = lunarDay
        self.lunarMonth = lunarMonth
        self.solarDate = solarDate
        self.repeat = `repeat`
        self.notifyBeforeMinutes = notifyBeforeMinutes
        self.isLeapMonth = isLeapMonth
    }

    /// Built-in: every lunar month’s first day (mùng 1).
    static var defaultMung1: Reminder {
        Reminder(
            id: "builtin.mung1",
            title: "Mùng 1 âm lịch",
            type: .lunar_fixed,
            lunarDay: 1,
            lunarMonth: nil,
            repeat: .monthly,
            notifyBeforeMinutes: 0
        )
    }

    /// Built-in: every lunar month’s 15th (rằm).
    static var defaultRam: Reminder {
        Reminder(
            id: "builtin.ram",
            title: "Rằm (15 âm lịch)",
            type: .lunar_fixed,
            lunarDay: 15,
            lunarMonth: nil,
            repeat: .monthly,
            notifyBeforeMinutes: 0
        )
    }
}
