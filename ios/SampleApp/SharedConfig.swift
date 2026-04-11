//
//  SharedConfig.swift
//  App group + keys for the main app and widget extension.
//

import Foundation

enum SharedConfig {
    static let appGroupId = "group.com.lunaryear.app"

    /// App ↔ widget shared keys live in `AppGroupPreferences` (plist in the group container), not `UserDefaults(suiteName:)`.

    static let languageKey = "app_language"
    static let themeAccentKey = "app_theme_accent"
    static let themeAppearanceKey = "app_theme_appearance"
    /// Optional: when set, widgets compute sunrise/sunset (local mean time from longitude).
    static let widgetLatitudeKey = "widget_latitude"
    static let widgetLongitudeKey = "widget_longitude"
    /// Raw value of `AppNotificationSoundPreference` for local notification sounds.
    static let notificationSoundPreferenceKey = "app_notification_sound_preference"
}
