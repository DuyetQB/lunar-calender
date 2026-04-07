//
//  ProfileView.swift
//  Profile list + create + compare.
//

import SwiftUI

@available(iOS 16.0, *)
struct ProfileView: View {
    @EnvironmentObject private var store: ProfileStore
    @EnvironmentObject private var language: AppLanguageManager
    @Environment(\.appThemeColors) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var showAdd = false
    @State private var draftName = ""
    @State private var draftBirth = Date()
    @State private var selectedA: UUID?
    @State private var selectedB: UUID?
    @State private var compatibility: CompatibilityResult?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                compareBar
                List {
                    ForEach(store.profiles) { p in
                        ProfileCardView(profile: p, selectedOrder: selectedOrder(for: p.id))
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    store.removeProfile(id: p.id)
                                } label: {
                                    Label("profile_delete", systemImage: "trash")
                                }
                            }
                            .onTapGesture {
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                    toggleSelection(p.id)
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                if selectedA == p.id || selectedB == p.id {
                                    Image(systemName: selectedA == p.id ? "1.circle.fill" : "2.circle.fill")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(theme.primary)
                                        .padding(8)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .animation(.spring(response: 0.35, dampingFraction: 0.86), value: selectedA)
                            .animation(.spring(response: 0.35, dampingFraction: 0.86), value: selectedB)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
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
            .navigationTitle(Text("profile_title"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Label("profile_add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                NavigationStack {
                    Form {
                        TextField(String(localized: "profile_name"), text: $draftName)
                        DatePicker("profile_birth_solar", selection: $draftBirth, displayedComponents: .date)
                    }
                    .navigationTitle(Text("profile_add"))
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("home_close") { showAdd = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("profile_save") {
                                let clean = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !clean.isEmpty {
                                    store.addProfile(name: clean, birthDate: draftBirth)
                                    draftName = ""
                                    draftBirth = Date()
                                    showAdd = false
                                }
                            }
                        }
                    }
                }
            }
            .navigationDestination(isPresented: Binding(get: { compatibility != nil }, set: { if !$0 { compatibility = nil } })) {
                if let a = selectedProfileA, let b = selectedProfileB, let result = compatibility {
                    CompatibilityView(a: a, b: b, result: result)
                }
            }
        }
    }

    private var compareBar: some View {
        HStack {
            Text("profile_compare_hint")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                guard let a = selectedProfileA, let b = selectedProfileB else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                    compatibility = LunarProfileService.calculateCompatibility(a: a, b: b, languageCode: language.language.rawValue)
                }
            } label: {
                Text("profile_compare")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedProfileA == nil || selectedProfileB == nil)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(theme.primary.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.22 : 0.07), radius: 10, x: 0, y: 3)
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    private var selectedProfileA: UserProfile? {
        guard let id = selectedA else { return nil }
        return store.profiles.first { $0.id == id }
    }

    private var selectedProfileB: UserProfile? {
        guard let id = selectedB else { return nil }
        return store.profiles.first { $0.id == id }
    }

    private func toggleSelection(_ id: UUID) {
        if selectedA == id {
            selectedA = nil
            return
        }
        if selectedB == id {
            selectedB = nil
            return
        }
        if selectedA == nil {
            selectedA = id
        } else if selectedB == nil {
            selectedB = id
        } else {
            selectedA = selectedB
            selectedB = id
        }
    }

    private func selectedOrder(for id: UUID) -> Int? {
        if selectedA == id { return 1 }
        if selectedB == id { return 2 }
        return nil
    }
}

#if DEBUG
@available(iOS 17.0, *)
#Preview {
    let store = ProfileStore()
    return ProfileView()
        .environmentObject(store)
}
#endif
