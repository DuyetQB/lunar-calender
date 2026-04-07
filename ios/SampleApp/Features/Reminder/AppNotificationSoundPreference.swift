//
//  AppNotificationSoundPreference.swift
//  User-selected sound for local notifications (notes + lunar reminders).
//

import Foundation
import UserNotifications

enum AppNotificationSoundPreference: String, CaseIterable, Identifiable {
    /// Standard notification alert sound.
    case systemDefault = "system_default"
    /// User’s default ringtone (iOS 15+); falls back to default on older OS.
    case defaultRingtone = "default_ringtone"
    /// Banner only, no sound.
    case silent = "silent"

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .systemDefault:
            return "settings_notification_sound_default"
        case .defaultRingtone:
            return "settings_notification_sound_ringtone"
        case .silent:
            return "settings_notification_sound_silent"
        }
    }

    /// Sound applied when scheduling a local notification.
    func notificationSound() -> UNNotificationSound? {
        switch self {
        case .systemDefault:
            return .default
        case .defaultRingtone:
            if #available(iOS 15.0, *) {
                return .defaultRingtone
            }
            return .default
        case .silent:
            return nil
        }
    }

    static func current() -> AppNotificationSoundPreference {
        let raw = UserDefaults.standard.string(forKey: SharedConfig.notificationSoundPreferenceKey) ?? ""
        return AppNotificationSoundPreference(rawValue: raw) ?? .systemDefault
    }
}
