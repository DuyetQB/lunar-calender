# Vietnamese Lunar Calendar — Architecture

## Overview

Offline-first, formula-based Vietnamese lunisolar calendar. All calculations use **astronomical formulas** (Julian day, mean new moon, sun longitude). No lookup tables for core conversions; timezone is **GMT+7** (Vietnam). Solar date range: **1900–2100**.

## Conceptual Layers

```
LunarEngine (facade)
├── JulianDateConverter     — Gregorian ↔ Julian Day Number (UTC then shift to GMT+7)
├── AstronomicalCalculator — Constants (obliquity, etc.) and shared helpers
├── NewMoonCalculator       — Mean new moon JDN for a given lunation
├── SunLongitudeCalculator  — Sun's ecliptic longitude (for solar terms)
├── LunarConverter          — Solar ↔ Lunar using new moons + solar terms
├── CanChiCalculator        — Heavenly Stems + Earthly Branches (day, month, year)
├── HoangDaoCalculator      — Hoàng Đạo / Hắc Đạo from day's Chi
└── TietKhiCalculator       — 24 solar terms (Tiết Khí) from sun longitude
```

- **JulianDateConverter**: Convert (year, month, day, hour in GMT+7) ↔ Julian Day Number. All internal times are in GMT+7 noon/midnight where needed.
- **NewMoonCalculator**: Compute JDN of new moon (mean lunation); used to list lunar months and assign lunar day from solar date.
- **SunLongitudeCalculator**: From JDN, compute sun's longitude (λ). Used for Tiết Khí and for deciding lunar month 1 (month containing 立春 Lập Xuân, λ ≈ 315°).
- **LunarConverter**: Uses new moons + “month 1” rule and leap-month rule to convert Solar ↔ Lunar.
- **CanChiCalculator**: Can (Thiên Can) and Chi (Địa Chi) for day (from JDN), month (lunar month + year stem), year (year stem/branch).
- **HoangDaoCalculator**: From day’s Chi, determine if day is Hoàng Đạo or Hắc Đạo; same logic gives good hours (Giờ Hoàng Đạo).
- **TietKhiCalculator**: From sun longitude, return current/next solar term and list of 24 terms for the year.

## Data Types

- **SolarDate**: `year`, `month`, `day` (Gregorian), optional `hour` for time-of-day (GMT+7).
- **LunarDate**: `year`, `month`, `day`, `isLeapMonth` (năm, tháng, ngày, tháng nhuận).

## Day Boundary for Can Chi

- **Day pillar (Can Chi of day)**: In Vietnamese/Chinese tradition, the “day” for Can Chi often starts at **23:00** (11 PM) local time (start of hour Tý). The implementation uses **23:00 GMT+7** as the boundary: times before 23:00 use the current solar day’s JDN; from 23:00 onward use the next solar day for the day pillar.

## Solar Terms (24 Tiết Khí)

- Defined by sun’s ecliptic longitude in 15° steps: 0° (Xuân Phân), 15°, 30°, … 345°.
- Names: Lập Xuân, Vũ Thủy, Kinh Trập, … (Vietnamese names used in code).
- Used to:
  - Define lunar month 1 (first month with 立春 Lập Xuân).
  - Answer “current Tiết Khí” for a given solar date.

## Hoàng Đạo / Hắc Đạo

- Each solar day has a “day Chi” (one of 12 branches). Six of the 12 two-hour periods (giờ) are Hoàng Đạo, six are Hắc Đạo, in a fixed pattern per Chi.
- Good hours (Giờ Hoàng Đạo): the 6 two-hour slots that are Hoàng Đạo for that day.

## Evaluation (Good for / Avoid)

- Simple rule-based: e.g. Hoàng Đạo + good Tiết Khí → “good for” wedding, groundbreaking, opening business; Hắc Đạo or certain terms → “avoid” funeral, travel, construction. Implemented as a small rule set in the engine.

## Platform Layout

- **iOS**: Pure Swift package `LunarCore` (no UIKit). App target uses SwiftUI (calendar grid + detail).
- **Android**: Pure Kotlin module `lunarcore` (no Android SDK in core). App uses Jetpack Compose (month grid + detail).
- **Shared**: Same algorithm design and formulas; code is duplicated in Swift and Kotlin for zero dependencies and best performance on each platform.

## Performance and Testing

- Target: **&lt; 1 ms** per conversion; no network, no reflection, no heavy allocations.
- Unit tests: Tet dates (solar ↔ lunar), random dates, solar term boundaries, Can Chi consistency, Hoàng Đạo hours.
