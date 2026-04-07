//
//  ReminderNotificationPort.swift
//  Abstraction so you can swap UNUserNotificationCenter vs mock (tests / previews).
//

import Foundation
import UserNotifications

protocol ReminderNotificationScheduling: AnyObject {
    func requestAuthorizationIfNeeded() async -> Bool
    func removePendingNotifications(withIdentifiers ids: [String])
    func add(_ request: ReminderNotificationRequest)
    /// Used to cancel and reschedule without depending on `UNUserNotificationCenter` in app code (mock-friendly).
    func pendingNotificationIdentifiers() async -> [String]
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
            content.interruptionLevel = .timeSensitive
        }
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = LunarReminderConverter.vietnamTimeZone
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: request.fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: request.identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    func pendingNotificationIdentifiers() async -> [String] {
        await withCheckedContinuation { cont in
            UNUserNotificationCenter.current().getPendingNotificationRequests { reqs in
                cont.resume(returning: reqs.map(\.identifier))
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
}
