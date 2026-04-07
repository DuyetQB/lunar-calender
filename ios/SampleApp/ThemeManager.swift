//
//  ThemeManager.swift
//  Accent + light/dark preference; shared with widget via App Group.
//

import Combine
import Foundation
import SwiftUI
import WidgetKit

enum AppearanceMode: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .system: return "appearance_system"
        case .light: return "appearance_light"
        case .dark: return "appearance_dark"
        }
    }

    /// Pass to `.preferredColorScheme(_:)`.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

final class ThemeManager: ObservableObject {
    @Published var accent: AccentTheme {
        didSet { persist() }
    }

    @Published var appearance: AppearanceMode {
        didSet { persist() }
    }

    var colors: AppThemeColors { AppThemeColors.palette(accent) }

    init() {
        let a = Self.loadAccent()
        let p = Self.loadAppearance()
        _accent = Published(initialValue: a)
        _appearance = Published(initialValue: p)
        persist()
    }

    private static func loadAccent() -> AccentTheme {
        if let suite = UserDefaults(suiteName: SharedConfig.appGroupId),
           let raw = suite.string(forKey: SharedConfig.themeAccentKey),
           let v = AccentTheme(rawValue: raw) {
            return v
        }
        if let raw = UserDefaults.standard.string(forKey: SharedConfig.themeAccentKey),
           let v = AccentTheme(rawValue: raw) {
            return v
        }
        return .terracotta
    }

    private static func loadAppearance() -> AppearanceMode {
        if let suite = UserDefaults(suiteName: SharedConfig.appGroupId),
           let raw = suite.string(forKey: SharedConfig.themeAppearanceKey),
           let v = AppearanceMode(rawValue: raw) {
            return v
        }
        if let raw = UserDefaults.standard.string(forKey: SharedConfig.themeAppearanceKey),
           let v = AppearanceMode(rawValue: raw) {
            return v
        }
        return .system
    }

    private func persist() {
        UserDefaults.standard.set(accent.rawValue, forKey: SharedConfig.themeAccentKey)
        UserDefaults.standard.set(appearance.rawValue, forKey: SharedConfig.themeAppearanceKey)
        let suite = UserDefaults(suiteName: SharedConfig.appGroupId)
        suite?.set(accent.rawValue, forKey: SharedConfig.themeAccentKey)
        suite?.set(appearance.rawValue, forKey: SharedConfig.themeAppearanceKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
