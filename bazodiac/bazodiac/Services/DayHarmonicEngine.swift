// DayHarmonicEngine.swift
// Bazodiac iOS — Day Pulse / Day Trace Berechnung
//
// 1:1 Port von day-harmonic.ts
//
// Der Harmony Index H wird als Kosinus-Ähnlichkeit zwischen den
// normalisierten Wu-Xing-Vektoren aus Western- und BaZi-Astrologie berechnet.
//
// H ≥ 0.50 → Trace (Pole kreuzen sich, etwas Konkretes passiert)
// H <  0.50 → Pulse (symmetrische Pole, ruhiger Rhythmus)
//
// Intensity = |H - 0.45| / 0.55 (Distanz vom Zufalls-Baseline)

import Foundation

// MARK: - Day Mode

enum DayMode: String {
    case pulse = "pulse"   // ~65–70% der Tage, ruhig, symmetrisch
    case trace = "trace"   // ~30–35% der Tage, Kreuzung, geladen
}

// MARK: - Day Harmonic State

struct DayHarmonicState: Equatable {
    let harmonyIndex: Double    // 0–1
    let mode: DayMode
    let intensity: Double       // 0–1

    static let neutral = DayHarmonicState(harmonyIndex: 0.45, mode: .pulse, intensity: 0)
}

// MARK: - Engine

enum DayHarmonicEngine {

    private static let HARMONY_RANDOM_BASELINE = 0.45
    private static let HARMONY_RANGE = 0.55  // 1.0 - baseline

    /// Berechnet DayHarmonicState aus dem Harmony Index
    static func compute(harmonyIndex: Double) -> DayHarmonicState {
        let h = clamp(harmonyIndex, 0, 1)
        let mode: DayMode = h >= 0.50 ? .trace : .pulse
        let intensity = clamp(abs(h - HARMONY_RANDOM_BASELINE) / HARMONY_RANGE, 0, 1)
        return DayHarmonicState(harmonyIndex: h, mode: mode, intensity: intensity)
    }

    /// Berechnet H als Kosinus-Ähnlichkeit zwischen Western und BaZi Wu-Xing-Vektoren
    static func computeHarmonyIndex(profile: CosmicProfile) -> Double {
        // Western Wu-Xing Vektor: aus Planetenpositionen → Element-Verteilung
        let westernVec = westernWuXingVector(profile.westernData)
        // BaZi Wu-Xing Vektor: aus den 4 Säulen-Elementen
        let baziVec = baziWuXingVector(profile.baziData)

        return cosineSimilarity(westernVec, baziVec)
    }

    /// Full Pipeline: Profil → H → DayHarmonicState
    static func fromProfile(_ profile: CosmicProfile) -> DayHarmonicState {
        let h = computeHarmonyIndex(profile: profile)
        return compute(harmonyIndex: h)
    }

    // MARK: - Western Wu-Xing Vektor

    /// Leitet einen Wu-Xing-Vektor aus den Western-Planetenpositionen ab.
    /// Jedes Zodiac-Element (fire/earth/air/water) wird auf Wu-Xing gemappt.
    private static func westernWuXingVector(_ data: WesternData) -> [Double] {
        // Zodiac-Element → Wu-Xing Mapping:
        //   fire  → Fire
        //   earth → Earth
        //   air   → Metal (Luft = Klarheit, Metall-Qualität)
        //   water → Water
        //   + Wood wird aus der Balance der anderen abgeleitet

        var counts: [CosmicElement: Double] = [
            .wood: 0, .fire: 0, .earth: 0, .metal: 0, .water: 0
        ]

        // Sun, Moon, Ascendant gewichtet
        let weighted: [(ZodiacSign, Double)] = [
            (data.sunSign, 3.0),
            (data.moonSign, 2.0),
            (data.ascendant, 1.5),
        ]

        // Alle Planeten mit Gewicht 1.0
        let planetWeighted = data.planets.map { ($0.sign, 1.0) }

        for (sign, weight) in weighted + planetWeighted {
            switch sign.element {
            case .fire:  counts[.fire, default: 0]  += weight
            case .earth: counts[.earth, default: 0] += weight
            case .air:   counts[.metal, default: 0] += weight  // Air → Metal
            case .water: counts[.water, default: 0] += weight
            }
        }

        // Wood als Ergänzung: Durchschnitt der niedrigsten zwei → Wood
        let sorted = counts.values.sorted()
        counts[.wood] = (sorted[0] + sorted[1]) / 2

        return normalize(counts)
    }

    // MARK: - BaZi Wu-Xing Vektor

    /// Leitet den Wu-Xing-Vektor aus den 4 BaZi-Säulen ab.
    /// Jede Säule hat Stem-Element + Branch-Element.
    private static func baziWuXingVector(_ data: BaZiData) -> [Double] {
        var counts: [CosmicElement: Double] = [
            .wood: 0, .fire: 0, .earth: 0, .metal: 0, .water: 0
        ]

        // Gewichte: Tag(0.40) > Jahr(0.25) > Monat(0.20) > Stunde(0.15)
        let pillars: [(BaZiPillar, Double)] = [
            (data.day,   0.40),
            (data.year,  0.25),
            (data.month, 0.20),
            (data.hour,  0.15),
        ]

        for (pillar, weight) in pillars {
            counts[pillar.stem.element, default: 0]   += weight
            counts[pillar.branch.element, default: 0] += weight * 0.7 // Branch etwas schwächer
        }

        return normalize(counts)
    }

    // MARK: - Math Helpers

    /// Normalisiert Element-Counts zu einem 5D-Einheitsvektor [wood, fire, earth, metal, water]
    private static func normalize(_ counts: [CosmicElement: Double]) -> [Double] {
        let order: [CosmicElement] = [.wood, .fire, .earth, .metal, .water]
        let vec = order.map { counts[$0] ?? 0 }
        let magnitude = sqrt(vec.reduce(0) { $0 + $1 * $1 })
        guard magnitude > 0 else { return [0.2, 0.2, 0.2, 0.2, 0.2] }
        return vec.map { $0 / magnitude }
    }

    /// Kosinus-Ähnlichkeit zweier Vektoren
    private static func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0.45 }
        let dot = zip(a, b).reduce(0.0) { $0 + $1.0 * $1.1 }
        let magA = sqrt(a.reduce(0) { $0 + $1 * $1 })
        let magB = sqrt(b.reduce(0) { $0 + $1 * $1 })
        guard magA > 0, magB > 0 else { return 0.45 }
        return clamp(dot / (magA * magB), 0, 1)
    }

    private static func clamp(_ v: Double, _ lo: Double, _ hi: Double) -> Double {
        max(lo, min(hi, v))
    }
}
