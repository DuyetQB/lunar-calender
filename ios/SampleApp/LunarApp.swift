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
        application.registerForRemoteNotifications()
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    /// User tapped a local or remote notification (app was backgrounded or terminated).
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        #if DEBUG
        let hex = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNs device token: \(hex)")
        #endif
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        #if DEBUG
        print("APNs registration failed: \(error.localizedDescription)")
        #endif
    }

    /// Remote notifications with `content-available: 1` while app is in background.
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        completionHandler(.noData)
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
