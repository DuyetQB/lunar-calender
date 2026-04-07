//
//  CompatibilityView.swift
//

import SwiftUI

@available(iOS 16.0, *)
struct CompatibilityView: View {
    @Environment(\.appThemeColors) private var theme
    @Environment(\.colorScheme) private var colorScheme
    let a: UserProfile
    let b: UserProfile
    let result: CompatibilityResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    ProfileCardMini(name: a.name, zodiac: a.zodiac, element: a.element)
                    Image(systemName: "heart.fill").foregroundStyle(theme.primary)
                    ProfileCardMini(name: b.name, zodiac: b.zodiac, element: b.element)
                }

                ElementCardView(profile: ElementService.shared.getElementProfile(element: a.element))
                ElementCardView(profile: ElementService.shared.getElementProfile(element: b.element))

                VStack(alignment: .leading, spacing: 8) {
                    Text(String(format: String(localized: "profile_compatibility_score"), result.score))
                        .font(.title3.weight(.bold))
                    ProgressView(value: Double(result.score), total: 100)
                        .tint(theme.primary)
                        .scaleEffect(y: 1.18)
                        .animation(.easeInOut(duration: 0.45), value: result.score)
                    HStack(spacing: 12) {
                        Text("Can: \(result.stemScore)")
                        Text("Chi: \(result.branchScore)")
                        Text("Ngũ hành: \(result.elementScore)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    Text(result.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(result.explanation)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 16).fill(cardSurface))
                .overlay(
                    RoundedRectangle(cornerRadius: 16).stroke(theme.primary.opacity(0.14), lineWidth: 1)
                )

                infoBlock(title: "profile_insights_title", items: result.insights, color: theme.primary)

                infoBlock(title: "profile_strengths_title", items: result.strengths, color: theme.goodAccent)
                infoBlock(title: "profile_weaknesses_title", items: result.weaknesses, color: theme.avoidAccent)
            }
            .padding(16)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(uiColor: .systemBackground),
                    (colorScheme == .dark ? Color.black : theme.cardBackground).opacity(0.92),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle(Text("profile_compatibility_title"))
    }

    private func infoBlock(title: LocalizedStringKey, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle().fill(color).frame(width: 7, height: 7).padding(.top, 6)
                    Text(item).font(.subheadline)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(cardSurface))
        .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.18), lineWidth: 1)
        )
    }

    private var cardSurface: Color {
        colorScheme == .dark ? Color(uiColor: .secondarySystemBackground) : theme.cardBackground
    }
}

@available(iOS 16.0, *)
private struct ProfileCardMini: View {
    let name: String
    let zodiac: String
    let element: Element

    var body: some View {
        VStack(spacing: 4) {
            Text(name).font(.subheadline.weight(.semibold))
            Text(zodiac).font(.caption)
            Text(element.rawValue).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
    }
}
