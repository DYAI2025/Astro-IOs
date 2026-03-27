// CosmicStore.swift
// Bazodiac iOS — Global App State (Observation framework, @MainActor)
//
// Single source of truth. Injected as environment object at app root.
// Uses @Observable (iOS 17+) — NOT ObservableObject.

import SwiftUI
import Observation

// MARK: - App Phase

enum AppPhase: Equatable {
    case splash
    case birthForm
    case dashboard
}

// MARK: - Cosmic Store

@Observable
@MainActor
final class CosmicStore {

    // ── Navigation ─────────────────────────────────────────────────────────────
    var appPhase: AppPhase = .splash
    var selectedTab: Tab = .home

    // ── Birth Data ──────────────────────────────────────────────────────────────
    var birthData = BirthData()

    // ── Profile ─────────────────────────────────────────────────────────────────
    var profile: CosmicProfile?
    var isLoading = false
    var error: String?

    // ── Language ─────────────────────────────────────────────────────────────────
    var language: Language = .german

    // ── Tab ─────────────────────────────────────────────────────────────────────
    enum Tab: String, CaseIterable {
        case home     = "home"
        case chart    = "chart"
        case bazi     = "bazi"
        case elements = "elements"
        case levi     = "levi"

        var label: String {
            switch self {
            case .home:     return "Kosmos"
            case .chart:    return "Chart"
            case .bazi:     return "BaZi"
            case .elements: return "Wu-Xing"
            case .levi:     return "Levi"
            }
        }

        var icon: String {
            switch self {
            case .home:     return "moon.stars.fill"
            case .chart:    return "scope"
            case .bazi:     return "rectangle.grid.2x2.fill"
            case .elements: return "pentagon.fill"
            case .levi:     return "waveform.circle.fill"
            }
        }
    }

    enum Language: String {
        case german  = "de"
        case english = "en"
    }

    // MARK: - Computed

    var hasProfile: Bool { profile != nil }

    var displayName: String {
        let name = birthData.name.trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? "Dein Kosmos" : name
    }

    // MARK: - Actions

    func enterApp(language: Language) {
        self.language = language
        withAnimation(.easeInOut(duration: 0.6)) {
            appPhase = hasProfile ? .dashboard : .birthForm
        }
    }

    func submitBirthData() async {
        guard !birthData.name.isEmpty else { return }
        isLoading = true
        error = nil

        // Simulate API call (replace with real BAFE + Gemini calls)
        try? await Task.sleep(for: .seconds(2.5))

        // For design concept: inject mock profile
        profile = CosmicProfile.mock
        isLoading = false

        withAnimation(.spring(duration: 0.7)) {
            appPhase = .dashboard
        }
    }

    func recalculate() async {
        guard hasProfile else { return }
        isLoading = true
        try? await Task.sleep(for: .seconds(1.5))
        profile = CosmicProfile.mock
        isLoading = false
    }

    func signOut() {
        profile = nil
        birthData = BirthData()
        withAnimation(.easeInOut(duration: 0.5)) {
            appPhase = .splash
        }
    }
}
