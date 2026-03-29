// AppConfig.swift
// Bazodiac iOS — Zentralisierte Konfiguration
//
// Alle API-URLs und externen Abhängigkeiten an einem Ort.
// Keys werden aus dem App-Bundle (Info.plist / Env) geladen — niemals hartcoden.

import Foundation

enum AppConfig {

    // MARK: - BAFE (Astrologische Berechnungs-Engine)

    /// BAFE API direkt (keine Auth nötig, kein Proxy)
    static var bafeBaseURL: URL {
        if let override = Bundle.main.object(forInfoDictionaryKey: "BAFE_BASE_URL") as? String,
           let url = URL(string: override) {
            return url
        }
        return URL(string: "https://bafe-production.up.railway.app")!
    }

    /// Railway Proxy Server (für Gemini/Auth-geschützte Endpunkte)
    static var proxyBaseURL: URL {
        return URL(string: "https://astro-noctum-production.up.railway.app")!
    }

    // MARK: - Gemini / Interpretation

    /// Gemini-Interpretation läuft server-seitig über den Railway Proxy.
    /// Erfordert Supabase Auth — bis Auth implementiert, nutze Template-Fallback.
    static var interpretURL: URL {
        proxyBaseURL.appendingPathComponent("/api/interpret")
    }

    // MARK: - ElevenLabs (Levi Voice AI)

    /// ElevenLabs Conversational AI Agent-IDs.
    /// Konfiguriert in Info.plist als ELEVENLABS_LEVI_AGENT_ID / ELEVENLABS_EVE_AGENT_ID.
    static var elevenLabsLeviAgentID: String {
        Bundle.main.object(forInfoDictionaryKey: "ELEVENLABS_LEVI_AGENT_ID") as? String ?? ""
    }

    static var elevenLabsEveAgentID: String {
        Bundle.main.object(forInfoDictionaryKey: "ELEVENLABS_EVE_AGENT_ID") as? String ?? ""
    }

    static let elevenLabsBaseURL = URL(string: "https://api.elevenlabs.io/v1")!

    // MARK: - Supabase

    static var supabaseURL: URL {
        let str = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
        return URL(string: str) ?? URL(string: "https://placeholder.supabase.co")!
    }

    static var supabaseAnonKey: String {
        Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""
    }

    // MARK: - Feature Flags

    /// Wenn true: echte BAFE-API-Calls. Wenn false: Mock-Daten (nur Debug).
    static var useLiveAPI: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["USE_LIVE_API"] == "1"
        #else
        return true
        #endif
    }

    /// Wenn true: ElevenLabs-Integration aktiv.
    static var leviEnabled: Bool {
        !elevenLabsLeviAgentID.isEmpty
    }
}
