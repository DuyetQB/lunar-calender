//
//  HolidayViews.swift
//  Icon, upcoming card, full list, detail + deep detail + previews.
//

import SwiftUI
import UIKit

// MARK: - Icon (SF Symbol or emoji)

struct HolidayIconView: View {
    let icon: String
    var font: Font = .title2

    private var isLikelySFSymbol: Bool {
        icon.unicodeScalars.allSatisfy { s in
            let c = s.value
            return (0x30...0x39).contains(c) || (0x41...0x5A).contains(c) || (0x61...0x7A).contains(c)
                || c == 0x2E || c == 0x2D
        }
    }

    var body: some View {
        Group {
            if isLikelySFSymbol {
                Image(systemName: icon)
                    .font(font)
            } else {
                Text(icon)
                    .font(font)
            }
        }
    }
}

// MARK: - Upcoming card

/// Uses `HolidayService.getUpcomingHolidays(from:)` (soonest first).
struct UpcomingHolidayCard: View {
    @Environment(\.appThemeColors) private var theme

    let holidays: [Holiday]
    let service: HolidayService
    var onRemind: (Holiday) -> Void
    var onView: (Holiday) -> Void

    private let maxSwipePages = 4

    @State private var pageIndex: Int = 0

    private var pages: [Holiday] {
        Array(holidays.prefix(maxSwipePages))
    }

    private var hiddenCount: Int {
        max(0, holidays.count - pages.count)
    }

    private let tabViewHeight: CGFloat = 182

    var body: some View {
        Group {
            if holidays.isEmpty {
                EmptyView()
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("holiday_card_section_title")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    if pages.count == 1, let only = pages.first {
                        cardContent(for: only, highlighted: isHighlighted(only))
                        if hiddenCount > 0 {
                            Text(String(format: String(localized: "holiday_card_more_format"), hiddenCount))
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(theme.primary)
                        }
                    } else {
                        TabView(selection: $pageIndex) {
                            ForEach(Array(pages.enumerated()), id: \.element.id) { index, holiday in
                                cardContent(for: holiday, highlighted: isHighlighted(holiday))
                                    .padding(.horizontal, 2)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: pages.count <= 3 ? .automatic : .never))
                        .frame(height: tabViewHeight)

                        HStack {
                            Text("\(pageIndex + 1)/\(pages.count)")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.tertiary)
                            if hiddenCount > 0 {
                                Text(String(format: String(localized: "holiday_card_more_format"), hiddenCount))
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(theme.primary)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
        }
    }

    private func isHighlighted(_ holiday: Holiday) -> Bool {
        guard let next = service.nextOccurrence(of: holiday, from: Date()),
              let days = service.daysRemaining(from: Date(), to: next) else { return false }
        return days <= 7
    }

    @ViewBuilder
    private func cardContent(for holiday: Holiday, highlighted: Bool) -> some View {
        let next = service.nextOccurrence(of: holiday, from: Date())
        let days = next.flatMap { service.daysRemaining(from: Date(), to: $0) }

        VStack(alignment: .leading, spacing: highlighted ? 12 : 8) {
            HStack(alignment: .center, spacing: 10) {
                HolidayIconView(icon: holiday.icon, font: highlighted ? .title2 : .title3)
                    .foregroundStyle(highlighted ? theme.primary : .secondary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle().fill(highlighted ? theme.primary.opacity(0.12) : Color(uiColor: .tertiarySystemFill))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(holiday.name)
                        .font(highlighted ? .title3.weight(.semibold) : .headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    if let next {
                        Text(String(format: String(localized: "holiday_lunar_format"), service.lunarLine(at: next)))
                            .font(highlighted ? .subheadline : .footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    if let days {
                        Text(String(format: String(localized: "holiday_countdown_format"), days))
                            .font(highlighted ? .subheadline.weight(.semibold) : .caption.weight(.semibold))
                            .foregroundStyle(days <= 7 ? theme.hoangDao : .secondary)
                    }
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 10) {
                Button {
                    onRemind(holiday)
                } label: {
                    Label("holiday_remind_me_short", systemImage: "bell.fill")
                        .font(highlighted ? .subheadline.weight(.semibold) : .caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.primary)
                .controlSize(highlighted ? .regular : .small)

                Button {
                    onView(holiday)
                } label: {
                    Text("holiday_view_button")
                        .font(highlighted ? .subheadline.weight(.semibold) : .caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(highlighted ? .regular : .small)
            }
        }
        .padding(highlighted ? 16 : 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: highlighted ? 18 : 14, style: .continuous)
                .fill(highlighted ? theme.primary.opacity(0.08) : Color(uiColor: .secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: highlighted ? 18 : 14, style: .continuous)
                .strokeBorder(
                    highlighted ? theme.hoangDao.opacity(0.55) : Color.clear,
                    lineWidth: highlighted ? 1.5 : 0
                )
        )
        .shadow(color: .black.opacity(highlighted ? 0.08 : 0.04), radius: highlighted ? 10 : 4, x: 0, y: highlighted ? 4 : 2)
    }
}

// MARK: - Full list (grouped by category)

struct HolidayListView: View {
    @Environment(\.appThemeColors) private var theme

    let service: HolidayService
    /// Called after a reminder is successfully scheduled (e.g. refresh calendar highlights).
    var onReminderScheduled: (() -> Void)?

    @State private var detailSheetHoliday: Holiday?

    init(service: HolidayService, onReminderScheduled: (() -> Void)? = nil) {
        self.service = service
        self.onReminderScheduled = onReminderScheduled
    }

    var body: some View {
        List {
            ForEach(HolidayCategory.allCases, id: \.self) { category in
                if !holidays(for: category).isEmpty {
                    Section {
                        ForEach(holidays(for: category)) { holiday in
                            NavigationLink {
                                HolidayDetailView(
                                    holiday: holiday,
                                    service: service,
                                    onReminderSuccess: { onReminderScheduled?() },
                                    onDismiss: nil
                                )
                            } label: {
                                HStack(spacing: 12) {
                                    HolidayIconView(icon: holiday.icon, font: .title3)
                                        .frame(width: 36, height: 36)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(holiday.name)
                                            .font(.headline)
                                        Text(holiday.shortDescription)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    } header: {
                        Text(categoryTitle(category))
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(theme.primary)
                            .textCase(nil)
                    }
                }
            }
        }
        .navigationTitle(Text("holiday_list_title"))
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $detailSheetHoliday) { holiday in
            NavigationStack {
                HolidayDetailView(
                    holiday: holiday,
                    service: service,
                    onReminderSuccess: { onReminderScheduled?() },
                    onDismiss: { detailSheetHoliday = nil }
                )
            }
        }
    }

    private func holidays(for category: HolidayCategory) -> [Holiday] {
        service.getAllHolidays()
            .filter { $0.category == category }
            .sorted { $0.name < $1.name }
    }

    private func categoryTitle(_ c: HolidayCategory) -> String {
        switch c {
        case .traditional:
            return String(localized: "holiday_category_traditional")
        case .spiritual:
            return String(localized: "holiday_category_spiritual")
        case .national:
            return String(localized: "holiday_category_national")
        }
    }
}

// MARK: - Detail (level 1–2)

struct HolidayDetailView: View {
    @Environment(\.appThemeColors) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL

    let holiday: Holiday
    let service: HolidayService
    /// Optional hook after a reminder is scheduled (e.g. refresh calendar pending markers).
    var onReminderSuccess: (() -> Void)? = nil
    var onDismiss: (() -> Void)?

    @State private var reminderFailure: HolidayDetailReminderFailure?
    @State private var reminderScheduled = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerRow

                if let next = service.nextOccurrence(of: holiday, from: Date()),
                   let days = service.daysRemaining(from: Date(), to: next) {
                    countdownStrip(next: next, days: days)
                }

                sectionCard(icon: "text.quote", titleKey: "holiday_detail_section_quick") {
                    Text(holiday.shortDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                sectionCard(icon: "book.closed.fill", titleKey: "holiday_detail_section_meaning") {
                    Text(holiday.meaning)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !holiday.activities.isEmpty {
                    sectionCard(icon: "list.bullet.rectangle.portrait.fill", titleKey: "holiday_detail_section_activities") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(holiday.activities.enumerated()), id: \.offset) { _, line in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("•")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(theme.primary)
                                        .frame(width: 14, alignment: .leading)
                                    Text(line)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }

                sectionCard(icon: "lightbulb.max.fill", titleKey: "holiday_fun_fact_heading") {
                    Text(holiday.funFact)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }

                NavigationLink {
                    HolidayDeepDetailView(
                        holiday: holiday,
                        service: service,
                        onRemind: scheduleReminderFromDetail
                    )
                } label: {
                    HStack {
                        Text("holiday_detail_see_more")
                            .font(.headline.weight(.semibold))
                        Spacer(minLength: 8)
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(theme.primary)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                Button(action: scheduleReminderFromDetail) {
                    Label("holiday_remind_me_short", systemImage: "bell.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.primary)
            }
            .padding(20)
            .padding(.bottom, 8)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(holiday.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "holiday_reminder_alert_title",
            isPresented: Binding(
                get: { reminderFailure != nil },
                set: { if !$0 { reminderFailure = nil } }
            )
        ) {
            if case .denied = reminderFailure {
                Button("holiday_reminder_open_settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                    reminderFailure = nil
                }
            }
            Button("home_close", role: .cancel) {
                reminderFailure = nil
            }
        } message: {
            switch reminderFailure {
            case .denied:
                Text("holiday_reminder_denied_message")
            case .noOccurrence:
                Text("holiday_reminder_no_occurrence")
            case .none:
                EmptyView()
            }
        }
        .alert(
            "holiday_reminder_scheduled_title",
            isPresented: $reminderScheduled
        ) {
            Button("home_close") { reminderScheduled = false }
        } message: {
            Text("holiday_reminder_scheduled_message")
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(
                    item: HolidayShareText.plain(holiday: holiday),
                    subject: Text(holiday.name),
                    message: Text(holiday.shortDescription)
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
                if let onDismiss {
                    Button("home_close", action: onDismiss)
                }
            }
        }
    }

    private enum HolidayDetailReminderFailure {
        case denied
        case noOccurrence
    }

    private func scheduleReminderFromDetail() {
        Task {
            let result = await service.scheduleHolidayReminder(holiday: holiday)
            await MainActor.run {
                switch result {
                case .scheduled:
                    reminderScheduled = true
                    onReminderSuccess?()
                case .denied:
                    reminderFailure = .denied
                case .noOccurrence:
                    reminderFailure = .noOccurrence
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(spacing: 14) {
            HolidayIconView(icon: holiday.icon, font: .title)
                .foregroundStyle(theme.primary)
                .frame(width: 48, height: 48)
                .background(theme.primary.opacity(colorScheme == .dark ? 0.22 : 0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(holiday.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(categoryTitle(holiday.category))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func categoryTitle(_ c: HolidayCategory) -> String {
        switch c {
        case .traditional:
            return String(localized: "holiday_category_traditional")
        case .spiritual:
            return String(localized: "holiday_category_spiritual")
        case .national:
            return String(localized: "holiday_category_national")
        }
    }

    private func countdownStrip(next: Date, days: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(format: String(localized: "holiday_countdown_format"), days))
                .font(.headline)
                .foregroundStyle(theme.primary)
            Text(service.solarLunarCaption(at: next))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }

    @ViewBuilder
    private func sectionCard<Content: View>(icon: String, titleKey: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(theme.primary)
                    .frame(width: 28, height: 28)
                    .background(theme.primary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text(titleKey)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.25 : 0.06), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Deep detail (history)

struct HolidayDeepDetailView: View {
    @Environment(\.appThemeColors) private var theme
    @Environment(\.colorScheme) private var colorScheme
    let holiday: Holiday
    let service: HolidayService
    var onRemind: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                hero

                deepSection(
                    icon: "clock.arrow.circlepath",
                    titleKey: "holiday_detail_deep_history",
                    body: holiday.history
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .padding(.bottom, 28)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle(Text(LocalizedStringKey("holiday_detail_deep_nav_title")))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(
                    item: HolidayShareText.deep(holiday: holiday),
                    subject: Text(holiday.name),
                    message: Text(holiday.shortDescription)
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()
                Button(action: onRemind) {
                    Label("holiday_remind_me_short", systemImage: "bell.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.bar)
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                HolidayIconView(icon: holiday.icon, font: .largeTitle)
                    .foregroundStyle(theme.primary)
                    .frame(width: 52, height: 52)
                    .background(theme.primary.opacity(colorScheme == .dark ? 0.2 : 0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(holiday.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(categoryTitle(holiday.category))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            if let next = service.nextOccurrence(of: holiday, from: Date()),
               let days = service.daysRemaining(from: Date(), to: next) {
                Text(String(format: String(localized: "holiday_countdown_format"), days))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 12, x: 0, y: 4)
        )
    }

    private func categoryTitle(_ c: HolidayCategory) -> String {
        switch c {
        case .traditional:
            return String(localized: "holiday_category_traditional")
        case .spiritual:
            return String(localized: "holiday_category_spiritual")
        case .national:
            return String(localized: "holiday_category_national")
        }
    }

    private func deepSection(icon: String, titleKey: LocalizedStringKey, body: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(theme.primary)
                    .frame(width: 36, height: 36)
                    .background(theme.primary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(titleKey)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
            }
            Text(body)
                .font(.title3)
                .foregroundStyle(.primary)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Previews

@available(iOS 16.0, *)
enum HolidayViews_Previews: PreviewProvider {
    static var previews: some View {
        let palette = AppThemeColors.palette(.terracotta)
        let svc = HolidayService()

        Group {
            NavigationStack {
                HolidayListView(service: svc)
            }
            .previewDisplayName("Danh sách lễ")

            NavigationStack {
                HolidayDetailView(
                    holiday: HolidayData.allHolidays.first(where: { $0.name.contains("Tết Nguyên") })!,
                    service: svc,
                    onReminderSuccess: nil,
                    onDismiss: {}
                )
            }
            .previewDisplayName("Chi tiết")
        }
        .environment(\.appThemeColors, palette)
    }
}
