# Widget Extension Suggestions

## iOS (WidgetKit)

1. **Target**
   - Add a Widget Extension target to the Xcode project (File → New → Target → Widget Extension).
   - Use "Accessory Widget" for lock screen + "Inline" / "Rectangular" for home screen.

2. **Dependencies**
   - Widget extension can depend on the same **LunarCore** Swift package (no UIKit in core).
   - In the widget target, add LunarCore as a dependency; use only `SolarDate`, `LunarDate`, `LunarEngine`.

3. **Data**
   - Widget runs in a separate process. Pass **no** live data from the app; recompute in the widget using `LunarEngine()`.
   - For "today" use `Calendar.current` in the widget’s time zone (or fix GMT+7 in code) to get year/month/day, then call `engine.solarToLunar(date:)`, `engine.tietKhi(date:)`, `engine.isHoangDao(date:)`, `engine.goodHours(date:)`.

4. **Content**
   - **Small/Compact**: Today’s lunar date (e.g. "15/2 Âm lịch") + Hoàng Đạo / Hắc Đạo.
   - **Medium**: Add Tiết Khí + first 2–3 good hours.
   - **Lock screen (circular)**: Lunar day number or Hoàng Đạo yes/no.

5. **Refreshes**
   - Use `TimelineProvider` with entries for today (and optionally tomorrow). Use `.atEnd` for next midnight so the widget refreshes once per day. No network; all entries computed from `LunarEngine`.

6. **Performance**
   - Keep timeline to 2–3 entries (e.g. today 00:00, tomorrow 00:00). Each entry’s content should be computed in &lt;1 ms (LunarCore is built for that).

---

## Android (Glance / App Widgets)

1. **Module**
   - Widget code can live in the same `app` module or a separate `widget` module that depends on `lunarcore`. No Context needed in core; only in the widget for `Calendar`/timezone if you want local "today".

2. **Compose for Glance**
   - Use **Glance** (Compose for widgets) with `GlanceAppWidget` and `GlanceComposable`. In the composable, get "today" (e.g. `LocalDate.now()` or fixed GMT+7), build `SolarDate`, then call `LunarEngine().solarToLunar(...)`, `tietKhi`, `isHoangDao`, `goodHours`.

3. **Content**
   - **4×1 / 2×2**: Lunar date + Hoàng Đạo status.
   - **4×2**: Add Tiết Khí + good hours (abbreviated).

4. **Updates**
   - Use `updatePeriodMillis` (e.g. 24h) or `WorkManager` one-shot at midnight to refresh. No network; all state from `LunarEngine` in process.

5. **Performance**
   - Compute once per update in the widget provider; avoid doing work on the main thread if you do heavy work (LunarEngine is fast enough that it’s acceptable on main for 1–2 dates).

---

## Shared Notes

- **Offline**: Widgets must never call network or APIs; use only LunarCore.
- **Timezone**: Document that displayed day is GMT+7 (Vietnam); if the user’s device is in another time zone, "today" in the widget may differ from Vietnam calendar date unless you explicitly use a fixed GMT+7 "today" in code.
- **Testing**: Reuse the same Tet/round-trip/solar-term unit tests; widget code paths that call `LunarEngine` are covered by those tests.
