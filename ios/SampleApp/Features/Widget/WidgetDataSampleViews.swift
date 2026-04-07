//
//  WidgetDataSampleViews.swift
//  In-app preview of the three widget tiers (not embedded in the widget extension).
//

import SwiftUI

@available(iOS 16.0, *)
struct WidgetDataSamplePanel: View {
    let data: WidgetData

    var body: some View {
        List {
            Section("Minimal (small)") {
                WidgetMinimalView(data: data, languageCode: "en")
                    .padding(.vertical, 8)
            }
            Section("Standard (medium)") {
                WidgetStandardView(data: data, languageCode: "en")
                    .padding(.vertical, 8)
            }
            Section("Advanced (large)") {
                WidgetAdvancedView(data: data, languageCode: "en")
                    .padding(.vertical, 8)
            }
        }
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview("Widget tiers") {
    let sample = WidgetData(
        lunarDate: "15/8/2025",
        solarDate: "10/7/2025",
        goodHours: ["Tý (23h-1h)", "Dần (3h-5h)", "Thìn (7h-9h)"],
        quote: "The moon waxes and wanes; so do we.",
        zodiacScore: 4,
        zodiacSummary: "Ox · Steady effort beats rushing.",
        sunrise: "05:42",
        sunset: "18:21"
    )
    return NavigationStack {
        WidgetDataSamplePanel(data: sample)
            .navigationTitle("Widget preview")
    }
}
#endif
