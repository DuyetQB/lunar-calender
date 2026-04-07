//
//  ProfileStore.swift
//  Offline persistence for user profiles.
//

import Foundation
import SwiftUI

@MainActor
final class ProfileStore: ObservableObject {
    @Published var profiles: [UserProfile] = []

    private let storageKey = "lunar_profile_store_v1"

    init() {
        load()
        if profiles.isEmpty {
            profiles = Self.mockProfiles()
            save()
        }
    }

    func addProfile(_ profile: UserProfile) {
        profiles.append(profile)
        save()
    }

    func removeProfile(id: UUID) {
        profiles.removeAll { $0.id == id }
        save()
    }

    func save() {
        guard let data = try? JSONEncoder().encode(profiles) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([UserProfile].self, from: data) else {
            profiles = []
            return
        }
        profiles = decoded
    }

    func addProfile(name: String, birthDate: Date) {
        addProfile(LunarProfileService.makeProfile(name: name, birthDateSolar: birthDate))
    }

    static func mockProfiles() -> [UserProfile] {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        let d1 = c.date(from: DateComponents(year: 1993, month: 11, day: 23)) ?? Date()
        let d2 = c.date(from: DateComponents(year: 1998, month: 5, day: 7)) ?? Date()
        return [
            LunarProfileService.makeProfile(name: "An", birthDateSolar: d1),
            LunarProfileService.makeProfile(name: "Binh", birthDateSolar: d2),
        ]
    }
}
