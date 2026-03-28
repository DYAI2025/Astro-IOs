// CosmicWeatherService.swift
// Bazodiac iOS — Kosmisches Wetter (Live-Daten + Mondphase)
//
// Quellen:
//   - NOAA SWPC: Kp-Index (geomagnetische Aktivität, Sonnenstürme)
//   - Berechnet: Mondphase aus Datum (Synodischer Monat)
//   - Optional: NASA DONKI Fallback
//
// Das kosmische Wetter fließt in den Day Pulse ein und personalisiert
// die Tages-Energie basierend auf dem Nutzer-Chart.

import Foundation

// MARK: - Cosmic Weather Data

struct CosmicWeather: Equatable {
    let kpIndex: Double              // 0–9 (geomagnetische Aktivität)
    let kpLabel: String              // "Ruhig", "Aktiv", "Sturm" etc.
    let moonPhase: MoonPhase
    let moonIllumination: Double     // 0.0–1.0
    let solarDescription: String     // Kurzbeschreibung der Sonnenaktivität
    let fetchedAt: Date

    var isStormy: Bool { kpIndex >= 5 }
    var isCalm: Bool { kpIndex <= 2 }
}

enum MoonPhase: String, CaseIterable {
    case newMoon        = "Neumond"
    case waxingCrescent = "Zunehmende Sichel"
    case firstQuarter   = "Erstes Viertel"
    case waxingGibbous  = "Zunehmender Mond"
    case fullMoon       = "Vollmond"
    case waningGibbous  = "Abnehmender Mond"
    case lastQuarter    = "Letztes Viertel"
    case waningCrescent = "Abnehmende Sichel"

    var icon: String {
        switch self {
        case .newMoon:        return "moon.fill"
        case .waxingCrescent: return "moon.stars.fill"
        case .firstQuarter:   return "moon.zzz.fill"
        case .waxingGibbous:  return "moon.haze.fill"
        case .fullMoon:       return "sun.and.horizon.fill"
        case .waningGibbous:  return "moon.haze.fill"
        case .lastQuarter:    return "moon.zzz.fill"
        case .waningCrescent: return "moon.stars.fill"
        }
    }

    var germanName: String { rawValue }

    var englishName: String {
        switch self {
        case .newMoon:        return "New Moon"
        case .waxingCrescent: return "Waxing Crescent"
        case .firstQuarter:   return "First Quarter"
        case .waxingGibbous:  return "Waxing Gibbous"
        case .fullMoon:       return "Full Moon"
        case .waningGibbous:  return "Waning Gibbous"
        case .lastQuarter:    return "Last Quarter"
        case .waningCrescent: return "Waning Crescent"
        }
    }
}

// MARK: - Service

@MainActor
final class CosmicWeatherService {

    static let shared = CosmicWeatherService()
    private init() {}

    private var cached: CosmicWeather?
    private var lastFetch: Date?
    private let cacheTTL: TimeInterval = 900 // 15 Minuten

    /// Kosmisches Wetter abrufen (mit Cache)
    func fetch() async -> CosmicWeather {
        if let cached, let lastFetch, Date().timeIntervalSince(lastFetch) < cacheTTL {
            return cached
        }

        let kp = await fetchKpIndex()
        let moon = calculateMoonPhase(Date())

        let weather = CosmicWeather(
            kpIndex: kp.index,
            kpLabel: kp.label,
            moonPhase: moon.phase,
            moonIllumination: moon.illumination,
            solarDescription: kp.description,
            fetchedAt: Date()
        )

        cached = weather
        lastFetch = Date()
        return weather
    }

    // MARK: - Kp-Index (NOAA SWPC)

    private func fetchKpIndex() async -> (index: Double, label: String, description: String) {
        do {
            let url = URL(string: "https://services.swpc.noaa.gov/json/planetary_k_index_1m.json")!
            let (data, _) = try await URLSession.shared.data(from: url)

            struct KpEntry: Decodable {
                let kp_index: Double?
                let estimated_kp: Double?
            }

            let entries = try JSONDecoder().decode([KpEntry].self, from: data)
            let kp = entries.last?.estimated_kp ?? entries.last?.kp_index ?? 0

            return (kp, kpLabel(kp), kpDescription(kp))
        } catch {
            return (0, "Unbekannt", "Kosmisches Wetter konnte nicht abgerufen werden.")
        }
    }

    private func kpLabel(_ kp: Double) -> String {
        switch kp {
        case 0..<2:   return "Ruhig"
        case 2..<4:   return "Leicht aktiv"
        case 4..<5:   return "Aktiv"
        case 5..<7:   return "Geomagnetischer Sturm"
        case 7..<9:   return "Starker Sturm"
        default:       return "Extremer Sturm"
        }
    }

    private func kpDescription(_ kp: Double) -> String {
        switch kp {
        case 0..<2:   return "Die Magnetosphäre ist still. Idealer Tag für innere Einkehr und Klarheit."
        case 2..<4:   return "Leichte geomagnetische Aktivität. Deine Intuition könnte heute geschärft sein."
        case 4..<5:   return "Erhöhte Sonnenwind-Aktivität. Emotionen können heute intensiver sein als gewöhnlich."
        case 5..<7:   return "Geomagnetischer Sturm aktiv. Kosmische Energie flutet die Erdatmosphäre — ein Tag der Transformation."
        case 7..<9:   return "Starker geomagnetischer Sturm. Die Grenze zwischen Innerem und Äußerem verschwimmt — handle bewusst."
        default:      return "Extremer Sonnensturm. Alle kosmischen Kanäle sind weit offen — tiefe Wandlung möglich."
        }
    }

    // MARK: - Mondphase (berechnet, kein API nötig)

    private func calculateMoonPhase(_ date: Date) -> (phase: MoonPhase, illumination: Double) {
        // Synodischer Monat: 29.53058770576 Tage
        // Referenz-Neumond: 6. Jan 2000, 18:14 UTC (Julian Day 2451550.26)
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)
        let year = Double(components.year ?? 2026)
        let month = Double(components.month ?? 1)
        let day = Double(components.day ?? 1) + Double(components.hour ?? 12) / 24.0

        // Julian Day Number
        let a = floor((14 - month) / 12)
        let y = year + 4800 - a
        let m = month + 12 * a - 3
        let jdn = day + floor((153 * m + 2) / 5) + 365 * y + floor(y / 4) - floor(y / 100) + floor(y / 400) - 32045

        // Tage seit Referenz-Neumond
        let daysSinceNew = jdn - 2451550.26
        let synodicMonth = 29.53058770576
        let cyclePosition = (daysSinceNew.truncatingRemainder(dividingBy: synodicMonth) + synodicMonth)
            .truncatingRemainder(dividingBy: synodicMonth)
        let phaseAngle = cyclePosition / synodicMonth // 0.0 = Neumond, 0.5 = Vollmond

        // Beleuchtung (Cosinus-Approximation)
        let illumination = (1 - cos(phaseAngle * 2 * .pi)) / 2

        // Phase bestimmen
        let phase: MoonPhase
        switch phaseAngle {
        case 0..<0.0625:      phase = .newMoon
        case 0.0625..<0.1875: phase = .waxingCrescent
        case 0.1875..<0.3125: phase = .firstQuarter
        case 0.3125..<0.4375: phase = .waxingGibbous
        case 0.4375..<0.5625: phase = .fullMoon
        case 0.5625..<0.6875: phase = .waningGibbous
        case 0.6875..<0.8125: phase = .lastQuarter
        case 0.8125..<0.9375: phase = .waningCrescent
        default:              phase = .newMoon
        }

        return (phase, illumination)
    }
}

// MARK: - Day Pulse Generator

enum DayPulseGenerator {

    /// Generiert den personalisierten Day Pulse Spruch
    static func generate(
        profile: CosmicProfile,
        weather: CosmicWeather,
        language: CosmicStore.Language
    ) -> DayPulse {
        let sun = profile.westernData.sunSign
        let moon = profile.westernData.moonSign
        let dayMaster = profile.baziData.day.stem
        let dominant = profile.wuxingData.dominant

        // Intensität: 0.0 (ruhig) – 1.0 (stürmisch)
        let intensity = min(1.0, weather.kpIndex / 9.0)

        let pulse: String
        let subtext: String

        if language == .german {
            pulse = buildGermanPulse(
                sun: sun, moon: moon, dayMaster: dayMaster,
                dominant: dominant, weather: weather, intensity: intensity
            )
            subtext = "\(weather.moonPhase.germanName) · Kp \(String(format: "%.0f", weather.kpIndex)) · \(weather.kpLabel)"
        } else {
            pulse = buildEnglishPulse(
                sun: sun, moon: moon, dayMaster: dayMaster,
                dominant: dominant, weather: weather, intensity: intensity
            )
            subtext = "\(weather.moonPhase.englishName) · Kp \(String(format: "%.0f", weather.kpIndex)) · \(weather.kpLabel)"
        }

        return DayPulse(
            headline: pulse,
            subtext: subtext,
            moonPhase: weather.moonPhase,
            moonIllumination: weather.moonIllumination,
            kpIndex: weather.kpIndex,
            intensity: intensity
        )
    }

    // MARK: - German Pulse

    private static func buildGermanPulse(
        sun: ZodiacSign, moon: ZodiacSign, dayMaster: HeavenlyStem,
        dominant: CosmicElement, weather: CosmicWeather, intensity: Double
    ) -> String {
        let moonPhaseText: String
        switch weather.moonPhase {
        case .newMoon:
            moonPhaseText = "Der Neumond öffnet ein leeres Blatt"
        case .fullMoon:
            moonPhaseText = "Der Vollmond bringt ans Licht, was verborgen war"
        case .waxingCrescent, .waxingGibbous, .firstQuarter:
            moonPhaseText = "Der wachsende Mond nährt deine Intention"
        case .waningCrescent, .waningGibbous, .lastQuarter:
            moonPhaseText = "Der abnehmende Mond lädt zum Loslassen ein"
        }

        let elementWeather: String
        switch dominant {
        case .water:
            elementWeather = intensity > 0.5
                ? "Dein Wasser-Element reagiert stark auf die kosmische Strömung — lass dich nicht mitreißen, sondern fließe bewusst."
                : "Dein Wasser-Element fließt heute ruhig — nutze die Klarheit für tiefe Reflexion."
        case .fire:
            elementWeather = intensity > 0.5
                ? "Dein Feuer-Element wird durch die Sonnenaktivität angefacht — kanalisiere die Energie, bevor sie dich verzehrt."
                : "Dein Feuer brennt heute gleichmäßig — idealer Tag für kreatives Schaffen."
        case .wood:
            elementWeather = intensity > 0.5
                ? "Dein Holz-Element wächst unter dem kosmischen Druck — Widerstand bringt dich weiter als Nachgeben."
                : "Dein Holz-Element steht fest und ruhig — ein guter Tag für neue Anfänge."
        case .earth:
            elementWeather = intensity > 0.5
                ? "Dein Erd-Element spürt die Erschütterungen des Kosmos — bleib geerdet, während andere schwanken."
                : "Dein Erd-Element trägt dich stabil — nutze die Bodenhaftung für praktische Entscheidungen."
        case .metal:
            elementWeather = intensity > 0.5
                ? "Dein Metall-Element schwingt mit der elektromagnetischen Energie — Klarheit kommt durch Reduktion."
                : "Dein Metall-Element reflektiert heute klar — ein Tag der präzisen Einsichten."
        }

        let signEnergy = "\(sun.germanName)-Sonne trifft auf \(moon.germanName)-Mond: \(sunMoonDynamic(sun: sun, moon: moon))"

        return "\(moonPhaseText). \(signEnergy) \(elementWeather)"
    }

    // MARK: - English Pulse

    private static func buildEnglishPulse(
        sun: ZodiacSign, moon: ZodiacSign, dayMaster: HeavenlyStem,
        dominant: CosmicElement, weather: CosmicWeather, intensity: Double
    ) -> String {
        let moonPhaseText: String
        switch weather.moonPhase {
        case .newMoon:
            moonPhaseText = "The New Moon opens a blank page"
        case .fullMoon:
            moonPhaseText = "The Full Moon illuminates what was hidden"
        case .waxingCrescent, .waxingGibbous, .firstQuarter:
            moonPhaseText = "The waxing Moon nourishes your intention"
        case .waningCrescent, .waningGibbous, .lastQuarter:
            moonPhaseText = "The waning Moon invites release"
        }

        let elementWeather: String
        switch dominant {
        case .water:
            elementWeather = intensity > 0.5
                ? "Your Water element responds strongly to the cosmic current — flow consciously, don't drift."
                : "Your Water element flows calmly today — use the clarity for deep reflection."
        case .fire:
            elementWeather = intensity > 0.5
                ? "Your Fire element is stoked by solar activity — channel the energy before it consumes you."
                : "Your Fire burns steadily today — ideal for creative work."
        case .wood:
            elementWeather = intensity > 0.5
                ? "Your Wood element grows under cosmic pressure — resistance will take you further than surrender."
                : "Your Wood element stands calm and steady — a good day for new beginnings."
        case .earth:
            elementWeather = intensity > 0.5
                ? "Your Earth element feels the cosmic tremors — stay grounded while others sway."
                : "Your Earth element carries you steadily — use the stability for practical decisions."
        case .metal:
            elementWeather = intensity > 0.5
                ? "Your Metal element resonates with the electromagnetic energy — clarity comes through reduction."
                : "Your Metal element reflects clearly today — a day for precise insights."
        }

        return "\(moonPhaseText). \(sun.rawValue) Sun meets \(moon.rawValue) Moon. \(elementWeather)"
    }

    // MARK: - Sun-Moon Dynamic

    private static func sunMoonDynamic(sun: ZodiacSign, moon: ZodiacSign) -> String {
        let sunEl = sun.element
        let moonEl = moon.element
        if sunEl == moonEl {
            return "Gleiche Elemente verstärken sich heute."
        }
        // Spannung
        let tensions: Set<Set<String>> = [["fire","water"], ["earth","air"]]
        let pair: Set<String> = [sunEl.rawValue, moonEl.rawValue]
        if tensions.contains(pair) {
            return "Die Spannung zwischen beiden Polen erzeugt heute kreative Reibung."
        }
        return "Die unterschiedlichen Energien ergänzen sich heute harmonisch."
    }
}

// MARK: - Day Pulse Model

struct DayPulse: Equatable {
    let headline: String
    let subtext: String
    let moonPhase: MoonPhase
    let moonIllumination: Double
    let kpIndex: Double
    let intensity: Double        // 0.0–1.0

    static let empty = DayPulse(
        headline: "", subtext: "",
        moonPhase: .newMoon, moonIllumination: 0,
        kpIndex: 0, intensity: 0
    )
}
