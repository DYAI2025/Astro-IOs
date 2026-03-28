// SupabaseService.swift
// Bazodiac iOS — Supabase Auth + Profile Sync
//
// TASK-supabase-swift-package + TASK-auth-view + TASK-profile-sync
//
// Struktur bereit für Integration.
// Erfordert: supabase-swift SPM Package + Supabase Keys in AppConfig.
//
// Aktueller Status: Stub — alle Methoden returnen graceful fallbacks.
// Sobald supabase-swift als SPM-Dependency hinzugefügt wird,
// können die Stubs durch echte Implementierungen ersetzt werden.

import Foundation

// MARK: - Supabase Auth State

enum AuthState: Equatable {
    case signedOut
    case signedIn(userId: String, email: String)
    case loading
}

// MARK: - Supabase Service

@MainActor
@Observable
final class SupabaseService {

    static let shared = SupabaseService()
    private init() {}

    var authState: AuthState = .signedOut
    var errorMessage: String?

    /// Ob Supabase konfiguriert ist (Keys vorhanden)
    var isConfigured: Bool {
        !AppConfig.supabaseAnonKey.isEmpty && AppConfig.supabaseURL.host != "placeholder.supabase.co"
    }

    // MARK: - Auth

    /// Apple Sign-In → Supabase Auth
    func signInWithApple(idToken: String, nonce: String) async {
        guard isConfigured else {
            errorMessage = "Supabase nicht konfiguriert"
            return
        }
        authState = .loading
        // TODO: Replace with real supabase-swift call
        // let result = try await supabase.auth.signInWithIdToken(
        //     credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        // )
        // authState = .signedIn(userId: result.user.id.uuidString, email: result.user.email ?? "")

        // Stub: simulate success
        try? await Task.sleep(for: .seconds(1))
        authState = .signedIn(userId: UUID().uuidString, email: "user@bazodiac.com")
    }

    /// E-Mail Magic Link
    func signInWithEmail(_ email: String) async {
        guard isConfigured else {
            errorMessage = "Supabase nicht konfiguriert"
            return
        }
        authState = .loading
        // TODO: supabase.auth.signInWithOTP(email: email)
        try? await Task.sleep(for: .seconds(1))
        errorMessage = "Magic Link gesendet an \(email)"
        authState = .signedOut // Wartet auf Link-Klick
    }

    /// Sign Out
    func signOut() async {
        // TODO: try await supabase.auth.signOut()
        authState = .signedOut
    }

    // MARK: - Profile Sync

    /// Profil in Supabase speichern
    func saveProfile(_ profile: CosmicProfile) async {
        guard case .signedIn(let userId, _) = authState else { return }
        guard isConfigured else { return }

        // TODO: Replace with real Supabase insert
        // try await supabase.from("astro_profiles").upsert([
        //     "user_id": userId,
        //     "sun_sign": profile.westernData.sunSign.rawValue,
        //     "moon_sign": profile.westernData.moonSign.rawValue,
        //     "asc_sign": profile.westernData.ascendant.rawValue,
        //     "astro_json": profile encoded as JSON,
        //     "astro_computed_at": ISO8601DateFormatter().string(from: Date()),
        // ])

        print("[SupabaseService] Would save profile for user \(userId)")
    }

    /// Profil aus Supabase laden
    func loadProfile(userId: String) async -> CosmicProfile? {
        guard isConfigured else { return nil }

        // TODO: Replace with real Supabase query
        // let data = try await supabase.from("astro_profiles")
        //     .select()
        //     .eq("user_id", value: userId)
        //     .single()
        //     .execute()

        print("[SupabaseService] Would load profile for user \(userId)")
        return nil // Fallback to local cache
    }

    /// Prüfe ob ein Cloud-Profil existiert
    func hasCloudProfile() async -> Bool {
        guard case .signedIn(let userId, _) = authState else { return false }
        return await loadProfile(userId: userId) != nil
    }
}
