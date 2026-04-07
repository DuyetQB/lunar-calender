//
//  ReminderStore.swift
//  Maps spec: useReminder.ts — load/save, CRUD, toggle, reschedule (ObservableObject for SwiftUI).
//
//  TS path map (this target is Swift):
//  - features/reminder/reminderService.ts  → ReminderService.swift
//  - features/reminder/lunarConverter.ts → LunarReminderConverter.swift (+ LunarCore)
//  - features/reminder/useReminder.ts      → ReminderStore.swift
//
//  Example (giỗ — yearly lunar 3/15, non-leap month):
//  ```swift
//  let gio = Reminder(
//      title: "Giỗ ông",
//      type: .user_event,
//      lunarDay: 15,
//      lunarMonth: 3,
//      repeat: .yearly,
//      notifyBeforeMinutes: 60,
//      isLeapMonth: false
//  )
//  await store.add(gio)
//  await store.rescheduleAllForCurrentYear()
//  ```
//  Example — convert lunar to solar `Date` (Vietnam 08:00):
//  `LunarReminderConverter.convertLunarToSolar(lunarDay: 1, lunarMonth: 1, year: 2026)`
//

import Foundation
import SwiftUI

@MainActor
final class ReminderStore: ObservableObject {
    @Published private(set) var reminders: [Reminder] = []

    private let service: ReminderService

    init(service: ReminderService = ReminderService()) {
        self.service = service
        reminders = ReminderStorage.loadEnsuringDefaults()
    }

    static func currentVietnamSolarYear() -> Int {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = LunarReminderConverter.vietnamTimeZone
        return cal.component(.year, from: Date())
    }

    func reloadFromDisk() {
        reminders = ReminderStorage.loadEnsuringDefaults()
    }

    private func persist() {
        ReminderStorage.save(reminders)
    }

    func add(_ reminder: Reminder) async {
        reminders.append(reminder)
        persist()
        if ReminderService.isReminderEnabled(reminder) {
            await service.scheduleReminder(reminder, solarYear: Self.currentVietnamSolarYear())
        }
    }

    func update(_ reminder: Reminder) async {
        guard let i = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }
        await service.cancelReminder(reminder)
        reminders[i] = reminder
        persist()
        if ReminderService.isReminderEnabled(reminder) {
            await service.scheduleReminder(reminder, solarYear: Self.currentVietnamSolarYear())
        }
    }

    func remove(_ reminder: Reminder) async {
        reminders.removeAll { $0.id == reminder.id }
        persist()
        await service.cancelReminder(reminder)
    }

    func setEnabled(_ reminder: Reminder, on: Bool) async {
        ReminderService.setReminderEnabled(reminder, on: on)
        if on {
            _ = await service.requestNotificationPermission()
            await service.scheduleReminder(reminder, solarYear: Self.currentVietnamSolarYear())
        } else {
            await service.cancelReminder(reminder)
        }
        objectWillChange.send()
    }

    func isOn(_ reminder: Reminder) -> Bool {
        ReminderService.isReminderEnabled(reminder)
    }

    /// Drops pending notifications for `year` and re-adds from saved reminders (offline).
    func rescheduleAllForYear(_ solarYear: Int) async {
        await service.rescheduleAllRemindersForYear(solarYear, reminders: reminders)
    }

    func rescheduleAllForCurrentYear() async {
        await rescheduleAllForYear(Self.currentVietnamSolarYear())
    }
}
