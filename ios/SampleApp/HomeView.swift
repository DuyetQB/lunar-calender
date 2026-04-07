//
//  HomeView.swift
//  Today’s lunar summary, date explorer, shareable quote, and detail sheet.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct HomeView: View {
    @Environment(\.appThemeColors) private var theme
    @Environment(\.locale) private var locale
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var language: AppLanguageManager

    private let engine = LunarEngine()

    @State private var exploreDate: Date = Date()
    @State private var sheetSolar: SolarDate?

    private var vietnamCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        c.locale = locale
        return c
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    todaySection
                    exploreSection
                    quoteSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemBackground),
                        (colorScheme == .dark ? Color.black : theme.cardBackground).opacity(0.9),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle(Text("home_title"))
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $sheetSolar) { solar in
                NavigationStack {
                    DetailView(solar: solar, engine: engine)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button {
                                    sheetSolar = nil
                                } label: {
                                    Text("home_close")
                                }
                            }
                        }
                }
            }
        }
    }

    // MARK: - Today

    private var todaySection: some View {
        let solar = solarDate(from: Date())
        return VStack(alignment: .leading, spacing: 10) {
            Label("home_today_section", systemImage: "sun.max.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.primary)
            heroCard(for: solar)
                .onTapGesture {
                    sheetSolar = solar
                }
        }
    }

    // MARK: - Pick a date

    private var exploreSection: some View {
        let solar = solarDate(from: exploreDate)
        return VStack(alignment: .leading, spacing: 12) {
            Label("home_pick_date", systemImage: "calendar")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.primary)

            DatePicker(
                "",
                selection: $exploreDate,
                in: supportedDateRange,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(theme.primary)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)

            compactDayCard(for: solar, subtitle: "home_selected_day")
                .onTapGesture {
                    sheetSolar = solar
                }

            Button {
                sheetSolar = solar
            } label: {
                Label("home_view_details", systemImage: "arrow.right.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(theme.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Quote + share

    private var quoteSection: some View {
        let quote = DailyQuotes.quote(for: Date(), languageCode: language.language.rawValue)
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundStyle(theme.primary)
                Text("daily_quote_title")
                    .font(.headline)
                Spacer()
                ShareLink(item: sharePayload(quote: quote), subject: Text("daily_quote_title")) {
                    Label("home_share_quote", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.primary)
                }
            }
            Text(quote)
                .font(.body)
                .foregroundStyle(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("daily_quote_text")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(uiColor: .secondarySystemBackground))
                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
        )
    }

    private func sharePayload(quote: String) -> String {
        let fmt = DateFormatter()
        fmt.locale = locale
        fmt.timeZone = vietnamCalendar.timeZone
        fmt.dateStyle = .full
        let dateLine = fmt.string(from: Date())
        return "\(quote)\n\n— \(dateLine)\n\(localizedKey("home_share_footer"))"
    }

    // MARK: - Cards

    private func heroCard(for solar: SolarDate) -> some View {
        let lunar = engine.solarToLunar(date: solar)
        let hoangDao = engine.isHoangDao(date: solar)
        let canChi = engine.canChi(date: solar)
        let term = engine.tietKhi(date: solar)
        let date = gregorianDate(from: solar)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(weekdayString(date))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(monthDayString(date))
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                }
                Spacer()
                statusOrb(hoangDao: hoangDao)
            }

            Divider().overlay(Color.white.opacity(0.25))

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(solar.day)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("/ \(solar.month)/\(solar.year)")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.85))
            }

            HStack(spacing: 12) {
                miniPill(icon: "moon.fill", text: lunarShortLine(lunar))
                miniPill(icon: "leaf.fill", text: term)
            }

            Text(canChi.day)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.95))

            HStack {
                Image(systemName: "hand.tap.fill")
                    .font(.caption)
                Text("home_tap_for_details")
                    .font(.caption)
            }
            .foregroundStyle(.white.opacity(0.75))
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: hoangDao
                            ? [theme.hoangDao.opacity(0.95), theme.hoangDao.opacity(0.65)]
                            : [theme.primary.opacity(0.92), theme.primary.opacity(0.72)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: hoangDao ? theme.hoangDao.opacity(0.35) : theme.primary.opacity(0.28), radius: 16, x: 0, y: 8)
    }

    private func compactDayCard(for solar: SolarDate, subtitle: LocalizedStringKey) -> some View {
        let lunar = engine.solarToLunar(date: solar)
        let hoangDao = engine.isHoangDao(date: solar)
        let canChi = engine.canChi(date: solar)

        return VStack(alignment: .leading, spacing: 12) {
            Text(subtitle)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(solar.day)/\(solar.month)/\(solar.year)")
                        .font(.title3.weight(.semibold))
                    Text(lunarShortLine(lunar))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(canChi.day)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(theme.primary)
                }
                Spacer()
                VStack(spacing: 6) {
                    Image(systemName: hoangDao ? "sun.max.fill" : "moon.fill")
                        .font(.title2)
                        .foregroundStyle(hoangDao ? theme.hoangDao : theme.hacDao)
                    Text(hoangDao ? "detail_hoangdao" : "detail_hacdao")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(hoangDao ? theme.hoangDao : theme.hacDao)
                }
            }
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.caption)
                Text("home_tap_for_details")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func statusOrb(hoangDao: Bool) -> some View {
        VStack(spacing: 4) {
            Text(hoangDao ? "home_good_day_short" : "home_bad_day_short")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.85))
            Text(hoangDao ? "detail_hoangdao" : "detail_hacdao")
                .font(.caption.weight(.heavy))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
        .accessibilityElement(children: .combine)
    }

    private func miniPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(.white.opacity(0.95))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.18))
        .clipShape(Capsule())
    }

    // MARK: - Formatting

    private func solarDate(from date: Date) -> SolarDate {
        let y = vietnamCalendar.component(.year, from: date)
        let m = vietnamCalendar.component(.month, from: date)
        let d = vietnamCalendar.component(.day, from: date)
        return SolarDate(year: y, month: m, day: d)
    }

    private func gregorianDate(from solar: SolarDate) -> Date {
        var comps = DateComponents()
        comps.year = solar.year
        comps.month = solar.month
        comps.day = solar.day
        return vietnamCalendar.date(from: comps) ?? Date()
    }

    private func weekdayString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = locale
        f.timeZone = vietnamCalendar.timeZone
        f.dateFormat = "EEEE"
        return f.string(from: date).capitalized(with: locale)
    }

    private func monthDayString(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = locale
        f.timeZone = vietnamCalendar.timeZone
        f.setLocalizedDateFormatFromTemplate("MMMMd")
        return f.string(from: date)
    }

    private func lunarShortLine(_ lunar: LunarDate) -> String {
        var s = "\(lunar.day)/\(lunar.month)/\(lunar.year)"
        if lunar.isLeapMonth { s += " " + localizedKey("detail_leap_suffix") }
        return s
    }

    private func localizedKey(_ key: String) -> String {
        guard let code = locale.language.languageCode?.identifier,
              let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, bundle: .main, comment: "")
        }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }

    private var supportedDateRange: ClosedRange<Date> {
        var c = vietnamCalendar
        let start = c.date(from: DateComponents(year: LunarEngine.supportedYearRange.lowerBound, month: 1, day: 1)) ?? Date()
        let end = c.date(from: DateComponents(year: LunarEngine.supportedYearRange.upperBound, month: 12, day: 31)) ?? Date()
        return start...end
    }
}
