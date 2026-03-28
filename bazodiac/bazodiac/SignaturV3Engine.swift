// SignaturV3Engine.swift
// Bazodiac iOS — Bipolar Trail Engine (1:1 Port von bipolar-engine.ts)
//
// 6 Dimensionen → 12 Pole (je 2 gegensätzliche Pole pro Dimension).
// Jeder Pol bewegt sich auf einer eigenen Bahn und zeichnet eine Spur.
// Die akkumulierten Spuren SIND die Signatur.
//
// Konsonanz (d→0): Pole bewegen sich symmetrisch um den Mittelpunkt
// Dissonanz (d→1): Pole bewegen sich gegenläufig DURCH den Mittelpunkt (Lissajous)

import Foundation

// MARK: - Dimension Definition

struct BipolarDimension {
    let id: String
    let poleA: String           // z.B. "Durchsetzung"
    let poleB: String           // z.B. "Hingabe"
    let baseAngle: Double       // Radians — Position auf dem Kreis
    let hz: Double              // Cousto Frequenz → Bewegungsgeschwindigkeit
    let colorA: (r: Float, g: Float, b: Float)
    let colorB: (r: Float, g: Float, b: Float)
}

let bipolarDimensions: [BipolarDimension] = [
    BipolarDimension(id: "assertion",   poleA: "Durchsetzung", poleB: "Hingabe",
                     baseAngle: 0,                  hz: 144.72,
                     colorA: (1.0, 0.15, 0.12),     colorB: (0.68, 0.55, 1.0)),
    BipolarDimension(id: "empathy",     poleA: "Einfühlung",   poleB: "Abgrenzung",
                     baseAngle: .pi / 3,            hz: 210.42,
                     colorA: (0.68, 0.55, 1.0),     colorB: (0.38, 0.52, 0.72)),
    BipolarDimension(id: "creativity",  poleA: "Schöpfung",    poleB: "Struktur",
                     baseAngle: 2 * .pi / 3,        hz: 126.22,
                     colorA: (1.0, 0.72, 0.12),     colorB: (0.20, 0.95, 1.0)),
    BipolarDimension(id: "logic",       poleA: "Analyse",      poleB: "Synthese",
                     baseAngle: .pi,                hz: 141.27,
                     colorA: (0.20, 0.95, 1.0),     colorB: (1.0, 0.40, 0.72)),
    BipolarDimension(id: "intuition",   poleA: "Ahnung",       poleB: "Evidenz",
                     baseAngle: 4 * .pi / 3,        hz: 183.58,
                     colorA: (1.0, 0.88, 0.0),      colorB: (0.38, 0.52, 0.72)),
    BipolarDimension(id: "discipline",  poleA: "Ordnung",      poleB: "Freiheit",
                     baseAngle: 5 * .pi / 3,        hz: 147.85,
                     colorA: (0.38, 0.52, 0.72),    colorB: (1.0, 0.88, 0.0)),
]

// MARK: - Pole State

struct PoleState {
    let dimensionId: String
    let pole: String            // "A" or "B"
    var x: Double = 0
    var y: Double = 0
    var theta: Double = 0
    var radius: Double = 0
    var speed: Double = 0
    var trail: [(x: Double, y: Double)] = []
    let maxTrailLength: Int
    let color: (r: Float, g: Float, b: Float)
}

// MARK: - Engine Config

struct SignaturV3Config {
    var maxR: Double = 150
    var maxTrailLength: Int = 800
    var trailPersistence: Double = 0.82
    var timeScale: Double = 1.0
}

// MARK: - Natal Weights from Profile

enum NatalWeightMapper {
    /// Maps a CosmicProfile to 6 dimension weights [0-1]
    static func fromProfile(_ profile: CosmicProfile) -> [String: Double] {
        let w = profile.westernData
        let wu = profile.wuxingData

        // Map zodiac elements + WuXing balance to dimension weights
        let fireWeight   = wu.balance[.fire] ?? 0
        let waterWeight  = wu.balance[.water] ?? 0
        let woodWeight   = wu.balance[.wood] ?? 0
        let earthWeight  = wu.balance[.earth] ?? 0
        let metalWeight  = wu.balance[.metal] ?? 0

        return [
            "assertion":  clamp01((fireWeight + (w.sunSign.element == .fire ? 0.3 : 0)) / 1.3),
            "empathy":    clamp01((waterWeight + (w.moonSign.element == .water ? 0.3 : 0)) / 1.3),
            "creativity": clamp01((woodWeight + fireWeight) / 2),
            "logic":      clamp01((metalWeight + earthWeight) / 2),
            "intuition":  clamp01((waterWeight + woodWeight) / 2),
            "discipline": clamp01((earthWeight + metalWeight) / 2),
        ]
    }

    private static func clamp01(_ v: Double) -> Double { max(0, min(1, v)) }
}

// MARK: - Bipolar Engine

@MainActor
final class BipolarEngine {

    var poles: [PoleState] = []
    var config: SignaturV3Config
    private var time: Double = 0
    private var dissonance: [String: Double] = [:]

    init(config: SignaturV3Config = SignaturV3Config()) {
        self.config = config
    }

    // MARK: - Initialize

    func initialize(natalWeights: [String: Double], quizWeights: [String: Double] = [:]) {
        poles = []
        time = 0

        // Compute per-dimension dissonance
        dissonance = [:]
        for dim in bipolarDimensions {
            let natal = natalWeights[dim.id] ?? 0.5
            let quiz = quizWeights[dim.id] ?? 0.5
            dissonance[dim.id] = abs(quiz - natal)
        }

        for dim in bipolarDimensions {
            let natalValue = natalWeights[dim.id] ?? 0.5
            let quizValue = quizWeights[dim.id] ?? 0.5
            let hzNorm = logNormHz(dim.hz)

            let baseRadius = config.maxR * lerp(0.25, 0.75, natalValue)
            let baseSpeed = (0.003 + hzNorm * 0.008) * config.timeScale

            for pole in ["A", "B"] {
                let angleOffset = pole == "A" ? 0.0 : .pi
                let startAngle = dim.baseAngle + angleOffset
                let radiusMod = pole == "A" ? 1.0 : lerp(0.7, 1.3, quizValue)
                let speedMod = pole == "A" ? 1.0 : lerp(0.8, 1.2, 1 - quizValue)
                let color = pole == "A" ? dim.colorA : dim.colorB

                poles.append(PoleState(
                    dimensionId: dim.id,
                    pole: pole,
                    x: cos(startAngle) * baseRadius * radiusMod,
                    y: sin(startAngle) * baseRadius * radiusMod,
                    theta: startAngle,
                    radius: baseRadius * radiusMod,
                    speed: baseSpeed * speedMod,
                    trail: [],
                    maxTrailLength: config.maxTrailLength,
                    color: color
                ))
            }
        }
    }

    // MARK: - Tick (per frame)

    func tick(dayHarmonic: DayHarmonicState, kpIndex: Double = 0) {
        time += 1

        for i in stride(from: 0, to: poles.count, by: 2) {
            guard i + 1 < poles.count else { break }
            let dimId = poles[i].dimensionId
            let dimIdx = i / 2
            guard dimIdx < bipolarDimensions.count else { break }
            let dim = bipolarDimensions[dimIdx]
            let d = dissonance[dimId] ?? 0

            // Advance theta
            poles[i].theta += poles[i].speed
            poles[i+1].theta += poles[i+1].speed

            // Symmetric orbit (consonant)
            let symAx = cos(poles[i].theta) * poles[i].radius
            let symAy = sin(poles[i].theta) * poles[i].radius
            let symBx = cos(poles[i+1].theta + .pi) * poles[i+1].radius
            let symBy = sin(poles[i+1].theta + .pi) * poles[i+1].radius

            // Lissajous (dissonant)
            let freqRatio = 1 + hash01(dim.hz, 3) * 2
            let lisAx = cos(poles[i].theta) * poles[i].radius
            let lisAy = sin(poles[i].theta * freqRatio) * poles[i].radius
            let lisBx = cos(poles[i+1].theta + .pi) * poles[i+1].radius
            let lisBy = sin(poles[i+1].theta * freqRatio + .pi) * poles[i+1].radius

            // Blend: d=0 → symmetric, d=1 → lissajous
            var blend = clamp(d * 2, 0, 1)

            // Day-Trace: boost Lissajous for high-Hz dimensions
            if dayHarmonic.mode == .trace {
                let hzNorm = logNormHz(dim.hz)
                if hzNorm >= 0.4 {
                    blend = clamp(blend + dayHarmonic.intensity * 0.6, 0, 1)
                }
            }

            poles[i].x = lerp(symAx, lisAx, blend)
            poles[i].y = lerp(symAy, lisAy, blend)
            poles[i+1].x = lerp(symBx, lisBx, blend)
            poles[i+1].y = lerp(symBy, lisBy, blend)

            // Micro-vibration bei Dissonanz
            if d > 0.1 {
                let vibAmp = d * config.maxR * 0.03
                let vibFreq = 3.0
                let vib = sin(time * vibFreq + dim.baseAngle) * vibAmp
                let perpA = poles[i].theta + .pi / 2
                poles[i].x += cos(perpA) * vib
                poles[i].y += sin(perpA) * vib
                let perpB = poles[i+1].theta + .pi / 2
                poles[i+1].x += cos(perpB) * vib * -1
                poles[i+1].y += sin(perpB) * vib * -1
            }

            // Day-Trace crossing vibration
            if dayHarmonic.mode == .trace && blend > 0.3 {
                let vibAmp = dayHarmonic.intensity * config.maxR * 0.015
                let vibFreq = 6.0 + dayHarmonic.intensity * 8.0
                let crossVib = sin(time * vibFreq + dim.baseAngle * 2) * vibAmp
                let perpA = poles[i].theta + .pi / 2
                poles[i].x += cos(perpA) * crossVib
                poles[i].y += sin(perpA) * crossVib
                poles[i+1].x += cos(perpA) * crossVib * -1
                poles[i+1].y += sin(perpA) * crossVib * -1
            }

            // Solar modulation (Kp storms)
            if kpIndex >= 5 {
                let expansion = (kpIndex / 9.0 - 0.5) * 0.3
                poles[i].x *= (1 + expansion)
                poles[i].y *= (1 + expansion)
                poles[i+1].x *= (1 + expansion)
                poles[i+1].y *= (1 + expansion)
            }

            // Record trail
            recordTrail(&poles[i])
            recordTrail(&poles[i+1])
        }
    }

    private func recordTrail(_ pole: inout PoleState) {
        pole.trail.append((x: pole.x, y: pole.y))
        if pole.trail.count > pole.maxTrailLength {
            pole.trail.removeFirst()
        }
    }

    // MARK: - Math Helpers

    private func clamp(_ v: Double, _ lo: Double, _ hi: Double) -> Double { max(lo, min(hi, v)) }
    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * t }
    private func hash01(_ seed: Double, _ k: Double) -> Double {
        let s = sin(seed * 12.9898 + k * 78.233) * 43758.5453123
        return (s.truncatingRemainder(dividingBy: 1) + 1).truncatingRemainder(dividingBy: 1)
    }
    private func logNormHz(_ freq: Double) -> Double {
        let lo = log(100.0)
        let hi = log(300.0)
        return clamp((log(freq) - lo) / (hi - lo), 0, 1)
    }
}
