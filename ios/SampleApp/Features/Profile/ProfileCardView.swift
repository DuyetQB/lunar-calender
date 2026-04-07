//
//  ProfileCardView.swift
//

import SwiftUI

@available(iOS 16.0, *)
struct ProfileCardView: View {
    @Environment(\.appThemeColors) private var theme
    @Environment(\.locale) private var locale
    @Environment(\.colorScheme) private var colorScheme
    let profile: UserProfile
    var selectedOrder: Int? = nil

    private var solarString: String {
        let f = DateFormatter()
        f.locale = locale
        f.dateStyle = .medium
        return f.string(from: profile.birthDateSolar)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(profile.name)
                    .font(.headline.weight(.semibold))
                Spacer()
                Text(profile.zodiac)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.primary.opacity(0.12))
                    .clipShape(Capsule())
            }
            HStack(spacing: 12) {
                Label(profile.element.rawValue, systemImage: "sparkles")
                Label(solarString, systemImage: "calendar")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Text("profile_lunar_birth_format")
                Text("\(profile.birthDateLunar.day)/\(profile.birthDateLunar.month)/\(profile.birthDateLunar.year)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            ElementInfoView(year: profile.birthDateLunar.year)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : theme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(selectedOrder != nil ? theme.primary.opacity(0.45) : theme.primary.opacity(0.18), lineWidth: selectedOrder != nil ? 1.5 : 1)
        )
        .shadow(color: selectedOrder != nil ? theme.primary.opacity(0.22) : .black.opacity(colorScheme == .dark ? 0.25 : 0.08), radius: selectedOrder != nil ? 14 : 8, x: 0, y: selectedOrder != nil ? 6 : 3)
        .scaleEffect(selectedOrder != nil ? 1.01 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: selectedOrder)
    }
}

@available(iOS 16.0, *)
struct ElementInfoView: View {
    let year: Int

    private var info: (element: Element, napAm: NapAm) {
        ElementService.shared.getFullElementProfile(year: year)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("profile_element_title")
                .font(.subheadline.weight(.semibold))
                
            HStack(spacing: 6) {
                 Text("profile_basic_element_label")
                 .font(.subheadline.weight(.semibold))
                 Text(":")
                Text(icon(info.element))
                Text(info.element.rawValue)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(elementColor(info.element))
            }
            HStack(spacing: 6) {
                 Text("profile_napam_label")
                 .font(.subheadline.weight(.semibold))
                 Text(":")
                Text(icon(info.napAm.element))
            
                Text(info.napAm.name)
                    .font(.subheadline.weight(.medium))
            }
        }
         .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(elementColor(info.element).opacity(0.18), lineWidth: 1)
        )
    }

    private func icon(_ e: Element) -> String {
        switch e {
        case .kim: return "⚙️"
        case .moc: return "🌳"
        case .thuy: return "🌊"
        case .hoa: return "🔥"
        case .tho: return "🪨"
        }
    }

    private func elementColor(_ e: Element) -> Color {
        switch e {
        case .kim: return .gray
        case .moc: return .green
        case .thuy: return .blue
        case .hoa: return .red
        case .tho: return .brown
        }
    }
}

@available(iOS 16.0, *)
struct ElementCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    let profile: ElementProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(icon(profile.element)) \(profile.element.rawValue)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(elementColor(profile.element))
                Spacer()
            }
            Text(profile.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            chips(title: "element_traits_title", items: profile.personalityTraits)
            chips(title: "element_strengths_title", items: profile.strengths)
            chips(title: "element_weaknesses_title", items: profile.weaknesses)
            chips(title: "element_compatible_title", items: profile.compatibleWith.map(\.rawValue))
            chips(title: "element_incompatible_title", items: profile.incompatibleWith.map(\.rawValue))
            chips(title: "element_suggestions_title", items: profile.suggestions)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : Color(uiColor: .systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(elementColor(profile.element).opacity(0.25), lineWidth: 1)
        )
    }

    private func chips(title: LocalizedStringKey, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle().fill(elementColor(profile.element)).frame(width: 6, height: 6).padding(.top, 6)
                    Text(item).font(.subheadline)
                }
            }
        }
    }

    private func icon(_ e: Element) -> String {
        switch e {
        case .kim: return "⚪️"
        case .moc: return "🌿"
        case .thuy: return "💧"
        case .hoa: return "🔥"
        case .tho: return "🟤"
        }
    }

    private func elementColor(_ e: Element) -> Color {
        switch e {
        case .kim: return .gray
        case .moc: return .green
        case .thuy: return .blue
        case .hoa: return .red
        case .tho: return .brown
        }
    }
}
