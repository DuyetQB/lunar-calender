//
//  WidgetLocalized.swift
//  Resolves strings from the active target’s bundle using App Group language (not system UI language).
//

import Foundation

enum WidgetLocalized {
    static func deviceLanguageCode() -> String {
        let preferred = Locale.preferredLanguages.first ?? Locale.current.identifier
        return preferred.lowercased().hasPrefix("vi") ? "vi" : "en"
    }

    static func locale(for languageCode: String) -> Locale {
        Locale(identifier: languageCode == "vi" ? "vi_VN" : "en_US")
    }

    static func string(_ key: String, languageCode: String) -> String {
        let loc = locale(for: languageCode)
        return String(localized: String.LocalizationValue(key), bundle: .main, locale: loc)
    }

    static func format(_ key: String, languageCode: String, _ arguments: CVarArg...) -> String {
        let format = string(key, languageCode: languageCode)
        return String(format: format, arguments: arguments)
    }
}
