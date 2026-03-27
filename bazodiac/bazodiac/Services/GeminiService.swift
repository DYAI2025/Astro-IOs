// GeminiService.swift
// Bazodiac iOS — Gemini Interpretations-Service
//
// Löst PH-6/7: statische Tages-Inhalte ersetzen.
// Ruft den server-seitigen Proxy (/api/interpret) auf — kein API-Key im Client.
// Fällt auf Template-Interpretationen zurück wenn Server nicht erreichbar.

import Foundation

// MARK: - Response-Typen

struct GeminiInterpretationResponse: Decodable {
    let interpretation: String
    let tiles:  [String: String]?
    let houses: [String: String]?
}

struct GeminiDailyQuoteResponse: Decodable {
    let quote: String
}

// MARK: - Gemini Service

@MainActor
final class GeminiService {

    static let shared = GeminiService()
    private init() {}

    private let session = URLSession.shared

    // MARK: - Vollständige Profil-Interpretation (einmalig nach Berechnung)

    func interpretProfile(results: BAFEAllResults, birthData: BirthData, lang: CosmicStore.Language) async -> String {
        let langCode = lang == .german ? "de" : "en"

        // Payload aufbauen — in Teile aufgeteilt wegen Swift Type-Checker Limit
        let sunSignRaw = results.western.bodies?["Sun"]?.zodiac_sign
            .flatMap { i -> String? in guard i >= 0, i < ZodiacSign.allCases.count else { return nil }; return ZodiacSign.allCases[i].rawValue } ?? ""
        let moonSignRaw = results.western.bodies?["Moon"]?.zodiac_sign
            .flatMap { i -> String? in guard i >= 0, i < ZodiacSign.allCases.count else { return nil }; return ZodiacSign.allCases[i].rawValue } ?? ""
        let ascSignRaw = BAFEResponseMapper.zodiacSignFromDegrees(results.western.angles?.Ascendant ?? 0)?.rawValue ?? ""

        let baziPayload: [String: Any] = [
            "day_master": results.bazi.chinese?.day_master ?? "",
            "year_stem":  results.bazi.pillars?.year.resolvedStem  ?? "",
            "month_stem": results.bazi.pillars?.month.resolvedStem ?? "",
            "day_stem":   results.bazi.pillars?.day.resolvedStem   ?? "",
            "hour_stem":  results.bazi.pillars?.hour.resolvedStem  ?? "",
        ]
        let westernPayload: [String: Any] = [
            "sun_sign": sunSignRaw, "moon_sign": moonSignRaw, "ascendant_sign": ascSignRaw
        ]
        let wuxingPayload: [String: Any] = [
            "dominant": results.wuxing.dominant_element ?? "",
            "vector": results.wuxing.wu_xing_vector ?? [:]
        ]
        let payload: [String: Any] = [
            "lang": langCode,
            "data": ["name": birthData.name, "birthPlace": birthData.birthPlace,
                     "bazi": baziPayload, "western": westernPayload, "wuxing": wuxingPayload]
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            var request = URLRequest(url: AppConfig.interpretURL, timeoutInterval: 25)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data

            let (responseData, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw GeminiError.serverError
            }

            let decoded = try JSONDecoder().decode(GeminiInterpretationResponse.self, from: responseData)
            return decoded.interpretation
        } catch {
            print("⚠️ GeminiService: Interpretation fehlgeschlagen (\(error)) — Template-Fallback")
            return templateInterpretation(results: results, birthData: birthData, lang: lang)
        }
    }

    // MARK: - Tages-Zitat (mit 1-Tages-Cache)

    func dailyQuote(profile: CosmicProfile, lang: CosmicStore.Language) async -> String {
        // Bereits heute generiert?
        if let cached = PersistenceService.loadTodayQuote() {
            return cached
        }

        let quote = await generateDailyQuote(profile: profile, lang: lang)
        PersistenceService.saveDailyQuote(quote)
        return quote
    }

    private func generateDailyQuote(profile: CosmicProfile, lang: CosmicStore.Language) async -> String {
        let langCode = lang == .german ? "de" : "en"
        let sunSign = profile.westernData.sunSign.rawValue
        let dayMaster = profile.baziData.day.stem.english

        let payload: [String: Any] = [
            "type": "daily_quote",
            "lang": langCode,
            "sun_sign": sunSign,
            "day_master": dayMaster,
            "date": ISO8601DateFormatter().string(from: Date())
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            var request = URLRequest(url: AppConfig.interpretURL, timeoutInterval: 15)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data

            let (responseData, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw GeminiError.serverError }

            let decoded = try JSONDecoder().decode(GeminiInterpretationResponse.self, from: responseData)
            return decoded.interpretation
        } catch {
            return fallbackQuote(sunSign: sunSign, lang: lang)
        }
    }

    // MARK: - Template-Fallback (kein Gemini-Aufruf nötig)

    private func templateInterpretation(results: BAFEAllResults, birthData: BirthData, lang: CosmicStore.Language) -> String {
        // Minimale Template-Interpretation (Erweiterung von Web-App interpretation-templates.ts)
        let sunSignRaw = results.western.bodies?["Sun"]?.zodiac_sign.flatMap { i -> String? in
            guard i >= 0, i < ZodiacSign.allCases.count else { return nil }
            return ZodiacSign.allCases[i].germanName
        } ?? "Unbekannt"

        let dayMaster = results.bazi.chinese?.day_master ?? results.bazi.pillars?.day.resolvedStem ?? "—"
        let dominant  = results.wuxing.dominant_element ?? "Wasser"

        if lang == .german {
            return """
            Dein kosmischer Blueprint vereint die Energie des \(sunSignRaw) mit der Tiefe des BaZi Day Masters \(dayMaster). \
            Das \(dominant)-Element dominiert deine Energiestruktur und formt deinen natürlichen Fluss. \
            Diese Fusion aus westlicher Astrologie und chinesischer Metaphysik zeigt den einzigartigen Pfad, der vor dir liegt.
            """
        } else {
            return """
            Your cosmic blueprint unites the energy of \(sunSignRaw) with the depth of BaZi Day Master \(dayMaster). \
            The \(dominant) element dominates your energy structure, shaping your natural flow. \
            This fusion of Western astrology and Chinese metaphysics reveals the unique path that lies before you.
            """
        }
    }

    func fallbackQuote(sunSign: String, lang: CosmicStore.Language) -> String {
        let quotes: [String: (de: String, en: String)] = [
            "Capricorn": (
                de: "Geduld ist nicht passives Warten — sie ist aktive Weisheit des Gipfels.",
                en: "Patience is not passive waiting — it is the active wisdom of the summit."
            ),
            "Scorpio": (
                de: "Was in der Tiefe verborgen liegt, ist nicht verloren — es wartet auf seinen Moment.",
                en: "What lies hidden in the depths is not lost — it awaits its moment."
            ),
            "Pisces": (
                de: "Intuition ist die Sprache, die der Verstand noch lernen muss.",
                en: "Intuition is the language the mind has yet to learn."
            ),
        ]

        let q = quotes[sunSign] ?? (
            de: "Die Sterne erzwingen nichts, sie laden ein. Gehe den Weg, der bereits deiner ist.",
            en: "The stars compel nothing, they invite. Walk the path that is already yours."
        )
        return lang == .german ? q.de : q.en
    }
}

enum GeminiError: Error {
    case serverError
}
