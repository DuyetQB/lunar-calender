//
//  DetailView.swift
//  Detail: solar, lunar, Can Chi, Hoàng Đạo, good hours, suggestions.
//

import Foundation
import SwiftUI
import UIKit

struct DetailView: View {
    @Environment(\.appThemeColors) private var theme
    @Environment(\.locale) private var locale
    @EnvironmentObject private var noteStore: NoteStore
    let solar: SolarDate
    let engine: LunarEngine
    @State private var showingNotes = false
    @State private var pendingHolidayReminder: Holiday?
    private let reminderService = ReminderService()

    var body: some View {
        let lunar = engine.solarToLunar(date: solar)
        let dayNotes = noteStore.notes(for: solarAsDate())
        let canChi = engine.canChi(date: solar)
        let hoangDao = engine.isHoangDao(date: solar)
        let hours = engine.goodHours(date: solar)
        let (goodFor, avoidFor) = engine.evaluation(date: solar)
        let term = engine.tietKhi(date: solar)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard(solar: solar, lunar: lunar, term: term)
                notesSummaryCard(notes: dayNotes)
                if let holiday = pendingHolidayReminder {
                    holidayReminderCard(holiday: holiday)
                }
                hoangDaoCard(hoangDao: hoangDao, hours: hours)
                canChiCard(canChi: canChi)
                evaluationCard(goodFor: goodFor, avoidFor: avoidFor)
            }
            .padding(16)
        }
        .background(theme.cardBackground.opacity(0.8))
        .navigationTitle(dateTitle(solar))
        .navigationBarTitleDisplayMode(.inline)
        .task(id: solar.id) {
            pendingHolidayReminder = await reminderService.holidayWithPendingReminder(on: solar)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task {
                pendingHolidayReminder = await reminderService.holidayWithPendingReminder(on: solar)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNotes = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "note.text.badge.plus")
                        if !dayNotes.isEmpty {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .accessibilityLabel(Text("notes_list_title"))
            }
        }
        .sheet(isPresented: $showingNotes) {
            NavigationStack {
                NoteListView(
                    selectedSolarDate: solarAsDate(),
                    selectedLunarDate: engine.solarToLunar(date: solar)
                )
            }
        }
    }

    private func dateTitle(_ solar: SolarDate) -> String {
        "\(solar.day)/\(solar.month)/\(solar.year)"
    }

    private func notesSummaryCard(notes: [CalendarNote]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundStyle(theme.primary)
                Text("detail_notes_section")
                    .font(.headline)
                Spacer()
                Button {
                    showingNotes = true
                } label: {
                    Text("detail_notes_manage")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.primary)
                }
            }
            if notes.isEmpty {
                Text("detail_notes_empty")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(notes.enumerated()), id: \.element.id) { index, note in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(note.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        if !note.content.isEmpty {
                            Text(note.content)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(5)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        if note.hasReminder, let reminderDate = note.reminderDate {
                            HStack(spacing: 6) {
                                Image(systemName: "bell.fill")
                                    .font(.caption2)
                                Text(reminderDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption.weight(.medium))
                                if note.isLunarRepeat {
                                    Text("notes_lunar_repeat_badge")
                                        .font(.caption2.weight(.semibold))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.18))
                                        .foregroundStyle(.orange)
                                        .clipShape(Capsule())
                                }
                            }
                            .foregroundStyle(.orange)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if index < notes.count - 1 {
                        Divider().padding(.vertical, 4)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    notes.isEmpty ? Color.clear : theme.primary.opacity(0.35),
                    lineWidth: notes.isEmpty ? 0 : 1.5
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func holidayReminderCard(holiday: Holiday) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .foregroundStyle(theme.primary)
                Text("detail_holiday_reminder_title")
                    .font(.headline)
            }
            Text(holiday.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            HStack(spacing: 6) {
                Image(systemName: "bell.fill")
                    .font(.caption2)
                Text("detail_holiday_reminder_time")
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(theme.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.primary.opacity(0.45), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func headerCard(solar: SolarDate, lunar: LunarDate, term: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(solar.day)")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(theme.primary)
                Text("/ \(solar.month)/\(solar.year)")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                labelValue("detail_lunar_day", lunarText(lunar))
                Spacer()
                labelValue("detail_solar_term", term)
            }
            .font(.subheadline)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func hoangDaoCard(hoangDao: Bool, hours: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: hoangDao ? "sun.max.fill" : "moon.fill")
                    .foregroundStyle(hoangDao ? theme.hoangDao : theme.hacDao)
                Text("detail_hoangdao_title")
                    .font(.headline)
                Spacer()
                Text(hoangDao ? "detail_hoangdao" : "detail_hacdao")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(hoangDao ? theme.hoangDao : theme.hacDao)
                    .clipShape(Capsule())
            }
            if hoangDao && !hours.isEmpty {
                Text("detail_good_hours")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                goodHoursStack(hours: hours)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func canChiCard(canChi: (day: String, month: String, year: String)) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(theme.primary)
                Text("detail_can_chi")
                    .font(.headline)
            }
            VStack(alignment: .leading, spacing: 6) {
                row("detail_day", canChi.day)
                row("detail_month", canChi.month)
                row("detail_year", canChi.year)
            }
            .font(.subheadline)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func evaluationCard(goodFor: [String], avoidFor: [String]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(theme.goodAccent)
                Text("detail_should_avoid_title")
                    .font(.headline)
            }
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("detail_should")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.goodAccent)
                    ForEach(goodFor, id: \.self) { s in
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(theme.goodAccent)
                            Text(LocalizedStringKey(evalLocalizationKey(s)))
                                .font(.subheadline)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 6) {
                    Text("detail_avoid")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.avoidAccent)
                    ForEach(avoidFor, id: \.self) { s in
                        HStack(spacing: 6) {
                            Image(systemName: "minus.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(theme.avoidAccent)
                            Text(LocalizedStringKey(evalLocalizationKey(s)))
                                .font(.subheadline)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func labelValue(_ labelKey: LocalizedStringKey, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(labelKey)
                .foregroundStyle(.secondary)
            Text(value)
                .fontWeight(.medium)
        }
    }

    private func row(_ labelKey: LocalizedStringKey, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(labelKey)
                .foregroundStyle(.secondary)
                .frame(width: 56, alignment: .leading)
            Text(value)
        }
    }

    private func evalLocalizationKey(_ engineKey: String) -> String {
        switch engineKey {
        case "wedding": return "eval_wedding"
        case "groundbreaking": return "eval_groundbreaking"
        case "opening business": return "eval_opening_business"
        case "funeral": return "eval_funeral"
        case "travel": return "eval_travel"
        case "construction": return "eval_construction"
        default: return engineKey
        }
    }

    private func goodHoursStack(hours: [String]) -> some View {
        let columns = 2
        return VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(stride(from: 0, to: hours.count, by: columns)), id: \.self) { start in
                HStack(spacing: 8) {
                    ForEach(start..<min(start + columns, hours.count), id: \.self) { i in
                        Text(hours[i])
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(theme.hoangDao.opacity(0.15))
                            .foregroundStyle(theme.hoangDao)
                            .clipShape(Capsule())
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func lunarText(_ lunar: LunarDate) -> String {
        var s = "\(lunar.day)/\(lunar.month)/\(lunar.year)"
        if lunar.isLeapMonth {
            s += " " + localizedString("detail_leap_suffix")
        }
        return s
    }

    private func localizedString(_ key: String) -> String {
        guard let code = locale.language.languageCode?.identifier,
              let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, bundle: .main, comment: "")
        }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }

    private func solarAsDate() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = LunarReminderConverter.vietnamTimeZone
        let comps = DateComponents(year: solar.year, month: solar.month, day: solar.day, hour: 12, minute: 0)
        return cal.date(from: comps) ?? Date()
    }
}
