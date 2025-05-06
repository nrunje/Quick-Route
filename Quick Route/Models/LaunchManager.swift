//
//  LaunchManager.swift
//  Quick Route
//
//  Created by Nicholas Runje on 5/6/25.
//

import Foundation

struct OnboardingState: Codable {
    var hasSeenWelcome = false
    var lastShownVersion = 0      // increment for “What’s New”
}

final class LaunchManager: ObservableObject {
    @Published var state: OnboardingState

    private let key = "onboardingState"
    private let currentVersion = 2   // bump when you add new pages

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(OnboardingState.self, from: data) {
            state = saved
        } else {
            state = OnboardingState()
        }
    }

    func markCompleted() {
        state.hasSeenWelcome = true
        state.lastShownVersion = currentVersion
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    var needsWelcome: Bool { !state.hasSeenWelcome }
    var needsWhatsNew: Bool { state.lastShownVersion < currentVersion }
}
