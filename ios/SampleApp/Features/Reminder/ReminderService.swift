//
//  ReminderService.swift
//  Maps spec: reminderService.ts — schedule / reschedule using LunarReminderConverter + notification port.
//

import Foundation

final class ReminderService {
    private let engine = LunarEngine()
    private let notifier: ReminderNotificationScheduling

    /// Default hour (Vietnam) for ritual reminders.
    private let defaultHour = 8
    private let defaultMinute = 0

    init(notifier: ReminderNotificationScheduling = UNNotificationScheduler()) {
        self.notifier = notifier
    }

    @discardableResult
    func requestNotificationPermission() async -> Bool {
        await notifier.requestAuthorizationIfNeeded()
    }

    // MARK: - scheduleReminder(reminder:)

    /// Schedules pending notifications for **one** reminder within `solarYear` (Gregorian, Vietnam calendar).
    func scheduleReminder(_ reminder: Reminder, solarYear: Int) async {
        guard LunarEngine.supportedYearRange.contains(solarYear) else { return }
        let dates = fireDates(for: reminder, solarYear: solarYear)
        let before = reminder.notifyBeforeMinutes ?? 0
        for (idx, solar) in dates.enumerated() {
            guard var fire = LunarReminderConverter.date(from: solar, hour: defaultHour, minute: defaultMinute) else { continue }
            fire = Calendar.current.date(byAdding: .minute, value: -before, to: fire) ?? fire
            guard fire > Date() else { continue }
            let id = "\(reminder.id).\(solarYear).\(idx)"
            let body = notificationBody(solar: solar, reminder: reminder)
            notifier.add(ReminderNotificationRequest(
                identifier: id,
                title: reminder.title,
                body: body,
                fireDate: fire
            ))
        }
    }

    /// Removes all pending requests whose identifier starts with `reminder.id.`.
    func cancelReminder(_ reminder: Reminder) async {
        let pending = await notifier.pendingNotificationIdentifiers()
        let ids = pending.filter { $0.hasPrefix(reminder.id + ".") }
        notifier.removePendingNotifications(withIdentifiers: ids)
    }

    // MARK: - rescheduleAllRemindersForYear(year)

    func rescheduleAllRemindersForYear(_ solarYear: Int, reminders: [Reminder]) async {
        _ = await notifier.requestAuthorizationIfNeeded()
        let pending = await notifier.pendingNotificationIdentifiers()
        let yearMarker = ".\(solarYear)."
        let toRemove = pending.filter { $0.contains(yearMarker) }
        notifier.removePendingNotifications(withIdentifiers: toRemove)
        for r in reminders where Self.isReminderEnabled(r) {
            await scheduleReminder(r, solarYear: solarYear)
        }
    }

    /// Per-reminder on/off (default **on** for built-ins when key missing).
    static func isReminderEnabled(_ reminder: Reminder) -> Bool {
        if UserDefaults.standard.object(forKey: "reminder.enabled.\(reminder.id)") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "reminder.enabled.\(reminder.id)")
    }

    static func setReminderEnabled(_ reminder: Reminder, on: Bool) {
        UserDefaults.standard.set(on, forKey: "reminder.enabled.\(reminder.id)")
    }

    // MARK: - Core date expansion

    /// When no lunar month is fixed (mùng 1 / rằm every month), do not filter leap. When a month is fixed, `isLeapMonth` on the reminder selects leap vs normal lunar month.
    private func leapFilter(for reminder: Reminder) -> Bool? {
        guard reminder.lunarMonth != nil else { return nil }
        return reminder.isLeapMonth
    }

    private func fireDates(for reminder: Reminder, solarYear: Int) -> [SolarDate] {
        switch reminder.type {
        case .lunar_fixed:
            guard let ld = reminder.lunarDay else { return [] }
            if reminder.repeat == .monthly, reminder.lunarMonth == nil {
                return LunarReminderConverter.solarOccurrences(
                    lunarDay: ld,
                    lunarMonth: nil,
                    isLeapMonth: nil,
                    solarYear: solarYear,
                    engine: engine
                )
            }
            if let lm = reminder.lunarMonth {
                return LunarReminderConverter.solarOccurrences(
                    lunarDay: ld,
                    lunarMonth: lm,
                    isLeapMonth: leapFilter(for: reminder),
                    solarYear: solarYear,
                    engine: engine
                )
            }
            return []

        case .user_event:
            guard let ld = reminder.lunarDay else { return [] }
            if reminder.repeat == .monthly, reminder.lunarMonth == nil {
                return LunarReminderConverter.solarOccurrences(
                    lunarDay: ld,
                    lunarMonth: nil,
                    isLeapMonth: nil,
                    solarYear: solarYear,
                    engine: engine
                )
            }
            guard let lm = reminder.lunarMonth else { return [] }
            return LunarReminderConverter.solarOccurrences(
                lunarDay: ld,
                lunarMonth: lm,
                isLeapMonth: leapFilter(for: reminder),
                solarYear: solarYear,
                engine: engine
            )
        }
    }

    private func notificationBody(solar: SolarDate, reminder: Reminder) -> String {
        let lunar = engine.solarToLunar(date: solar)
        return "Âm lịch \(lunar.day)/\(lunar.month)/\(lunar.year) · Dương \(solar.day)/\(solar.month)/\(solar.year)"
    }
}
