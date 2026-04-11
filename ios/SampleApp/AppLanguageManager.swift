//
//  AppLanguageManager.swift
//  In-app language (English / Vietnamese) + shared defaults for the widget.
//

import Combine
import Foundation
import SwiftUI
import WidgetKit

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case vietnamese = "vi"

    var id: String { rawValue }

    var displayNameKey: LocalizedStringKey {
        switch self {
        case .english: return "lang_english"
        case .vietnamese: return "lang_vietnamese"
        }
    }
}

final class AppLanguageManager: ObservableObject {
    @Published var language: AppLanguage {
        didSet { persist(language) }
    }

    var locale: Locale { Locale(identifier: language.rawValue) }

    init() {
        let initial = Self.loadInitialLanguage()
        _language = Published(initialValue: initial)
        persist(initial)
    }

    private static func loadInitialLanguage() -> AppLanguage {
        if let raw = AppGroupPreferences.string(forKey: SharedConfig.languageKey),
           let parsed = AppLanguage(rawValue: raw) {
            return parsed
        }
        if let raw = UserDefaults.standard.string(forKey: SharedConfig.languageKey),
           let parsed = AppLanguage(rawValue: raw) {
            return parsed
        }
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("vi") ? .vietnamese : .english
    }

    private func persist(_ lang: AppLanguage) {
        UserDefaults.standard.set(lang.rawValue, forKey: SharedConfig.languageKey)
        AppGroupPreferences.set(lang.rawValue, forKey: SharedConfig.languageKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
