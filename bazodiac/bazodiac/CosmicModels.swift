// CosmicModels.swift
// Bazodiac iOS — All domain models for Western Astrology, BaZi, Wu-Xing
//
// Data shapes mirror the BAFE API response structure from the web app.

import SwiftUI

// MARK: - Birth Data

struct BirthData: Equatable, Codable {
    var name: String = ""
    var birthDate: Date = {
        var c = DateComponents()
        c.year = 1990; c.month = 1; c.day = 15
        c.hour = 14;   c.minute = 30
        return Calendar.current.date(from: c) ?? Date()
    }()
    var birthPlace: String = ""
    var latitude:  Double = 0
    var longitude: Double = 0
    var timezone:  String = TimeZone.current.identifier
}

// MARK: - Wu-Xing / Five Elements

enum CosmicElement: String, CaseIterable, Identifiable {
    case wood  = "Wood"
    case fire  = "Fire"
    case earth = "Earth"
    case metal = "Metal"
    case water = "Water"

    var id: String { rawValue }

    var chineseChar: String {
        switch self {
        case .wood:  return "木"
        case .fire:  return "火"
        case .earth: return "土"
        case .metal: return "金"
        case .water: return "水"
        }
    }

    var germanName: String {
        switch self {
        case .wood:  return "Holz"
        case .fire:  return "Feuer"
        case .earth: return "Erde"
        case .metal: return "Metall"
        case .water: return "Wasser"
        }
    }

    var color: Color {
        switch self {
        case .wood:  return .elementWood
        case .fire:  return .elementFire
        case .earth: return .elementEarth
        case .metal: return .elementMetal
        case .water: return .elementWater
        }
    }

    var symbol: String {
        switch self {
        case .wood:  return "leaf.fill"
        case .fire:  return "flame.fill"
        case .earth: return "mountain.2.fill"
        case .metal: return "circle.hexagongrid.fill"
        case .water: return "drop.fill"
        }
    }

    /// Generating cycle: Wood → Fire → Earth → Metal → Water → Wood
    var generates: CosmicElement {
        switch self {
        case .wood:  return .fire
        case .fire:  return .earth
        case .earth: return .metal
        case .metal: return .water
        case .water: return .wood
        }
    }

    /// Controlling cycle: Wood → Earth → Water → Fire → Metal → Wood
    var controls: CosmicElement {
        switch self {
        case .wood:  return .earth
        case .earth: return .water
        case .water: return .fire
        case .fire:  return .metal
        case .metal: return .wood
        }
    }
}

// MARK: - Western Zodiac

enum ZodiacSign: String, CaseIterable, Identifiable {
    case aries        = "Aries"
    case taurus       = "Taurus"
    case gemini       = "Gemini"
    case cancer       = "Cancer"
    case leo          = "Leo"
    case virgo        = "Virgo"
    case libra        = "Libra"
    case scorpio      = "Scorpio"
    case sagittarius  = "Sagittarius"
    case capricorn    = "Capricorn"
    case aquarius     = "Aquarius"
    case pisces       = "Pisces"

    var id: String { rawValue }

    /// Full Unicode astrological symbol — for regular Text views
    var glyph: String {
        let glyphs = ["♈", "♉", "♊", "♋", "♌", "♍", "♎", "♏", "♐", "♑", "♒", "♓"]
        return glyphs[ZodiacSign.allCases.firstIndex(of: self) ?? 0]
    }

    /// 2-letter abbreviation for Canvas rendering (SF font lacks astrological block)
    var canvasLabel: String {
        let labels = ["AR", "TA", "GE", "CN", "LE", "VI", "LI", "SC", "SG", "CP", "AQ", "PI"]
        return labels[ZodiacSign.allCases.firstIndex(of: self) ?? 0]
    }

    var element: ZodiacElement {
        switch self {
        case .aries, .leo, .sagittarius:        return .fire
        case .taurus, .virgo, .capricorn:       return .earth
        case .gemini, .libra, .aquarius:        return .air
        case .cancer, .scorpio, .pisces:        return .water
        }
    }

    var quality: ZodiacQuality {
        switch self {
        case .aries, .cancer, .libra, .capricorn:          return .cardinal
        case .taurus, .leo, .scorpio, .aquarius:            return .fixed
        case .gemini, .virgo, .sagittarius, .pisces:        return .mutable
        }
    }

    /// Start degree in the ecliptic (0° = Aries)
    var startDegree: Double {
        Double(ZodiacSign.allCases.firstIndex(of: self) ?? 0) * 30.0
    }

    var color: Color {
        element.color
    }

    var germanName: String {
        let names = ["Widder","Stier","Zwillinge","Krebs","Löwe","Jungfrau",
                     "Waage","Skorpion","Schütze","Steinbock","Wassermann","Fische"]
        return names[ZodiacSign.allCases.firstIndex(of: self) ?? 0]
    }
}

enum ZodiacElement: String {
    case fire, earth, air, water

    var color: Color {
        switch self {
        case .fire:  return .zodiacFire
        case .earth: return .zodiacEarth
        case .air:   return .zodiacAir
        case .water: return .zodiacWater
        }
    }
}

enum ZodiacQuality: String {
    case cardinal = "Kardinal"
    case fixed    = "Fix"
    case mutable  = "Mutable"
}

// MARK: - Planet

enum Planet: String, CaseIterable, Identifiable {
    case sun     = "Sun"
    case moon    = "Moon"
    case mercury = "Mercury"
    case venus   = "Venus"
    case mars    = "Mars"
    case jupiter = "Jupiter"
    case saturn  = "Saturn"
    case uranus  = "Uranus"
    case neptune = "Neptune"
    case pluto   = "Pluto"

    var id: String { rawValue }

    var glyph: String {
        switch self {
        case .sun:     return "☉"
        case .moon:    return "☽"
        case .mercury: return "☿"
        case .venus:   return "♀"
        case .mars:    return "♂"
        case .jupiter: return "♃"
        case .saturn:  return "♄"
        case .uranus:  return "♅"
        case .neptune: return "♆"
        case .pluto:   return "♇"
        }
    }

    var germanName: String {
        switch self {
        case .sun:     return "Sonne"
        case .moon:    return "Mond"
        case .mercury: return "Merkur"
        case .venus:   return "Venus"
        case .mars:    return "Mars"
        case .jupiter: return "Jupiter"
        case .saturn:  return "Saturn"
        case .uranus:  return "Uranus"
        case .neptune: return "Neptun"
        case .pluto:   return "Pluto"
        }
    }

    /// SF Symbol name — used in SwiftUI views (SF font can't render classic astrological glyphs)
    var sfSymbol: String {
        switch self {
        case .sun:     return "sun.max.fill"
        case .moon:    return "moon.fill"
        case .mercury: return "waveform.path.ecg"
        case .venus:   return "heart.circle.fill"
        case .mars:    return "arrow.up.right.circle.fill"
        case .jupiter: return "circle.hexagongrid.fill"
        case .saturn:  return "rotate.3d"
        case .uranus:  return "bolt.circle.fill"
        case .neptune: return "water.waves"
        case .pluto:   return "circle.dotted"
        }
    }

    var color: Color {
        switch self {
        case .sun:     return Color(hex: "#FFD700")
        case .moon:    return Color(hex: "#C0C0C0")
        case .mercury: return Color(hex: "#A0C4FF")
        case .venus:   return Color(hex: "#FFB3C6")
        case .mars:    return Color(hex: "#FF6B4A")
        case .jupiter: return Color(hex: "#FFA040")
        case .saturn:  return Color(hex: "#D4AF37")
        case .uranus:  return Color(hex: "#80DEEA")
        case .neptune: return Color(hex: "#7986CB")
        case .pluto:   return Color(hex: "#CE93D8")
        }
    }
}

struct PlanetPosition: Identifiable {
    let id   = UUID()
    let planet: Planet
    let degree: Double    // ecliptic degree 0–360
    let sign:   ZodiacSign
    let house:  Int        // 1–12
    let isRetrograde: Bool
}

// MARK: - Western Chart Data

struct WesternData {
    let sunSign:         ZodiacSign
    let moonSign:        ZodiacSign
    let ascendant:       ZodiacSign
    let sunDegree:       Double   // within sign
    let moonDegree:      Double
    let ascendantDegree: Double
    let planets:         [PlanetPosition]
    let houseStarts:     [Double] // 12 house cusp degrees (ecliptic)

    /// Mock data for design concept
    static let mock = WesternData(
        sunSign:         .capricorn,
        moonSign:        .scorpio,
        ascendant:       .gemini,
        sunDegree:       24.7,
        moonDegree:      11.3,
        ascendantDegree: 7.9,
        planets: [
            PlanetPosition(planet: .sun,     degree: 294.7, sign: .capricorn,   house:  8, isRetrograde: false),
            PlanetPosition(planet: .moon,    degree: 221.3, sign: .scorpio,     house:  6, isRetrograde: false),
            PlanetPosition(planet: .mercury, degree: 280.5, sign: .capricorn,   house:  8, isRetrograde: false),
            PlanetPosition(planet: .venus,   degree: 310.2, sign: .aquarius,    house:  9, isRetrograde: false),
            PlanetPosition(planet: .mars,    degree: 23.8,  sign: .aries,       house: 11, isRetrograde: false),
            PlanetPosition(planet: .jupiter, degree: 98.1,  sign: .cancer,      house:  2, isRetrograde: false),
            PlanetPosition(planet: .saturn,  degree: 289.6, sign: .capricorn,   house:  8, isRetrograde: false),
            PlanetPosition(planet: .uranus,  degree: 271.4, sign: .sagittarius, house:  7, isRetrograde: false),
            PlanetPosition(planet: .neptune, degree: 280.2, sign: .capricorn,   house:  8, isRetrograde: false),
            PlanetPosition(planet: .pluto,   degree: 226.8, sign: .scorpio,     house:  6, isRetrograde: false),
        ],
        houseStarts: [67.9, 107.4, 137.8, 157.5, 177.2, 207.6,
                      247.9, 287.4, 317.8, 337.5, 357.2,  27.6]
    )
}

// MARK: - BaZi / Four Pillars

struct HeavenlyStem: Identifiable {
    let id         = UUID()
    let char:      String
    let pinyin:    String
    let english:   String
    let element:   CosmicElement
    let isYang:    Bool
}

struct EarthlyBranch: Identifiable {
    let id:         UUID   = UUID()
    let char:       String
    let animal:     String
    let animalEmoji: String
    let element:    CosmicElement
}

struct BaZiPillar: Identifiable {
    let id           = UUID()
    let type:        PillarType
    let stem:        HeavenlyStem
    let branch:      EarthlyBranch
    let hiddenStems: [HeavenlyStem]

    enum PillarType: String {
        case year  = "年柱"
        case month = "月柱"
        case day   = "日柱"
        case hour  = "時柱"

        var englishLabel: String {
            switch self {
            case .year:  return "Year"
            case .month: return "Month"
            case .day:   return "Day"
            case .hour:  return "Hour"
            }
        }

        var germanLabel: String {
            switch self {
            case .year:  return "Jahr"
            case .month: return "Monat"
            case .day:   return "Tag"
            case .hour:  return "Stunde"
            }
        }

        var description: String {
            switch self {
            case .year:  return "Äußere Persona"
            case .month: return "Karriere & Antrieb"
            case .day:   return "Wahres Selbst"
            case .hour:  return "Verborgenes Selbst"
            }
        }
    }
}

struct BaZiData {
    let year:  BaZiPillar
    let month: BaZiPillar
    let day:   BaZiPillar
    let hour:  BaZiPillar

    var allPillars: [BaZiPillar] { [year, month, day, hour] }

    /// Mock data: 1990-01-15, 14:30 Munich
    /// (Chinese New Year 1990 = Jan 27, so Jan 15 = Ji-Si year / Gui-Chou month / Ren-Yin day / Gui-Wei hour)
    static let mock: BaZiData = {
        let stems: [HeavenlyStem] = [
            HeavenlyStem(char: "己", pinyin: "jǐ",   english: "Earth Yin",   element: .earth, isYang: false),
            HeavenlyStem(char: "癸", pinyin: "guǐ",  english: "Water Yin",   element: .water, isYang: false),
            HeavenlyStem(char: "壬", pinyin: "rén",  english: "Water Yang",  element: .water, isYang: true),
            HeavenlyStem(char: "癸", pinyin: "guǐ",  english: "Water Yin",   element: .water, isYang: false),
        ]
        let branches: [EarthlyBranch] = [
            EarthlyBranch(char: "巳", animal: "Snake",  animalEmoji: "🐍", element: .fire),
            EarthlyBranch(char: "丑", animal: "Ox",     animalEmoji: "🐂", element: .earth),
            EarthlyBranch(char: "寅", animal: "Tiger",  animalEmoji: "🐅", element: .wood),
            EarthlyBranch(char: "未", animal: "Goat",   animalEmoji: "🐐", element: .earth),
        ]
        return BaZiData(
            year:  BaZiPillar(type: .year,  stem: stems[0], branch: branches[0], hiddenStems: []),
            month: BaZiPillar(type: .month, stem: stems[1], branch: branches[1], hiddenStems: []),
            day:   BaZiPillar(type: .day,   stem: stems[2], branch: branches[2], hiddenStems: []),
            hour:  BaZiPillar(type: .hour,  stem: stems[3], branch: branches[3], hiddenStems: [])
        )
    }()
}

// MARK: - Wu-Xing Data

struct WuXingData {
    let balance:          [CosmicElement: Double]   // 0.0–1.0 per element
    let dominant:         CosmicElement
    let weakest:          CosmicElement
    let interpretation:   String

    /// Normalized 0–1 scores sorted by element order
    var pentagonValues: [Double] {
        CosmicElement.allCases.map { balance[$0] ?? 0 }
    }

    static let mock = WuXingData(
        balance: [
            CosmicElement.wood:  0.45,
            CosmicElement.fire:  0.20,
            CosmicElement.earth: 0.60,
            CosmicElement.metal: 0.15,
            CosmicElement.water: 0.80,
        ],
        dominant: .water,
        weakest:  .metal,
        interpretation: "Dein Wasserenergie dominiert — Intuition, Fluss und Tiefe prägen deinen Weg. Die schwache Metallenergie lädt dich ein, Struktur und Präzision als Wachstumsfeld zu erkunden."
    )
}

// MARK: - Full Cosmic Profile

struct CosmicProfile {
    let birthData:       BirthData
    let westernData:     WesternData
    let baziData:        BaZiData
    let wuxingData:      WuXingData
    let interpretation:  String
    let dailyQuote:      String

    static let mock = CosmicProfile(
        birthData: {
            var b = BirthData()
            b.name = "Layla"
            b.birthPlace = "München, Deutschland"
            return b
        }(),
        westernData:    .mock,
        baziData:       .mock,
        wuxingData:     .mock,
        interpretation: "Deine kosmische Signatur vereint die Erdbeständigkeit des Steinbocks mit der Tiefe des Skorpion-Mondes. Der Zwillinge-Aszendent verleiht dir communicativen Charme und intellektuelle Neugierde. Im BaZi dominiert das Wasserelement, das deine intuitive, fließende Natur bekräftigt.",
        dailyQuote:     "Die Sterne erzwingen nichts, sie laden ein. Der Atlas zeigt den Weg, den du bereits gehst."
    )
}
