//
//  WidgetService.swift
//  Maps spec: widgetService.ts — assemble WidgetData offline (LunarCore + quotes + zodiac JSON + optional sun).
//

import Foundation

enum WidgetService {
    /// Vietnam civil calendar for solar/lunar alignment with the rest of the app.
    static var vietnamCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return c
    }

    private static func solarDate(from date: Date, calendar: Calendar) -> SolarDate {
        let y = calendar.component(.year, from: date)
        let m = calendar.component(.month, from: date)
        let d = calendar.component(.day, from: date)
        return SolarDate(year: y, month: m, day: d)
    }

    private static func formatLunar(_ lunar: LunarDate, languageCode: String) -> String {
        let leap = lunar.isLeapMonth ? (languageCode == "vi" ? " (nhuận)" : " (leap)") : ""
        if languageCode == "vi" {
            return String(format: "%d/%d/%d%@", lunar.day, lunar.month, lunar.year, leap)
        }
        return String(format: "%d/%d/%d%@", lunar.day, lunar.month, lunar.year, leap)
    }

    /// Vietnamese Chi labels → common English pinyin (for `en` widget language).
    private static let chiHourViToEn: [String: String] = [
        "Tý": "Zi", "Sửu": "Chou", "Dần": "Yin", "Mão": "Mao", "Thìn": "Chen", "Tỵ": "Si",
        "Ngọ": "Wu", "Mùi": "Wei", "Thân": "Shen", "Dậu": "You", "Tuất": "Xu", "Hợi": "Hai",
    ]

    private static func localizedGoodHours(_ lines: [String], languageCode: String) -> [String] {
        guard languageCode == "en" else { return lines }
        return lines.map { line in
            for (vi, en) in chiHourViToEn {
                if line.hasPrefix(vi) {
                    let rest = line.dropFirst(vi.count)
                    return en + rest
                }
            }
            return line
        }
    }

    private static func formatSolar(_ solar: SolarDate, languageCode: String) -> String {
        if languageCode == "vi" {
            return String(format: "%d/%d/%d", solar.day, solar.month, solar.year)
        }
        return String(format: "%d/%d/%d", solar.month, solar.day, solar.year)
    }

    // MARK: - Public API

    static func getSunTimes(latitude: Double, longitude: Double, date: Date, calendar: Calendar = WidgetService.vietnamCalendar) -> SunTimes? {
        let solar = solarDate(from: date, calendar: calendar)
        return SunTimeCalculator.sunTimes(
            latitude: latitude,
            longitude: longitude,
            year: solar.year,
            month: solar.month,
            day: solar.day
        )
    }

    static func getZodiacForDate(_ date: Date, languageCode: String, engine: LunarEngine = LunarEngine(), calendar: Calendar = WidgetService.vietnamCalendar) -> ZodiacDaily {
        let solar = solarDate(from: date, calendar: calendar)
        let lunar = engine.solarToLunar(date: solar)
        let branch = ZodiacCatalog.yearBranchIndex(lunarYear: lunar.year)
        let animal = ZodiacCatalog.animalName(branchIndex: branch, languageCode: languageCode)
        let variant = DailyQuotes.dayIndex(for: date, calendar: calendar)
        let summary = ZodiacCatalog.summary(branchIndex: branch, languageCode: languageCode, variantIndex: variant)
        let score = 1 + ((variant % 5) + 5) % 5
        return ZodiacDaily(branchIndex: branch, animalName: animal, score: score, summary: summary)
    }

    static func getWidgetData(
        date: Date,
        latitude: Double? = nil,
        longitude: Double? = nil,
        languageCode: String,
        engine: LunarEngine = LunarEngine(),
        calendar: Calendar = WidgetService.vietnamCalendar
    ) -> WidgetData {
        let solar = solarDate(from: date, calendar: calendar)
        let lunar = engine.solarToLunar(date: solar)
        let hours = localizedGoodHours(engine.goodHours(date: solar), languageCode: languageCode)
        let quote = DailyQuotes.quote(for: date, languageCode: languageCode, calendar: calendar)
        let z = getZodiacForDate(date, languageCode: languageCode, engine: engine, calendar: calendar)

        var rise: String?
        var set: String?
        if let lat = latitude, let lng = longitude {
            let st = getSunTimes(latitude: lat, longitude: lng, date: date, calendar: calendar)
            rise = st?.sunrise
            set = st?.sunset
        }

        return WidgetData(
            lunarDate: formatLunar(lunar, languageCode: languageCode),
            solarDate: formatSolar(solar, languageCode: languageCode),
            goodHours: hours,
            quote: quote,
            zodiacScore: z.score,
            zodiacSummary: "\(z.animalName) · \(z.summary)",
            sunrise: rise,
            sunset: set
        )
    }

    /// Reads optional saved coordinates from the App Group (set by the main app when you add a location picker).
    static func savedCoordinates() -> (lat: Double, lng: Double)? {
        let d = UserDefaults(suiteName: SharedConfig.appGroupId)
        guard let d,
              d.object(forKey: SharedConfig.widgetLatitudeKey) != nil,
              d.object(forKey: SharedConfig.widgetLongitudeKey) != nil else { return nil }
        return (d.double(forKey: SharedConfig.widgetLatitudeKey), d.double(forKey: SharedConfig.widgetLongitudeKey))
    }
}
