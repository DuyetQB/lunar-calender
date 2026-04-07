//
//  QuoteWidget.swift
//  Home screen widget: quote + theme from App Group; iOS 17+ uses `containerBackground(for:)`.
//

import SwiftUI
import WidgetKit

struct QuoteEntry: TimelineEntry {
    let date: Date
    let text: String
    let title: String
}

struct QuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        let languageCode = WidgetLocalized.deviceLanguageCode()
        return QuoteEntry(
            date: Date(),
            text: "…",
            title: WidgetLocalized.string("widget_quote_header", languageCode: languageCode)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let now = Date()
        let cal = Calendar.current
        let entry = entry(for: now)
        let startTomorrow = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: now) ?? now)
        completion(Timeline(entries: [entry], policy: .after(startTomorrow)))
    }

    private func entry(for date: Date) -> QuoteEntry {
        let lang = WidgetLocalized.deviceLanguageCode()
        let text = DailyQuotes.quote(for: date, languageCode: lang)
        let title = WidgetLocalized.string("widget_quote_header", languageCode: lang)
        return QuoteEntry(date: date, text: text, title: title)
    }
}

struct QuoteWidgetView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme
    let entry: QuoteEntry

    private var colors: AppThemeColors {
        let raw = UserDefaults(suiteName: SharedConfig.appGroupId)?.string(forKey: SharedConfig.themeAccentKey)
        let accent = AccentTheme(rawValue: raw ?? "") ?? .terracotta
        return AppThemeColors.palette(accent)
    }

    var body: some View {
        content
            .animation(.easeInOut(duration: 0.35), value: entry.text)
            .animation(.easeInOut(duration: 0.35), value: entry.title)
            .modifier(WidgetContainerBackground(colors: colors, colorScheme: colorScheme, date: entry.date))
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .font(.caption)
                    .foregroundStyle(colors.primary)
                    .padding(6)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Text(entry.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .contentTransition(.opacity)
            }
            Text(entry.text)
                .font(family == .systemSmall ? .footnote : .body)
                .foregroundStyle(.primary)
                .lineLimit(family == .systemSmall ? 5 : 8)
                .minimumScaleFactor(0.85)
                .contentTransition(.opacity)
                .padding(.top, 2)
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// iOS 17+: `containerBackground(for: .widget)` — full rounded container; iOS 16: legacy fill.
private struct WidgetContainerBackground: ViewModifier {
    let colors: AppThemeColors
    let colorScheme: ColorScheme
    let date: Date

    private var gradientPoints: (start: UnitPoint, end: UnitPoint, highlight: UnitPoint) {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        switch day % 4 {
        case 0: return (.topLeading, .bottomTrailing, .topLeading)
        case 1: return (.leading, .trailing, .top)
        case 2: return (.top, .bottom, .trailing)
        default: return (.bottomLeading, .topTrailing, .leading)
        }
    }

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    ZStack {
                        LinearGradient(
                            colors: colors.widgetGradientColors(colorScheme: colorScheme),
                            startPoint: gradientPoints.start,
                            endPoint: gradientPoints.end
                        )
                        RadialGradient(
                            colors: [Color.white.opacity(colorScheme == .dark ? 0.10 : 0.18), .clear],
                            center: gradientPoints.highlight,
                            startRadius: 10,
                            endRadius: 220
                        )
                        ContainerRelativeShape()
                            .fill(.ultraThinMaterial.opacity(colorScheme == .dark ? 0.35 : 0.5))
                        ContainerRelativeShape()
                            .strokeBorder(.white.opacity(colorScheme == .dark ? 0.12 : 0.22), lineWidth: 0.8)
                    }
                }
        } else {
            content
                .background {
                    ZStack {
                        LinearGradient(
                            colors: colors.widgetGradientColors(colorScheme: colorScheme),
                            startPoint: gradientPoints.start,
                            endPoint: gradientPoints.end
                        )
                        ContainerRelativeShape()
                            .fill(colors.cardBackground.opacity(0.35))
                    }
                }
        }
    }
}

struct DailyQuoteWidget: Widget {
    let kind: String = "DailyQuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            QuoteWidgetView(entry: entry)
        }
        .configurationDisplayName(Text("widget_daily_quote_title"))
        .description(Text("widget_daily_quote_description"))
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
