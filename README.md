# Vietnamese Lunar Calendar (Offline)

Offline Vietnamese Lunar Calendar core logic and sample UIs for **iOS (Swift)** and **Android (Kotlin)**. All lunar calculations use local astronomical formulas; no network or APIs. Timezone: **GMT+7** (Vietnam). Solar date range: **1900–2100**.

## Architecture (short)

- **LunarEngine** is the facade. Under the hood:
  - **JulianDateConverter**: Gregorian ↔ Julian Day Number.
  - **NewMoonCalculator**: Mean new moon JDN per lunation.
  - **SunLongitudeCalculator**: Sun ecliptic longitude (for solar terms).
  - **LunarConverter**: Solar ↔ Lunar using new moons and principal solar terms (month 1 = month containing Lập Xuân).
  - **CanChiCalculator**: Thiên Can + Địa Chi (day, month, year).
  - **HoangDaoCalculator**: Hoàng Đạo / Hắc Đạo and good hours (Giờ Hoàng Đạo).
  - **TietKhiCalculator**: 24 solar terms (Tiết Khí).

See [ARCHITECTURE.md](ARCHITECTURE.md) for details.

## Features

1. Solar date ↔ Lunar date conversion  
2. Can Chi (day, month, year)  
3. Hoàng Đạo / Hắc Đạo  
4. 24 Solar Terms (Tiết Khí)  
5. Good hours (Giờ Hoàng Đạo)  
6. Simple evaluation: good for (wedding, groundbreaking, opening business) / avoid (funeral, travel, construction)

---

## iOS

### LunarCore (Swift package)

- **Path**: `ios/LunarCore/`
- Pure Swift; no UIKit in core.
- **Build**: `cd ios/LunarCore && swift build`
- **Test**: `swift test` (requires Xcode/CLT with XCTest/Swift Testing).

### Sample app (SwiftUI)

- **Path**: `ios/SampleApp/`
- **Screen 1**: Monthly calendar grid; tap a date → detail.
- **Screen 2**: Solar date, lunar date, Can Chi, Hoàng Đạo, good hours, suggested activities.

**Open in Xcode:** Open `ios/LunarYear.xcodeproj` in Xcode (from the repo root or from the `ios` folder). The project already links the local LunarCore package and includes the SampleApp sources. Select the LunarYear scheme and run on a simulator or device.

---

## Android

### lunarcore (Kotlin library)

- **Path**: `android/lunarcore/`
- Pure Kotlin; no Android SDK in core.
- **Test**: `./gradlew :lunarcore:test` (from `android/`).

### Sample app (Jetpack Compose)

- **Path**: `android/app/`
- **Screen 1**: Calendar month grid with prev/next; tap date → detail.
- **Screen 2**: Detail (solar, lunar, Can Chi, Hoàng Đạo, good hours, suggestions).

**Build**: from `android/` run `./gradlew assembleDebug` (ensure you have `gradle-wrapper.jar` and `gradle/wrapper/gradle-wrapper.properties`).

---

## Unit tests

- **iOS**: `ios/LunarCore/Tests/` — Tet conversion, random date round-trip, solar terms, performance (&lt;1 ms).
- **Android**: `android/lunarcore/src/test/` — Tet conversion, round-trip, solar terms.

---

## Widget extensions

See [WIDGET_SUGGESTIONS.md](WIDGET_SUGGESTIONS.md) for:

- iOS: WidgetKit, using LunarCore in the widget, timeline with no network.
- Android: Glance/App Widgets, same lunarcore, daily refresh.

---

## License

Use as needed for your project.
