// BAFEResponseMapper.swift
// Bazodiac iOS — Mapping BAFE JSON-Responses → iOS CosmicModels
//
// Ersetzt alle .mock-Instanzen in Prod-Pfaden durch echte Daten.
// Web-Referenz: src/services/api.ts (mapPillar, signFromIndex, signFromDegrees)

import SwiftUI

// MARK: - Hauptmapper

enum BAFEResponseMapper {

    // MARK: - CosmicProfile erstellen (Gesamt-Einstiegspunkt)

    static func buildProfile(
        from results: BAFEAllResults,
        birthData: BirthData,
        interpretation: String,
        dailyQuote: String
    ) -> CosmicProfile {
        CosmicProfile(
            birthData:      birthData,
            westernData:    mapWestern(results.western),
            baziData:       mapBaZi(results.bazi),
            wuxingData:     mapWuXing(results.wuxing),
            interpretation: interpretation,
            dailyQuote:     dailyQuote
        )
    }

    // MARK: - Western Astrologie

    static func mapWestern(_ raw: BAFEWesternResponse) -> WesternData {

        // Planeten: BAFE liefert bodies["Sun"], ["Moon"] etc.
        let planets: [PlanetPosition] = Planet.allCases.compactMap { planet in
            guard let body = raw.bodies?[planet.bafeKey] else { return nil }
            let eclipticDeg = body.longitude ?? 0
            guard let sign = zodiacSignFromDegrees(eclipticDeg) else { return nil }
            let house = houseFor(degree: eclipticDeg, cusps: raw.houses ?? [:])
            return PlanetPosition(
                planet:       planet,
                degree:       eclipticDeg,
                sign:         sign,
                house:        house,
                isRetrograde: (body.speed ?? 1) < 0
            )
        }

        // Sonne, Mond, Aszendent
        let sunEcliptic = raw.bodies?["Sun"]?.longitude ?? 0
        let moonEcliptic = raw.bodies?["Moon"]?.longitude ?? 0
        let ascDegree = raw.angles?.Ascendant ?? 0

        let sunSign  = zodiacSignFromDegrees(sunEcliptic)  ?? .aries
        let moonSign = zodiacSignFromDegrees(moonEcliptic) ?? .cancer
        let ascSign  = zodiacSignFromDegrees(ascDegree)    ?? .gemini

        // Häuser: Cusp-Grad-Array für Canvas-Rendering
        let houseStarts: [Double] = (1...12).map { i in
            raw.houses?["\(i)"] ?? Double(i - 1) * 30.0
        }

        return WesternData(
            sunSign:         sunSign,
            moonSign:        moonSign,
            ascendant:       ascSign,
            sunDegree:       degreeWithinSign(sunEcliptic),
            moonDegree:      degreeWithinSign(moonEcliptic),
            ascendantDegree: degreeWithinSign(ascDegree),
            planets:         planets,
            houseStarts:     houseStarts
        )
    }

    // MARK: - BaZi Vier Säulen

    static func mapBaZi(_ raw: BAFEBaziResponse) -> BaZiData {
        guard let pillars = raw.pillars else {
            return BaZiData.mock   // Fallback wenn API keinen Wert liefert
        }

        return BaZiData(
            year:  mapPillar(pillars.year,  type: .year),
            month: mapPillar(pillars.month, type: .month),
            day:   mapPillar(pillars.day,   type: .day),
            hour:  mapPillar(pillars.hour,  type: .hour)
        )
    }

    private static func mapPillar(_ raw: BAFERawPillar, type: BaZiPillar.PillarType) -> BaZiPillar {
        let stemChar   = raw.resolvedStem
        let branchChar = raw.resolvedBranch
        let animalName = raw.resolvedAnimal

        // Himmels-Stamm: Chinese char OR Pinyin
        let stem = HeavenlyStemDatabase.stem(forChar: stemChar)
            ?? HeavenlyStem(char: stemChar, pinyin: stemChar, english: stemChar, element: .earth, isYang: true)

        // Erd-Zweig: Chinese char OR Pinyin OR via animal name (DE/EN)
        let branch = EarthlyBranchDatabase.branch(forChar: branchChar)
            ?? EarthlyBranchDatabase.branch(forAnimal: animalName)
            ?? EarthlyBranch(char: branchChar, animal: animalName, animalEmoji: "🌙", element: .earth)

        return BaZiPillar(type: type, stem: stem, branch: branch, hiddenStems: [])
    }

    // MARK: - Wu-Xing Fünf Elemente

    static func mapWuXing(_ raw: BAFEWuXingResponse) -> WuXingData {
        let vec = raw.wu_xing_vector ?? [:]

        // BAFE liefert deutsche UND/ODER englische Keys
        let counts: [CosmicElement: Double] = [
            .wood:  vec["Holz"]   ?? vec["Wood"]  ?? 0,
            .fire:  vec["Feuer"]  ?? vec["Fire"]  ?? 0,
            .earth: vec["Erde"]   ?? vec["Earth"] ?? 0,
            .metal: vec["Metall"] ?? vec["Metal"] ?? 0,
            .water: vec["Wasser"] ?? vec["Water"] ?? 0,
        ]

        // Normalisierung: rohe Counts → 0.0–1.0
        let maxVal = counts.values.max() ?? 1
        let normalized: [CosmicElement: Double] = counts.mapValues { maxVal > 0 ? $0 / maxVal : 0 }

        let dominant: CosmicElement = normalized.max(by: { $0.value < $1.value })?.key
            ?? elementFromBAFEString(raw.dominant_element ?? "")
            ?? .water

        let weakest = normalized.min(by: { $0.value < $1.value })?.key ?? .metal

        return WuXingData(
            balance: normalized,
            dominant: dominant,
            weakest:  weakest,
            interpretation: ""   // wird separat von Gemini befüllt
        )
    }

    // MARK: - Hilfsfunktionen

    /// Ekliptik-Grad → ZodiacSign (wie signFromDegrees in api.ts)
    static func zodiacSignFromDegrees(_ deg: Double) -> ZodiacSign? {
        let normalized = ((deg.truncatingRemainder(dividingBy: 360)) + 360)
            .truncatingRemainder(dividingBy: 360)
        let index = Int(normalized / 30)
        guard index >= 0, index < ZodiacSign.allCases.count else { return nil }
        return ZodiacSign.allCases[index]
    }

    /// 0-basierter Index → ZodiacSign (wie signFromIndex in api.ts)
    static func zodiacSignFromIndex(_ idx: Int) -> ZodiacSign? {
        guard idx >= 0, idx < ZodiacSign.allCases.count else { return nil }
        return ZodiacSign.allCases[idx]
    }

    /// Grad innerhalb des Zeichens (0–29.99°)
    private static func degreeWithinSign(_ eclipticDeg: Double) -> Double {
        eclipticDeg.truncatingRemainder(dividingBy: 30)
    }

    /// Haus-Nummer für einen gegebenen Ekliptik-Grad
    private static func houseFor(degree: Double, cusps: [String: Double]) -> Int {
        let sorted = (1...12).compactMap { i -> (Int, Double)? in
            guard let cusp = cusps["\(i)"] else { return nil }
            return (i, cusp)
        }.sorted { $0.1 < $1.1 }

        var house = 1
        for (h, cusp) in sorted {
            if degree >= cusp { house = h }
        }
        return house
    }

    private static func elementFromBAFEString(_ str: String) -> CosmicElement? {
        switch str.lowercased() {
        case "wood",   "holz":   return .wood
        case "fire",   "feuer":  return .fire
        case "earth",  "erde":   return .earth
        case "metal",  "metall": return .metal
        case "water",  "wasser": return .water
        default: return nil
        }
    }
}

// MARK: - Planet + BAFE Key Mapping

extension Planet {
    /// Der Schlüssel den BAFE für diesen Planeten in `bodies` verwendet
    var bafeKey: String {
        switch self {
        case .sun:     return "Sun"
        case .moon:    return "Moon"
        case .mercury: return "Mercury"
        case .venus:   return "Venus"
        case .mars:    return "Mars"
        case .jupiter: return "Jupiter"
        case .saturn:  return "Saturn"
        case .uranus:  return "Uranus"
        case .neptune: return "Neptune"
        case .pluto:   return "Pluto"
        }
    }
}

// MARK: - Himmels-Stamm Datenbank (alle 10 Stämme)

enum HeavenlyStemDatabase {
    static let all: [HeavenlyStem] = [
        HeavenlyStem(char: "甲", pinyin: "jiǎ",  english: "Wood Yang",   element: .wood,  isYang: true),
        HeavenlyStem(char: "乙", pinyin: "yǐ",   english: "Wood Yin",    element: .wood,  isYang: false),
        HeavenlyStem(char: "丙", pinyin: "bǐng", english: "Fire Yang",   element: .fire,  isYang: true),
        HeavenlyStem(char: "丁", pinyin: "dīng", english: "Fire Yin",    element: .fire,  isYang: false),
        HeavenlyStem(char: "戊", pinyin: "wù",   english: "Earth Yang",  element: .earth, isYang: true),
        HeavenlyStem(char: "己", pinyin: "jǐ",   english: "Earth Yin",   element: .earth, isYang: false),
        HeavenlyStem(char: "庚", pinyin: "gēng", english: "Metal Yang",  element: .metal, isYang: true),
        HeavenlyStem(char: "辛", pinyin: "xīn",  english: "Metal Yin",   element: .metal, isYang: false),
        HeavenlyStem(char: "壬", pinyin: "rén",  english: "Water Yang",  element: .water, isYang: true),
        HeavenlyStem(char: "癸", pinyin: "guǐ",  english: "Water Yin",   element: .water, isYang: false),
    ]

    static func stem(forChar char: String) -> HeavenlyStem? {
        // Match by Chinese character OR Pinyin (BAFE returns Pinyin: "Ji", "Gui", etc.)
        all.first { $0.char == char }
        ?? all.first { $0.pinyin.lowercased().replacingOccurrences(of: "ǐ", with: "i")
            .replacingOccurrences(of: "ǐ", with: "i")
            .replacingOccurrences(of: "ī", with: "i")
            .replacingOccurrences(of: "ǐ", with: "i")
            .replacingOccurrences(of: "ù", with: "u")
            .replacingOccurrences(of: "ēng", with: "eng")
            .replacingOccurrences(of: "īn", with: "in")
            .replacingOccurrences(of: "én", with: "en")
            == char.lowercased()
        }
        ?? stemByPinyinMap[char.lowercased().trimmingCharacters(in: .whitespaces)]
    }

    /// Direct Pinyin → Stem mapping (ASCII, no diacritics)
    private static let stemByPinyinMap: [String: HeavenlyStem] = {
        var map: [String: HeavenlyStem] = [:]
        let pinyinASCII = ["jia","yi","bing","ding","wu","ji","geng","xin","ren","gui"]
        for (i, p) in pinyinASCII.enumerated() where i < all.count {
            map[p] = all[i]
        }
        return map
    }()
}

// MARK: - Erd-Zweig Datenbank (alle 12 Zweige)

enum EarthlyBranchDatabase {
    static let all: [EarthlyBranch] = [
        EarthlyBranch(char: "子", animal: "Rat",     animalEmoji: "🐀", element: .water),
        EarthlyBranch(char: "丑", animal: "Ox",      animalEmoji: "🐂", element: .earth),
        EarthlyBranch(char: "寅", animal: "Tiger",   animalEmoji: "🐅", element: .wood),
        EarthlyBranch(char: "卯", animal: "Rabbit",  animalEmoji: "🐇", element: .wood),
        EarthlyBranch(char: "辰", animal: "Dragon",  animalEmoji: "🐉", element: .earth),
        EarthlyBranch(char: "巳", animal: "Snake",   animalEmoji: "🐍", element: .fire),
        EarthlyBranch(char: "午", animal: "Horse",   animalEmoji: "🐎", element: .fire),
        EarthlyBranch(char: "未", animal: "Goat",    animalEmoji: "🐐", element: .earth),
        EarthlyBranch(char: "申", animal: "Monkey",  animalEmoji: "🐒", element: .metal),
        EarthlyBranch(char: "酉", animal: "Rooster", animalEmoji: "🐓", element: .metal),
        EarthlyBranch(char: "戌", animal: "Dog",     animalEmoji: "🐕", element: .earth),
        EarthlyBranch(char: "亥", animal: "Pig",     animalEmoji: "🐖", element: .water),
    ]

    static func branch(forChar char: String) -> EarthlyBranch? {
        all.first { $0.char == char }
        ?? branchByPinyinMap[char.lowercased().trimmingCharacters(in: .whitespaces)]
    }

    /// Direct Pinyin → Branch mapping (ASCII)
    private static let branchByPinyinMap: [String: EarthlyBranch] = {
        var map: [String: EarthlyBranch] = [:]
        let pinyinASCII = ["zi","chou","yin","mao","chen","si","wu","wei","shen","you","xu","hai"]
        for (i, p) in pinyinASCII.enumerated() where i < all.count {
            map[p] = all[i]
        }
        return map
    }()

    /// Mapping: BAFE-Tiername (DE/EN) → EarthlyBranch
    static func branch(forAnimal animal: String) -> EarthlyBranch? {
        let map: [String: String] = [
            // Deutsch
            "Ratte": "子", "Ochse": "丑", "Tiger": "寅", "Hase": "卯",
            "Drache": "辰", "Schlange": "巳", "Pferd": "午", "Ziege": "未",
            "Affe": "申", "Hahn": "酉", "Hund": "戌", "Schwein": "亥",
            // Englisch
            "Rat": "子", "Ox": "丑", "Rabbit": "卯",
            "Dragon": "辰", "Snake": "巳", "Horse": "午", "Goat": "未",
            "Monkey": "申", "Rooster": "酉", "Dog": "戌", "Pig": "亥",
        ]
        guard let char = map[animal] else { return nil }
        return branch(forChar: char)
    }
}
