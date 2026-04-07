//
//  LunarApp.swift
//  Sample Vietnamese Lunar Calendar (SwiftUI)
//
//  Lunar calendar logic lives in ios/LunarCore (sources are compiled into this app target).
//

import SwiftUI
import UIKit
import UserNotifications

final class AppNotificationDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}

@main
struct LunarApp: App {
    @UIApplicationDelegateAdaptor(AppNotificationDelegate.self) private var appDelegate
    @StateObject private var language = AppLanguageManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var reminderStore = ReminderStore()
    @StateObject private var noteStore = NoteStore()
    @StateObject private var profileStore = ProfileStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(language)
                .environmentObject(themeManager)
                .environmentObject(reminderStore)
                .environmentObject(noteStore)
                .environmentObject(profileStore)
                .environment(\.appThemeColors, themeManager.colors)
                .preferredColorScheme(themeManager.appearance.colorScheme)
        }
    }
}
