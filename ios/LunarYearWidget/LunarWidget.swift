//
//  LunarWidget.swift
//  Minimal / standard / advanced layouts by widget family (offline lunar data).
//

import SwiftUI
import WidgetKit

struct LunarWidgetEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
    let languageCode: String
}

struct LunarWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> LunarWidgetEntry {
        LunarWidgetEntry(
            date: Date(),
            data: WidgetData(
                lunarDate: "1/1/2025",
                solarDate: "1/29/2025",
                goodHours: ["Dần (3h-5h)", "Thìn (7h-9h)"],
                quote: "…",
                zodiacScore: 3,
                zodiacSummary: "Rat · …",
                sunrise: "06:10",
                sunset: "17:45"
            ),
            languageCode: "en"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (LunarWidgetEntry) -> Void) {
        completion(entry(for: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LunarWidgetEntry>) -> Void) {
        let now = Date()
        let cal = Calendar.current
        let entry = entry(for: now)
        let startTomorrow = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: now) ?? now)
        completion(Timeline(entries: [entry], policy: .after(startTomorrow)))
    }

    private func entry(for date: Date) -> LunarWidgetEntry {
        let lang = WidgetLocalized.deviceLanguageCode()
        let c = WidgetService.savedCoordinates()
        let data = WidgetService.getWidgetData(
            date: date,
            latitude: c?.lat,
            longitude: c?.lng,
            languageCode: lang
        )
        return LunarWidgetEntry(date: date, data: data, languageCode: lang)
    }
}

// MARK: - Views by tier

struct WidgetMinimalView: View {
    let data: WidgetData
    var languageCode: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "moon.fill")
                    .font(.caption2)
                    .foregroundStyle(.primary.opacity(0.8))
                Text(WidgetLocalized.format("widget_lunar_format", languageCode: languageCode, data.lunarDate))
                    .font(.caption.weight(.semibold))
                    .contentTransition(.opacity)
            }
            Text(WidgetLocalized.format("widget_solar_format", languageCode: languageCode, data.solarDate))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .contentTransition(.opacity)
            Text(data.quote)
                .font(.caption2)
                .lineLimit(4)
                .minimumScaleFactor(0.85)
                .foregroundStyle(.primary.opacity(0.95))
                .contentTransition(.opacity)
            Spacer(minLength: 0)
        }
    }
}

struct WidgetStandardView: View {
    let data: WidgetData
    var languageCode: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Label {
                        Text(WidgetLocalized.format("widget_lunar_format", languageCode: languageCode, data.lunarDate))
                    } icon: {
                        Image(systemName: "moon.stars.fill")
                    }
                    .font(.caption.weight(.semibold))
                    .contentTransition(.opacity)
                    Text(WidgetLocalized.format("widget_solar_format", languageCode: languageCode, data.solarDate))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .contentTransition(.opacity)
                }
                Spacer()
                if let s = data.zodiacScore {
                    VStack(alignment: .trailing, spacing: 2) {
                        starRow(score: s)
                        Text(shortZodiac(data))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            Text(data.quote)
                .font(.footnote)
                .lineLimit(3)
                .foregroundStyle(.primary.opacity(0.95))
                .contentTransition(.opacity)
            if !data.goodHours.isEmpty {
                Text(data.goodHours.prefix(3).joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
            Spacer(minLength: 0)
        }
    }

    private func shortZodiac(_ d: WidgetData) -> String {
        d.zodiacSummary?.split(separator: "·").first.map(String.init)?.trimmingCharacters(in: .whitespaces) ?? ""
    }

    private func starRow(score: Int) -> some View {
        HStack(spacing: 1) {
            ForEach(0 ..< 5, id: \.self) { i in
                Image(systemName: i < score ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(i < score ? Color.yellow : Color.secondary.opacity(0.35))
            }
        }
    }
}

struct WidgetAdvancedView: View {
    let data: WidgetData
    var languageCode: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(WidgetLocalized.format("widget_lunar_format", languageCode: languageCode, data.lunarDate))
                        .font(.subheadline.weight(.semibold))
                        .contentTransition(.opacity)
                    Text(WidgetLocalized.format("widget_solar_format", languageCode: languageCode, data.solarDate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .contentTransition(.opacity)
                }
                Spacer()
                if let s = data.zodiacScore {
                    VStack(alignment: .trailing, spacing: 4) {
                        HStack(spacing: 2) {
                            ForEach(0 ..< 5, id: \.self) { i in
                                Image(systemName: i < s ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundStyle(i < s ? Color.yellow : Color.secondary.opacity(0.35))
                            }
                        }
                        if let z = data.zodiacSummary {
                            Text(z)
                                .font(.caption2)
                                .multilineTextAlignment(.trailing)
                                .lineLimit(4)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            if let r = data.sunrise, let st = data.sunset {
                Label {
                    Text(WidgetLocalized.format("widget_sunrise_sunset_format", languageCode: languageCode, r, st))
                } icon: {
                    Image(systemName: "sun.horizon.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
            }
            Text(data.quote)
                .font(.footnote)
                .lineLimit(3)
                .foregroundStyle(.primary.opacity(0.95))
                .contentTransition(.opacity)
            Text(WidgetLocalized.string("widget_good_hours_section", languageCode: languageCode))
                .font(.caption.weight(.semibold))
            Text(data.goodHours.joined(separator: " · "))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial.opacity(0.8), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            Spacer(minLength: 0)
        }
    }
}

struct LunarWidgetView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme
    let entry: LunarWidgetEntry

    private var colors: AppThemeColors {
        let raw = AppGroupPreferences.string(forKey: SharedConfig.themeAccentKey)
        let accent = AccentTheme(rawValue: raw ?? "") ?? .terracotta
        return AppThemeColors.palette(accent)
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                WidgetMinimalView(data: entry.data, languageCode: entry.languageCode)
            case .systemMedium:
                WidgetStandardView(data: entry.data, languageCode: entry.languageCode)
            case .systemLarge:
                WidgetAdvancedView(data: entry.data, languageCode: entry.languageCode)
            default:
                WidgetStandardView(data: entry.data, languageCode: entry.languageCode)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(.easeInOut(duration: 0.35), value: entry.data.lunarDate)
        .animation(.easeInOut(duration: 0.35), value: entry.data.quote)
        .modifier(LunarWidgetBackground(colors: colors, colorScheme: colorScheme, date: entry.date))
    }
}

private struct LunarWidgetBackground: ViewModifier {
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
                            startRadius: 8,
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

struct LunarDayWidget: Widget {
    let kind = "LunarDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LunarWidgetProvider()) { entry in
            LunarWidgetView(entry: entry)
        }
        .configurationDisplayName(Text("widget_lunar_day_title"))
        .description(Text("widget_lunar_day_description"))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
