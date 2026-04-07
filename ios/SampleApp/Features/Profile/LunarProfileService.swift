//
//  LunarProfileService.swift
//  Conversion + zodiac + element + compatibility logic.
//

import Foundation

enum LunarProfileService {
    private static let zodiacAnimals = ["Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi", "Thân", "Dậu", "Tuất", "Hợi"]

    private static var vietnamCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return c
    }

    // MARK: - 2. Lunar conversion
    static func convertSolarToLunar(date: Date) -> ProfileLunarDate {
        let lunar = LunarService.convertSolarToLunar(date: date)
        return ProfileLunarDate(day: lunar.day, month: lunar.month, year: lunar.year)
    }

    // MARK: - 3. Zodiac & element
    static func getZodiac(year: Int) -> String {
        let i = ((year - 4) % 12 + 12) % 12
        return zodiacAnimals[i]
    }

    static func getElement(year: Int) -> Element {
        ElementService.shared.getElementFromYear(year: year)
    }

    // MARK: - 2,3,4,5,6,7 Can-Chi compatibility engine
    static func getCanChi(year: Int) -> CanChi {
        LunarService.getCanChi(year: year)
    }

    static func getElement(from stem: HeavenlyStem) -> Element {
        ElementService.shared.getElement(from: stem)
    }

    static func calculateStemScore(a: HeavenlyStem, b: HeavenlyStem) -> Int {
        let ea = getElement(from: a)
        let eb = getElement(from: b)
        if generates(ea, eb) || generates(eb, ea) { return 25 }
        if ea == eb { return 20 }
        // Same polarity (both even or both odd) tends to align pace better than mixed polarity.
        let samePolarity = (a.rawValue % 2) == (b.rawValue % 2)
        if samePolarity { return 12 }
        return 5
    }

    static func calculateBranchScore(a: EarthlyBranch, b: EarthlyBranch) -> Int {
        if sameTamHop(a, b) { return 30 }
        if lucXung(a, b) { return 5 }
        if lucHai(a, b) { return 10 }
        if a == b { return 26 }
        return 20
    }

    static func calculateElementScore(a: Element, b: Element) -> Int {
        if generates(a, b) || generates(b, a) { return 25 }
        if a == b { return 20 }
        if conflicts(a, b) || conflicts(b, a) { return 5 }
        return 15
    }

    static func calculateCompatibility(yearA: Int, yearB: Int) -> CompatibilityScore {
        let canChiA = getCanChi(year: yearA)
        let canChiB = getCanChi(year: yearB)
        let stemScore = calculateStemScore(a: canChiA.stem, b: canChiB.stem)
        let branchScore = calculateBranchScore(a: canChiA.branch, b: canChiB.branch)
        let elementScore = calculateElementScore(a: getElement(from: canChiA.stem), b: getElement(from: canChiB.stem))
        let total = stemScore + branchScore + elementScore
        let summary: String
        switch total {
        case 85 ... 100: summary = "Excellent match with strong long-term potential."
        case 70 ..< 85: summary = "Good match with healthy complementary traits."
        case 55 ..< 70: summary = "Balanced match that can improve with communication."
        case 40 ..< 55: summary = "Mixed compatibility, needs patience and adjustment."
        default: summary = "Challenging match, but still workable with effort."
        }
        return CompatibilityScore(
            total: max(0, min(100, total)),
            stemScore: stemScore,
            branchScore: branchScore,
            elementScore: elementScore,
            summary: summary
        )
    }

    // MARK: - 8. Bridge to Profile UI model
    static func calculateCompatibility(a: UserProfile, b: UserProfile, languageCode: String) -> CompatibilityResult {
        var strengths: [String] = []
        var weaknesses: [String] = []

        let score = calculateCompatibility(yearA: a.birthDateLunar.year, yearB: b.birthDateLunar.year)
        let canChiA = getCanChi(year: a.birthDateLunar.year)
        let canChiB = getCanChi(year: b.birthDateLunar.year)

        if score.branchScore >= 30 {
            strengths.append(tr("profile_strength_zodiac_strong", languageCode: languageCode))
        } else if score.branchScore >= 20 {
            strengths.append(tr("profile_strength_zodiac_moderate", languageCode: languageCode))
        } else {
            weaknesses.append(tr("profile_weakness_zodiac_conflict", languageCode: languageCode))
        }

        if score.elementScore >= 25 {
            strengths.append(tr("profile_strength_element_strong", languageCode: languageCode))
        } else if score.elementScore >= 15 {
            strengths.append(tr("profile_strength_element_moderate", languageCode: languageCode))
        } else {
            weaknesses.append(tr("profile_weakness_element_conflict", languageCode: languageCode))
        }

        if strengths.isEmpty { strengths.append(tr("profile_strength_base_stable", languageCode: languageCode)) }
        if weaknesses.isEmpty { weaknesses.append(tr("profile_weakness_no_major", languageCode: languageCode)) }

        let summary: String
        switch score.total {
        case 85 ... 100: summary = tr("profile_summary_excellent", languageCode: languageCode)
        case 70 ..< 85: summary = tr("profile_summary_good", languageCode: languageCode)
        case 55 ..< 70: summary = tr("profile_summary_balanced", languageCode: languageCode)
        case 40 ..< 55: summary = tr("profile_summary_mixed", languageCode: languageCode)
        default: summary = tr("profile_summary_challenging", languageCode: languageCode)
        }
        let explanation = buildExplanation(score: score, languageCode: languageCode)
        let insights = personalityInsights(a: a, b: b, canChiA: canChiA, canChiB: canChiB, languageCode: languageCode)
        return CompatibilityResult(
            score: score.total,
            stemScore: score.stemScore,
            branchScore: score.branchScore,
            elementScore: score.elementScore,
            summary: summary,
            explanation: explanation,
            insights: insights,
            strengths: strengths,
            weaknesses: weaknesses
        )
    }

    private static func tr(_ key: String, languageCode: String) -> String {
        let locale = Locale(identifier: languageCode == "vi" ? "vi_VN" : "en_US")
        return String(localized: String.LocalizationValue(key), bundle: .main, locale: locale)
    }

    private static let tamHopGroups: [Set<EarthlyBranch>] = [
        [.than, .ty, .thin],
        [.ty2, .dau, .suu],
        [.dan, .ngo, .tuat],
        [.hoi, .mao, .mui],
    ]

    private static let lucXungPairs: Set<Set<EarthlyBranch>> = [
        [.ty, .ngo],
        [.suu, .mui],
        [.dan, .than],
        [.mao, .dau],
        [.thin, .tuat],
        [.ty2, .hoi],
    ]

    private static let lucHaiPairs: Set<Set<EarthlyBranch>> = [
        [.ty, .mui],
        [.suu, .ngo],
        [.dan, .ty2],
        [.mao, .thin],
        [.than, .hoi],
        [.dau, .tuat],
    ]

    private static func sameTamHop(_ a: EarthlyBranch, _ b: EarthlyBranch) -> Bool {
        tamHopGroups.contains { $0.contains(a) && $0.contains(b) }
    }

    private static func lucXung(_ a: EarthlyBranch, _ b: EarthlyBranch) -> Bool {
        lucXungPairs.contains([a, b])
    }

    private static func lucHai(_ a: EarthlyBranch, _ b: EarthlyBranch) -> Bool {
        lucHaiPairs.contains([a, b])
    }

    private static let generating: [Element: Element] = [
        .moc: .hoa,
        .hoa: .tho,
        .tho: .kim,
        .kim: .thuy,
        .thuy: .moc,
    ]

    private static let conflicting: [Element: Element] = [
        .moc: .tho,
        .tho: .thuy,
        .thuy: .hoa,
        .hoa: .kim,
        .kim: .moc,
    ]

    private static func generates(_ a: Element, _ b: Element) -> Bool {
        generating[a] == b
    }

    private static func conflicts(_ a: Element, _ b: Element) -> Bool {
        conflicting[a] == b
    }

    private static func buildExplanation(score: CompatibilityScore, languageCode: String) -> String {
        if languageCode == "vi" {
            return "Điểm Can \(score.stemScore)/25, Chi \(score.branchScore)/30, ngũ hành \(score.elementScore)/25. " +
                "Tổng \(score.total)/100 cho thấy mức hòa hợp tổng thể và cách hai người phối hợp trong nhịp sống hằng ngày."
        }
        return "Stem \(score.stemScore)/25, Branch \(score.branchScore)/30, Element \(score.elementScore)/25. " +
            "Total \(score.total)/100 reflects overall harmony and day-to-day compatibility rhythm."
    }

    private static func personalityInsights(
        a: UserProfile,
        b: UserProfile,
        canChiA: CanChi,
        canChiB: CanChi,
        languageCode: String
    ) -> [String] {
        let eA = getElement(from: canChiA.stem)
        let eB = getElement(from: canChiB.stem)
        var out: [String] = []
        if languageCode == "vi" {
            out.append("\(a.name): thiên về \(elementTraitVi(eA)); \(b.name): thiên về \(elementTraitVi(eB)).")
            if generates(eA, eB) || generates(eB, eA) {
                out.append("Hai mệnh có xu hướng hỗ trợ nhau tự nhiên, dễ phân vai khi làm việc chung.")
            } else if conflicts(eA, eB) || conflicts(eB, eA) {
                out.append("Hai mệnh dễ khác nhịp quyết định; nên thống nhất nguyên tắc giao tiếp từ sớm.")
            } else {
                out.append("Năng lượng hai mệnh khá trung tính, phù hợp xây nền tảng ổn định từng bước.")
            }
            if sameTamHop(canChiA.branch, canChiB.branch) {
                out.append("Địa chi cùng tam hợp: dễ đồng điệu mục tiêu dài hạn.")
            } else if lucXung(canChiA.branch, canChiB.branch) {
                out.append("Địa chi lục xung: nên tránh phản ứng nóng khi bất đồng.")
            }
        } else {
            out.append("\(a.name) leans \(elementTraitEn(eA)); \(b.name) leans \(elementTraitEn(eB)).")
            if generates(eA, eB) || generates(eB, eA) {
                out.append("Your elements naturally support each other, making role sharing easier.")
            } else if conflicts(eA, eB) || conflicts(eB, eA) {
                out.append("Element rhythm can clash; align communication rules early.")
            } else {
                out.append("Element energy is neutral, good for building a steady foundation.")
            }
            if sameTamHop(canChiA.branch, canChiB.branch) {
                out.append("Branches are in the same trine group, often aligned on long-term goals.")
            } else if lucXung(canChiA.branch, canChiB.branch) {
                out.append("Branch clash suggests avoiding reactive decisions during conflicts.")
            }
        }
        return out
    }

    private static func elementTraitVi(_ element: Element) -> String {
        switch element {
        case .kim: return "kỷ luật và dứt khoát"
        case .moc: return "linh hoạt và phát triển"
        case .thuy: return "thích nghi và quan sát"
        case .hoa: return "nhiệt huyết và chủ động"
        case .tho: return "ổn định và thực tế"
        }
    }

    private static func elementTraitEn(_ element: Element) -> String {
        switch element {
        case .kim: return "disciplined and decisive"
        case .moc: return "growth-oriented and flexible"
        case .thuy: return "adaptive and observant"
        case .hoa: return "energetic and proactive"
        case .tho: return "grounded and practical"
        }
    }

    static func makeProfile(name: String, birthDateSolar: Date) -> UserProfile {
        let lunar = convertSolarToLunar(date: birthDateSolar)
        let zodiac = getZodiac(year: lunar.year)
        // Uses lunar year. `adjustYearForLunar` exists in `LunarService` as a replaceable fallback hook.
        let element = getElement(year: lunar.year)
        return UserProfile(
            name: name,
            birthDateSolar: birthDateSolar,
            birthDateLunar: lunar,
            zodiac: zodiac,
            element: element
        )
    }
}
