//
//  SharedConfig.swift
//  App group + keys for the main app and widget extension.
//

import Foundation

enum SharedConfig {
    static let appGroupId = "group.com.lunaryear.app"
    static let languageKey = "app_language"
    static let themeAccentKey = "app_theme_accent"
    static let themeAppearanceKey = "app_theme_appearance"
    /// Optional: when set, widgets compute sunrise/sunset (local mean time from longitude).
    static let widgetLatitudeKey = "widget_latitude"
    static let widgetLongitudeKey = "widget_longitude"
}
