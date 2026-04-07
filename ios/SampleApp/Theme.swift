//
//  Theme.swift
//  Accent palettes + SwiftUI environment for app and widget.
//

import SwiftUI

// MARK: - Accent presets

enum AccentTheme: String, CaseIterable, Identifiable, Codable {
    case terracotta
    case ocean
    case plum
    case jade
    case sunset
    case midnight

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .terracotta: return "accent_terracotta"
        case .ocean: return "accent_ocean"
        case .plum: return "accent_plum"
        case .jade: return "accent_jade"
        case .sunset: return "accent_sunset"
        case .midnight: return "accent_midnight"
        }
    }
}

/// Colors for one accent; used via `@Environment(\.appThemeColors)` in the app and in the widget.
struct AppThemeColors {
    let primary: Color
    let primaryLight: Color
    let hoangDao: Color
    let hacDao: Color
    let goodAccent: Color
    let avoidAccent: Color
    let cardBackground: Color
    let todayRing: Color
    let weekend: Color

    static func palette(_ accent: AccentTheme) -> AppThemeColors {
        switch accent {
        case .terracotta:
            return AppThemeColors(
                primary: Color(red: 0.72, green: 0.35, blue: 0.24),
                primaryLight: Color(red: 0.88, green: 0.62, blue: 0.52),
                hoangDao: Color(red: 0.22, green: 0.55, blue: 0.45),
                hacDao: Color(red: 0.45, green: 0.45, blue: 0.48),
                goodAccent: Color(red: 0.28, green: 0.58, blue: 0.42),
                avoidAccent: Color(red: 0.65, green: 0.38, blue: 0.38),
                cardBackground: Color(red: 0.98, green: 0.97, blue: 0.96),
                todayRing: Color(red: 0.72, green: 0.35, blue: 0.24),
                weekend: Color(red: 0.55, green: 0.35, blue: 0.35)
            )
        case .ocean:
            return AppThemeColors(
                primary: Color(red: 0.12, green: 0.45, blue: 0.55),
                primaryLight: Color(red: 0.45, green: 0.72, blue: 0.82),
                hoangDao: Color(red: 0.18, green: 0.52, blue: 0.48),
                hacDao: Color(red: 0.42, green: 0.48, blue: 0.52),
                goodAccent: Color(red: 0.22, green: 0.58, blue: 0.50),
                avoidAccent: Color(red: 0.58, green: 0.38, blue: 0.42),
                cardBackground: Color(red: 0.96, green: 0.98, blue: 0.99),
                todayRing: Color(red: 0.12, green: 0.45, blue: 0.55),
                weekend: Color(red: 0.38, green: 0.45, blue: 0.55)
            )
        case .plum:
            return AppThemeColors(
                primary: Color(red: 0.45, green: 0.28, blue: 0.52),
                primaryLight: Color(red: 0.72, green: 0.55, blue: 0.78),
                hoangDao: Color(red: 0.25, green: 0.50, blue: 0.42),
                hacDao: Color(red: 0.48, green: 0.44, blue: 0.50),
                goodAccent: Color(red: 0.35, green: 0.55, blue: 0.45),
                avoidAccent: Color(red: 0.62, green: 0.40, blue: 0.45),
                cardBackground: Color(red: 0.98, green: 0.96, blue: 0.99),
                todayRing: Color(red: 0.45, green: 0.28, blue: 0.52),
                weekend: Color(red: 0.50, green: 0.38, blue: 0.55)
            )
        case .jade:
            return AppThemeColors(
                primary: Color(red: 0.13, green: 0.54, blue: 0.44),
                primaryLight: Color(red: 0.57, green: 0.82, blue: 0.73),
                hoangDao: Color(red: 0.16, green: 0.56, blue: 0.42),
                hacDao: Color(red: 0.42, green: 0.50, blue: 0.47),
                goodAccent: Color(red: 0.20, green: 0.62, blue: 0.45),
                avoidAccent: Color(red: 0.60, green: 0.42, blue: 0.40),
                cardBackground: Color(red: 0.95, green: 0.99, blue: 0.97),
                todayRing: Color(red: 0.13, green: 0.54, blue: 0.44),
                weekend: Color(red: 0.33, green: 0.50, blue: 0.42)
            )
        case .sunset:
            return AppThemeColors(
                primary: Color(red: 0.84, green: 0.39, blue: 0.26),
                primaryLight: Color(red: 0.97, green: 0.68, blue: 0.48),
                hoangDao: Color(red: 0.26, green: 0.56, blue: 0.44),
                hacDao: Color(red: 0.50, green: 0.45, blue: 0.44),
                goodAccent: Color(red: 0.33, green: 0.60, blue: 0.45),
                avoidAccent: Color(red: 0.70, green: 0.36, blue: 0.34),
                cardBackground: Color(red: 0.99, green: 0.96, blue: 0.93),
                todayRing: Color(red: 0.84, green: 0.39, blue: 0.26),
                weekend: Color(red: 0.60, green: 0.40, blue: 0.36)
            )
        case .midnight:
            return AppThemeColors(
                primary: Color(red: 0.22, green: 0.33, blue: 0.60),
                primaryLight: Color(red: 0.53, green: 0.63, blue: 0.88),
                hoangDao: Color(red: 0.24, green: 0.53, blue: 0.45),
                hacDao: Color(red: 0.38, green: 0.44, blue: 0.58),
                goodAccent: Color(red: 0.28, green: 0.58, blue: 0.48),
                avoidAccent: Color(red: 0.58, green: 0.40, blue: 0.46),
                cardBackground: Color(red: 0.95, green: 0.96, blue: 0.99),
                todayRing: Color(red: 0.22, green: 0.33, blue: 0.60),
                weekend: Color(red: 0.36, green: 0.41, blue: 0.58)
            )
        }
    }

    /// Subtle gradient for widget `containerBackground`.
    func widgetGradientColors(colorScheme: ColorScheme) -> [Color] {
        if colorScheme == .dark {
            return [
                primary.opacity(0.35),
                Color(red: 0.12, green: 0.12, blue: 0.14),
                hoangDao.opacity(0.2)
            ]
        }
        return [
            cardBackground,
            primary.opacity(0.14),
            primaryLight.opacity(0.35)
        ]
    }
}

// MARK: - Environment

private struct AppThemeColorsKey: EnvironmentKey {
    static let defaultValue = AppThemeColors.palette(.terracotta)
}

extension EnvironmentValues {
    var appThemeColors: AppThemeColors {
        get { self[AppThemeColorsKey.self] }
        set { self[AppThemeColorsKey.self] = newValue }
    }
}
