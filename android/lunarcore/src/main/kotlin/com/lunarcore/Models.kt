/**
 * Vietnamese Lunar Calendar — Solar and Lunar date types.
 * All dates in GMT+7 (Vietnam). No Android Context dependency.
 */
package com.lunarcore

/**
 * Gregorian calendar date in Vietnam timezone (GMT+7).
 * Year range supported: 1900–2100.
 */
data class SolarDate(
    val year: Int,
    val month: Int,  // 1–12
    val day: Int     // 1–31
)

/**
 * Vietnamese lunar calendar date.
 * Month 1 is the month containing Lập Xuân (Beginning of Spring).
 */
data class LunarDate(
    val year: Int,
    val month: Int,   // 1–12 (or 1–13 with leap)
    val day: Int,     // 1–29 or 1–30
    val isLeapMonth: Boolean = false
)
