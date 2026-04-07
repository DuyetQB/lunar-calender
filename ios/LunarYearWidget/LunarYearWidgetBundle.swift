//
//  LunarYearWidgetBundle.swift
//

import SwiftUI
import WidgetKit

@main
struct LunarYearWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyQuoteWidget()
        LunarDayWidget()
    }
}
