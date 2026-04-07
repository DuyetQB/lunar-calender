//
//  RootTabView.swift
//  Home, calendar, and settings tabs.
//

import SwiftUI

@available(iOS 16.0, *)
struct RootTabView: View {
    @EnvironmentObject private var language: AppLanguageManager
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("tab_home")
                }
            CalendarMonthView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("tab_calendar")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("tab_profile")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("tab_settings")
                }
        }
        .environment(\.locale, language.locale)
    }
}
