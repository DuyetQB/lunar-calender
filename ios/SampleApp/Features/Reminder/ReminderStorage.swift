//
//  ReminderStorage.swift
//  Local persistence (UserDefaults JSON blob — offline, no SQLite dependency).
//

import Foundation

enum ReminderStorage {
    private static let key = "smart_lunar_reminders_v1"

    static func load() -> [Reminder] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Reminder].self, from: data)) ?? []
    }

    static func save(_ reminders: [Reminder]) {
        guard let data = try? JSONEncoder().encode(reminders) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    /// Merge in built-ins if missing (first launch).
    static func loadEnsuringDefaults() -> [Reminder] {
        var list = load()
        let ids = Set(list.map(\.id))
        if !ids.contains(Reminder.defaultMung1.id) {
            list.insert(Reminder.defaultMung1, at: 0)
        }
        if !ids.contains(Reminder.defaultRam.id) {
            list.insert(Reminder.defaultRam, at: min(1, list.count))
        }
        save(list)
        return list
    }
}
