// AppConfig.swift
// Bazodiac iOS — Zentralisierte Konfiguration
//
// Alle API-URLs und externen Abhängigkeiten an einem Ort.
// Keys werden aus dem App-Bundle (Info.plist / Env) geladen — niemals hartcoden.

import Foundation

enum AppConfig {

    // MARK: - BAFE (Astrologische Berechnungs-Engine)

    /// Basis-URL des BAFE-Proxy-Servers.
    /// Dev: lokaler Vite-Proxy auf :3000
    /// Prod: Railway-Server (server.mjs)
    static var bafeBaseURL: URL {
        // Aus Info.plist laden wenn gesetzt, sonst Produktion
        if let override = Bundle.main.object(forInfoDictionaryKey: "BAFE_BASE_URL") as? String,
           let url = URL(string: override) {
            return url
        }
        return URL(string: "https://bazodiac.up.railway.app")!
    }

    // MARK: - Gemini / Interpretation

    /// Gemini-Interpretation läuft server-seitig über den Proxy.
    /// Der iOS-Client ruft niemals direkt die Gemini-API auf.
    static var interpretURL: URL {
        bafeBaseURL.appendingPathComponent("/api/interpret")
    }

    // MARK: - ElevenLabs (Levi Voice AI)

    /// ElevenLabs Conversational AI Agent-ID.
    /// Wird in Info.plist als ELEVENLABS_AGENT_ID eingetragen.
    static var elevenLabsAgentID: String {
        Bundle.main.object(forInfoDictionaryKey: "ELEVENLABS_AGENT_ID") as? String ?? ""
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
        !elevenLabsAgentID.isEmpty
    }
}
