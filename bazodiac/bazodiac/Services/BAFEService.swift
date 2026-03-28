// BAFEService.swift
// Bazodiac iOS — BAFE Astrologische Berechnungs-API Client
//
// Ruft alle 5 BAFE-Endpunkte auf und gibt gemappte iOS-Modelle zurück.
// Ersetzt: CosmicStore.submitBirthData() Stub + CosmicProfile.mock
//
// BAFE-Endpunkte (via Proxy /api/calculate/…):
//   POST /bazi    → BaZi Vier Säulen
//   POST /western → Westliche Astrologie (Planeten, Häuser, Aspekte)
//   POST /wuxing  → Wu-Xing Fünf Elemente
//   POST /fusion  → Fusionsthema (BaZi + Western)
//   POST /tst     → Temporal Structure Transits

import Foundation

// MARK: - Request Payload

struct BAFERequest: Encodable {
    let date: String       // ISO 8601: "1990-01-15T14:30:00"
    let tz: String         // IANA Timezone: "Europe/Berlin"
    let lon: Double        // Längengrad
    let lat: Double        // Breitengrad
    let standard: String   = "CIVIL"
    let boundary: String   = "midnight"
    let strict: Bool       = true
    let ambiguousTime: String    = "earlier"
    let nonexistentTime: String  = "error"
}

// MARK: - Rohe BAFE-Response-Typen (JSON-Decodierung)

struct BAFERawPillar: Decodable {
    // BAFE liefert deutsche UND englische Keys je nach Version
    let stamm:   String?   // Himmels-Stamm (de)
    let zweig:   String?   // Erd-Zweig (de)
    let tier:    String?   // Tier (de)
    let element: String?
    // Englische Fallbacks
    let stem:    String?
    let branch:  String?
    let animal:  String?

    var resolvedStem:   String { stamm   ?? stem   ?? "" }
    var resolvedBranch: String { zweig   ?? branch  ?? "" }
    var resolvedAnimal: String { tier    ?? animal  ?? "" }
}

struct BAFERawPillars: Decodable {
    let year:  BAFERawPillar
    let month: BAFERawPillar
    let day:   BAFERawPillar
    let hour:  BAFERawPillar
}

struct BAFEBaziChinese: Decodable {
    let day_master: String?
    let year: BAFEBaziYear?
    struct BAFEBaziYear: Decodable { let animal: String? }
}

struct BAFEBaziResponse: Decodable {
    let pillars: BAFERawPillars?
    let chinese: BAFEBaziChinese?
}

struct BAFEBody: Decodable {
    let zodiac_sign: Int?      // 0-basierter Index (0=Widder … 11=Fische)
    let longitude: Double?     // Ekliptik-Grad 0–360
    let latitude:  Double?
    let speed:     Double?
}

struct BAFEAngles: Decodable {
    let Ascendant: Double?
    let MC: Double?
}

struct BAFEWesternResponse: Decodable {
    let bodies: [String: BAFEBody]?
    let angles: BAFEAngles?
    let houses: [String: Double]?   // "1"–"12" → Cusp-Grad
}

struct BAFEWuXingResponse: Decodable {
    let wu_xing_vector: [String: Double]?
    let dominant_element: String?
}

struct BAFEFusionResponse: Decodable {
    let theme:   String?
    let summary: String?
}

// MARK: - Gemappte Ergebnis-Struktur

struct BAFEAllResults {
    let bazi:    BAFEBaziResponse
    let western: BAFEWesternResponse
    let wuxing:  BAFEWuXingResponse
    let fusion:  BAFEFusionResponse
    var issues:  [String] = []
}

// MARK: - BAFE Service

@MainActor
final class BAFEService {

    static let shared = BAFEService()
    private init() {}

    private let session = URLSession.shared

    // MARK: - Alle Berechnungen parallel abrufen

    func calculateAll(birthData: BirthData) async throws -> BAFEAllResults {
        let payload = buildPayload(from: birthData)

        var issues: [String] = []

        // Alle 5 Endpunkte parallel (wie Web-App in api.ts)
        async let baziTask    = fetchWithFallback("bazi",    payload: payload, type: BAFEBaziResponse.self,    fallback: BAFEBaziResponse(pillars: nil, chinese: nil))
        async let westernTask = fetchWithFallback("western", payload: payload, type: BAFEWesternResponse.self, fallback: BAFEWesternResponse(bodies: nil, angles: nil, houses: nil))
        async let wuxingTask  = fetchWithFallback("wuxing",  payload: payload, type: BAFEWuXingResponse.self,  fallback: BAFEWuXingResponse(wu_xing_vector: nil, dominant_element: nil))
        async let fusionTask  = fetchWithFallback("fusion",  payload: payload, type: BAFEFusionResponse.self,  fallback: BAFEFusionResponse(theme: nil, summary: nil))

        let (bazi, westernResult) = try await (baziTask, westernTask)
        let wuxing = try await wuxingTask
        let fusion = try await fusionTask

        return BAFEAllResults(bazi: bazi, western: westernResult, wuxing: wuxing, fusion: fusion, issues: issues)
    }

    // MARK: - Privat: HTTP POST

    private func fetch<T: Decodable>(_ endpoint: String, payload: BAFERequest, type: T.Type) async throws -> T {
        // BAFE direkt (kein Proxy, kein Auth nötig): /calculate/<endpoint>
        let url = AppConfig.bafeBaseURL.appendingPathComponent("/calculate/\(endpoint)")
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw BAFEError.serverError(endpoint: endpoint, body: body)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    private func fetchWithFallback<T: Decodable>(
        _ endpoint: String,
        payload: BAFERequest,
        type: T.Type,
        fallback: T
    ) async throws -> T {
        do {
            return try await fetch(endpoint, payload: payload, type: type)
        } catch {
            print("⚠️ BAFE /\(endpoint) failed: \(error)")
            return fallback
        }
    }

    // MARK: - Payload Mapping

    private func buildPayload(from data: BirthData) -> BAFERequest {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
        formatter.timeZone = TimeZone(identifier: data.timezone) ?? .current
        let isoDate = formatter.string(from: data.birthDate)

        return BAFERequest(
            date: isoDate,
            tz: data.timezone,
            lon: data.longitude,
            lat: data.latitude
        )
    }
}

// MARK: - Fehlertypen

enum BAFEError: LocalizedError {
    case serverError(endpoint: String, body: String)
    case missingCoordinates

    var errorDescription: String? {
        switch self {
        case .serverError(let ep, let body):
            return "BAFE /\(ep) Fehler: \(body)"
        case .missingCoordinates:
            return "Geburtsort konnte nicht geortet werden. Bitte erneut eingeben."
        }
    }
}
