// CosmicStore.swift
// Bazodiac iOS — Global App State (Observation framework, @MainActor)
//
// Single source of truth. Injected as environment object at app root.
// Uses @Observable (iOS 17+) — NOT ObservableObject.
//
// Platzhalter-Status (siehe PLACEHOLDERS.md):
//   ✅ PH-1  submitBirthData → BAFEService (echte API-Calls)
//   ✅ PH-3  CosmicProfile.mock aus Prod-Pfaden entfernt
//   ✅ PH-4  Persistenz über PersistenceService
//   ✅ PH-16 Light/Dark-Theme-Toggle
//   🟡 PH-5  Supabase Auth (Phase 6)

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

    // ── Theme (PH-16) ──────────────────────────────────────────────────────────
    var theme: CosmicTheme = .dark

    // ── Language ─────────────────────────────────────────────────────────────────
    var language: Language = .german

    // ── Daily content ────────────────────────────────────────────────────────────
    var dailyQuote: String = ""
    var dailyRefreshDate: Date?

    // MARK: - Init (Persistenz laden)

    init() {
        // Theme aus UserDefaults
        if let saved = PersistenceService.loadTheme(),
           let t = CosmicTheme(rawValue: saved) {
            theme = t
        }

        // Sprache aus UserDefaults
        if let saved = PersistenceService.loadLanguage() {
            language = saved == "en" ? .english : .german
        }

        // Profil aus Cache
        if let cached = PersistenceService.loadProfile() {
            profile   = cached
            birthData = cached.birthData
            appPhase  = .dashboard
        }

                // Tages-Zitat aus Cache
        if let quote = PersistenceService.loadTodayQuote() {
            dailyQuote = quote
        }
    }

    // ── Tab ─────────────────────────────────────────────────────────────────────
    enum Tab: String, CaseIterable {
        case home    = "home"
        case chart   = "chart"
        case bazi    = "bazi"
        case quizzes = "quizzes"
        case agents  = "agents"

        var label: String {
            switch self {
            case .home:    return "Atlas"
            case .chart:   return "Charts"
            case .bazi:    return "Signatur"
            case .quizzes: return "Quizzes"
            case .agents:  return "Companions"
            }
        }

        var icon: String {
            switch self {
            case .home:    return "moon.stars.fill"
            case .chart:   return "scope"
            case .bazi:    return "rectangle.grid.2x2.fill"
            case .quizzes: return "square.grid.2x2.fill"
            case .agents:  return "person.2.fill"
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
        return name.isEmpty ? (language == .german ? "Dein Kosmos" : "Your Cosmos") : name
    }

    // MARK: - Actions

    func enterApp(language: Language) {
        self.language = language
        PersistenceService.saveLanguage(language.rawValue)
        withAnimation(.easeInOut(duration: 0.6)) {
            appPhase = hasProfile ? .dashboard : .birthForm
        }
    }

    /// PH-1 ERSETZT: Echter BAFE-API-Aufruf statt Fake-Sleep + Mock
    func submitBirthData() async {
        guard !birthData.name.isEmpty else { return }
        guard birthData.latitude != 0 || birthData.longitude != 0 else {
            // PH-2: Geocoding fehlt noch → temporärer Fallback auf Mock für Entwicklung
            await submitWithMockFallback()
            return
        }

        isLoading = true
        error = nil

        do {
            // 1. Alle astrologischen Berechnungen parallel
            let results = try await BAFEService.shared.calculateAll(birthData: birthData)

            // 2. KI-Interpretation generieren
            let interpretation = await GeminiService.shared.interpretProfile(
                results: results,
                birthData: birthData,
                lang: language
            )

            // 3. Tages-Zitat
            let quote = await GeminiService.shared.generateDailyQuote(
                profile: nil,
                lang: language,
                sunSignRaw: BAFEResponseMapper.zodiacSignFromDegrees(
                    results.western.bodies?["Sun"]?.longitude ?? 0
                )?.rawValue ?? ""
            )

            // 4. iOS-Modell bauen
            let newProfile = BAFEResponseMapper.buildProfile(
                from: results,
                birthData: birthData,
                interpretation: interpretation,
                dailyQuote: quote
            )

            // 5. Speichern
            profile = newProfile
            dailyQuote = quote
            PersistenceService.saveProfile(newProfile)
            PersistenceService.saveBirthData(birthData)

            withAnimation(.spring(duration: 0.7)) {
                appPhase = .dashboard
            }

        } catch {
            self.error = error.localizedDescription
            // Bei Fehler: Fallback auf Mock für Dev
            #if DEBUG
            await submitWithMockFallback()
            #endif
        }

        isLoading = false
    }

    /// PH-1 ERSETZT: recalculate mit echter API
    func recalculate() async {
        guard hasProfile else { return }
        isLoading = true

        do {
            let results = try await BAFEService.shared.calculateAll(birthData: birthData)
            let interpretation = await GeminiService.shared.interpretProfile(
                results: results,
                birthData: birthData,
                lang: language
            )
            let updated = BAFEResponseMapper.buildProfile(
                from: results,
                birthData: birthData,
                interpretation: interpretation,
                dailyQuote: profile?.dailyQuote ?? ""
            )
            profile = updated
            PersistenceService.saveProfile(updated)
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    /// Tages-Zitat aktualisieren (max. 1x pro Tag)
    func refreshDailyContentIfNeeded() async {
        guard let profile else { return }
        guard dailyRefreshDate.map({ !Calendar.current.isDateInToday($0) }) ?? true else { return }
        let quote = await GeminiService.shared.dailyQuote(profile: profile, lang: language)
        dailyQuote = quote
        dailyRefreshDate = Date()
    }

    func toggleTheme() {
        withAnimation(.spring(duration: 0.4, bounce: 0.1)) {
            theme = theme.next
        }
        PersistenceService.saveTheme(theme.rawValue)
    }

    func signOut() {
        profile = nil
        birthData = BirthData()
        dailyQuote = ""
        PersistenceService.clearAll()
        withAnimation(.easeInOut(duration: 0.5)) {
            appPhase = .splash
        }
    }

    // MARK: - Dev Fallback (nur Debug, solange PH-2 Geocoding fehlt)

    #if DEBUG
    private func submitWithMockFallback() async {
        var mockData = BirthData()
        mockData.name       = birthData.name.isEmpty ? "Vorschau" : birthData.name
        mockData.birthPlace = birthData.birthPlace.isEmpty ? "München, Deutschland" : birthData.birthPlace
        mockData.birthDate  = birthData.birthDate

        profile = CosmicProfile(
            birthData:      mockData,
            westernData:    .mock,
            baziData:       .mock,
            wuxingData:     .mock,
            interpretation: "Vorschau-Interpretation. Geburtsort-Koordinaten werden nach Implementierung des Geocodings durch echte Daten ersetzt.",
            dailyQuote:     "Die Sterne laden ein — gehe den Weg, der bereits deiner ist."
        )
        PersistenceService.saveProfile(profile!)
        isLoading = false
        withAnimation(.spring(duration: 0.7)) {
            appPhase = .dashboard
        }
    }
    #else
    private func submitWithMockFallback() async {
        error = "Geburtsort konnte nicht geortet werden. Bitte erneut eingeben."
        isLoading = false
    }
    #endif
}

// MARK: - GeminiService Erweiterung für dailyQuote ohne volles Profil

extension GeminiService {
    func generateDailyQuote(profile: CosmicProfile?, lang: CosmicStore.Language, sunSignRaw: String = "") async -> String {
        if let profile {
            return await dailyQuote(profile: profile, lang: lang)
        }
        return fallbackQuote(sunSign: sunSignRaw, lang: lang)
    }
}
