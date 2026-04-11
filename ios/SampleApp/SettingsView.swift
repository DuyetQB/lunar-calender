//
//  SettingsView.swift
//  Language, appearance, accent, and widget help.
//

import SwiftUI
import WidgetKit

@available(iOS 16.0, *)
struct SettingsView: View {
    @EnvironmentObject private var language: AppLanguageManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var reminderStore: ReminderStore
    @EnvironmentObject private var noteStore: NoteStore
    @AppStorage(SharedConfig.notificationSoundPreferenceKey) private var notificationSoundRaw = AppNotificationSoundPreference.systemDefault.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(reminderStore.reminders) { r in
                        Toggle(isOn: Binding(
                            get: { reminderStore.isOn(r) },
                            set: { on in Task { await reminderStore.setEnabled(r, on: on) } }
                        )) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(r.title)
                                Text(reminderSubtitle(r))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    Button {
                        Task { await reminderStore.rescheduleAllForCurrentYear() }
                    } label: {
                        Text("settings_reminders_reschedule")
                    }
                } header: {
                    Text("settings_reminders_section")
                } footer: {
                    Text("settings_reminders_footer")
                }

                Section {
                    Picker(selection: notificationSoundBinding) {
                        ForEach(AppNotificationSoundPreference.allCases) { option in
                            Text(LocalizedStringKey(option.titleKey)).tag(option)
                        }
                    } label: {
                        Label {
                            Text("settings_notification_sound_label")
                        } icon: {
                            Image(systemName: "bell.badge.fill")
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("settings_notification_sound_section")
                } footer: {
                    Text("settings_notification_sound_footer")
                }

                Section {
                    Picker(selection: $language.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayNameKey).tag(lang)
                        }
                    } label: {
                        Label {
                            Text("language_label")
                        } icon: {
                            Image(systemName: "globe")
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("language_section")
                }

                Section {
                    Picker(selection: $themeManager.appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.titleKey).tag(mode)
                        }
                    } label: {
                        Label {
                            Text("settings_appearance_mode")
                        } icon: {
                            Image(systemName: "circle.lefthalf.filled")
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Picker(selection: $themeManager.accent) {
                        ForEach(AccentTheme.allCases) { accent in
                            Text(accent.titleKey).tag(accent)
                        }
                    } label: {
                        Label {
                            Text("settings_accent_color")
                        } icon: {
                            Image(systemName: "paintpalette.fill")
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("settings_appearance_section")
                }

                Section {
                    Text("settings_widget_instructions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Button {
                        AppGroupPreferences.set(10.8231, forKey: SharedConfig.widgetLatitudeKey)
                        AppGroupPreferences.set(106.6297, forKey: SharedConfig.widgetLongitudeKey)
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        Text("settings_widget_location_hcm")
                    }
                    Button(role: .destructive) {
                        AppGroupPreferences.removeObject(forKey: SharedConfig.widgetLatitudeKey)
                        AppGroupPreferences.removeObject(forKey: SharedConfig.widgetLongitudeKey)
                        WidgetCenter.shared.reloadAllTimelines()
                    } label: {
                        Text("settings_widget_location_clear")
                    }
                } header: {
                    Text("settings_widget_section")
                }
            }
            .navigationTitle(Text("settings_title"))
            .onChange(of: notificationSoundRaw) { _ in
                noteStore.rescheduleAllNotes()
                Task { await reminderStore.rescheduleAllForCurrentYear() }
            }
        }
    }

    private var notificationSoundBinding: Binding<AppNotificationSoundPreference> {
        Binding(
            get: { AppNotificationSoundPreference(rawValue: notificationSoundRaw) ?? .systemDefault },
            set: { notificationSoundRaw = $0.rawValue }
        )
    }

    private func reminderSubtitle(_ r: Reminder) -> String {
        switch r.repeat {
        case .monthly:
            return String(localized: "settings_reminder_repeat_monthly")
        case .yearly:
            return String(localized: "settings_reminder_repeat_yearly")
        }
    }
}
