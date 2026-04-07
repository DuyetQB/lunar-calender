//
//  LunarApp.swift
//  Sample Vietnamese Lunar Calendar (SwiftUI)
//
//  Lunar calendar logic lives in ios/LunarCore (sources are compiled into this app target).
//

import SwiftUI

@main
struct LunarApp: App {
    @StateObject private var language = AppLanguageManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var reminderStore = ReminderStore()
    @StateObject private var profileStore = ProfileStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(language)
                .environmentObject(themeManager)
                .environmentObject(reminderStore)
                .environmentObject(profileStore)
                .environment(\.appThemeColors, themeManager.colors)
                .preferredColorScheme(themeManager.appearance.colorScheme)
        }
    }
}
