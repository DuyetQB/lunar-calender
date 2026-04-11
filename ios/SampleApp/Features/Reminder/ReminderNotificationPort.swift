//
//  ReminderNotificationPort.swift
//  Abstraction so you can swap UNUserNotificationCenter vs mock (tests / previews).
//

import Foundation
import UserNotifications

/// Identifier prefix for one-shot holiday reminders (`ReminderService`); parsed when highlighting the calendar.
enum HolidayPendingNotificationId {
    static let prefix = "calendar.holiday."
    static func identifier(holidayId: UUID) -> String { "\(prefix)\(holidayId.uuidString)" }
}

protocol ReminderNotificationScheduling: AnyObject {
    func requestAuthorizationIfNeeded() async -> Bool
    func removePendingNotifications(withIdentifiers ids: [String])
    func add(_ request: ReminderNotificationRequest)
    /// Used to cancel and reschedule without depending on `UNUserNotificationCenter` in app code (mock-friendly).
    func pendingNotificationIdentifiers() async -> [String]
    /// Pending holiday one-shots: holiday id and next fire date (from the notification trigger).
    func pendingHolidayReminderFires() async -> [(holidayId: UUID, fireDate: Date)]
}

struct ReminderNotificationRequest {
    let identifier: String
    let title: String
    let body: String
    let fireDate: Date
}

/// Real iOS local notifications.
final class UNNotificationScheduler: ReminderNotificationScheduling {
    func requestAuthorizationIfNeeded() async -> Bool {
        await withCheckedContinuation { cont in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { ok, _ in
                cont.resume(returning: ok)
            }
        }
    }

    func removePendingNotifications(withIdentifiers ids: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    func add(_ request: ReminderNotificationRequest) {
        let content = UNMutableNotificationContent()
        content.title = request.title
        content.body = request.body
        content.sound = AppNotificationSoundPreference.current().notificationSound()
        content.badge = 1
        if #available(iOS 15.0, *) {
            // `.timeSensitive` requires the Time Sensitive Notifications capability; use `.active` so delivery is reliable.
            content.interruptionLevel = .active
        }
        // `UNCalendarNotificationTrigger(dateMatching:repeats:)` uses the **device** calendar/timezone, so
        // Vietnam 08:00 wall times were mis-scheduled for users outside VN (or never fired). Interval trigger matches the absolute `fireDate`.
        let seconds = request.fireDate.timeIntervalSinceNow
        guard seconds > 1 else { return }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let req = UNNotificationRequest(identifier: request.identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }

    func pendingNotificationIdentifiers() async -> [String] {
        await withCheckedContinuation { cont in
            UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
                cont.resume(returning: reqs.map(\.identifier))
            }
        }
    }

    func pendingHolidayReminderFires() async -> [(holidayId: UUID, fireDate: Date)] {
        await withCheckedContinuation { cont in
            UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
                let p = HolidayPendingNotificationId.prefix
                var out: [(UUID, Date)] = []
                out.reserveCapacity(4)
                for r in reqs {
                    guard r.identifier.hasPrefix(p) else { continue }
                    let rest = String(r.identifier.dropFirst(p.count))
                    guard let uuid = UUID(uuidString: rest) else { continue }
                    let fire: Date?
                    if let t = r.trigger as? UNTimeIntervalNotificationTrigger {
                        fire = t.nextTriggerDate()
                    } else if let t = r.trigger as? UNCalendarNotificationTrigger {
                        fire = t.nextTriggerDate()
                    } else {
                        fire = nil
                    }
                    guard let f = fire else { continue }
                    out.append((uuid, f))
                }
                cont.resume(returning: out)
            }
        }
    }
}

/// Mock: stores requests only.
final class MockNotificationScheduler: ReminderNotificationScheduling {
    var lastRequests: [ReminderNotificationRequest] = []

    func requestAuthorizationIfNeeded() async -> Bool { true }

    func removePendingNotifications(withIdentifiers ids: [String]) {
        lastRequests.removeAll { ids.contains($0.identifier) }
    }

    func add(_ request: ReminderNotificationRequest) {
        lastRequests.append(request)
    }

    func pendingNotificationIdentifiers() async -> [String] {
        lastRequests.map(\.identifier)
    }

    func pendingHolidayReminderFires() async -> [(holidayId: UUID, fireDate: Date)] {
        let p = HolidayPendingNotificationId.prefix
        return lastRequests.compactMap { req in
            guard req.identifier.hasPrefix(p) else { return nil }
            let rest = String(req.identifier.dropFirst(p.count))
            guard let uuid = UUID(uuidString: rest) else { return nil }
            return (uuid, req.fireDate)
        }
    }
}
