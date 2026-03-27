// PersistenceService.swift
// Bazodiac iOS — Lokale Datenpersistenz
//
// Löst PH-4: App vergisst alles nach Neustart.
// Speichert CosmicProfile + BirthData als JSON in UserDefaults.
// Kein Keychain nötig (keine sensiblen Secrets, nur astrologische Daten).

import Foundation

enum PersistenceService {

    private static let profileKey   = "bazodiac.cosmicProfile.v1"
    private static let birthDataKey = "bazodiac.birthData.v1"
    private static let themeKey     = "bazodiac.theme.v1"
    private static let languageKey  = "bazodiac.language.v1"
    private static let dailyQuoteKey   = "bazodiac.dailyQuote.v1"
    private static let dailyQuoteDateKey = "bazodiac.dailyQuoteDate.v1"

    // MARK: - CosmicProfile

    static func saveProfile(_ profile: CosmicProfile) {
        do {
            let data = try JSONEncoder().encode(ProfileStorage(profile))
            UserDefaults.standard.set(data, forKey: profileKey)
        } catch {
            print("⚠️ PersistenceService: Profil konnte nicht gespeichert werden: \(error)")
        }
    }

    static func loadProfile() -> CosmicProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else { return nil }
        do {
            let storage = try JSONDecoder().decode(ProfileStorage.self, from: data)
            return storage.toCosmicProfile()
        } catch {
            print("⚠️ PersistenceService: Profil konnte nicht geladen werden: \(error)")
            return nil
        }
    }

    static func deleteProfile() {
        UserDefaults.standard.removeObject(forKey: profileKey)
    }

    // MARK: - BirthData

    static func saveBirthData(_ data: BirthData) {
        do {
            let encoded = try JSONEncoder().encode(BirthDataStorage(data))
            UserDefaults.standard.set(encoded, forKey: birthDataKey)
        } catch {
            print("⚠️ BirthData nicht gespeichert: \(error)")
        }
    }

    static func loadBirthData() -> BirthData? {
        guard let raw = UserDefaults.standard.data(forKey: birthDataKey),
              let storage = try? JSONDecoder().decode(BirthDataStorage.self, from: raw) else { return nil }
        return storage.toBirthData()
    }

    // MARK: - Theme

    static func saveTheme(_ theme: String) {
        UserDefaults.standard.set(theme, forKey: themeKey)
    }

    static func loadTheme() -> String? {
        UserDefaults.standard.string(forKey: themeKey)
    }

    // MARK: - Language

    static func saveLanguage(_ lang: String) {
        UserDefaults.standard.set(lang, forKey: languageKey)
    }

    static func loadLanguage() -> String? {
        UserDefaults.standard.string(forKey: languageKey)
    }

    // MARK: - Daily Quote (mit TTL = 1 Tag)

    static func saveDailyQuote(_ quote: String, date: Date = Date()) {
        UserDefaults.standard.set(quote, forKey: dailyQuoteKey)
        UserDefaults.standard.set(date, forKey: dailyQuoteDateKey)
    }

    /// Gibt Quote zurück wenn es von heute ist, sonst nil
    static func loadTodayQuote() -> String? {
        guard let savedDate = UserDefaults.standard.object(forKey: dailyQuoteDateKey) as? Date else { return nil }
        guard Calendar.current.isDateInToday(savedDate) else { return nil }
        return UserDefaults.standard.string(forKey: dailyQuoteKey)
    }

    // MARK: - Reset (für Sign-Out)

    static func clearAll() {
        [profileKey, birthDataKey, dailyQuoteKey, dailyQuoteDateKey].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }
}

// MARK: - Codierbare Speicher-Strukturen

/// Flache, codierbare Repräsentation von CosmicProfile
private struct ProfileStorage: Codable {
    let name:           String
    let birthPlace:     String
    let birthDate:      Date
    let latitude:       Double
    let longitude:      Double
    let timezone:       String
    let interpretation: String
    let dailyQuote:     String

    // Western
    let sunSignRaw:         String
    let moonSignRaw:        String
    let ascendantRaw:       String
    let sunDegree:          Double
    let moonDegree:         Double
    let ascendantDegree:    Double
    let planetPositions:    [PlanetStorage]
    let houseStarts:        [Double]

    // BaZi
    let baziPillars: [PillarStorage]

    // WuXing
    let wuxingBalance: [String: Double]
    let dominantElement: String
    let weakestElement:  String
    let wuxingInterpretation: String

    init(_ p: CosmicProfile) {
        name        = p.birthData.name
        birthPlace  = p.birthData.birthPlace
        birthDate   = p.birthData.birthDate
        latitude    = p.birthData.latitude
        longitude   = p.birthData.longitude
        timezone    = p.birthData.timezone
        interpretation = p.interpretation
        dailyQuote  = p.dailyQuote

        let w = p.westernData
        sunSignRaw       = w.sunSign.rawValue
        moonSignRaw      = w.moonSign.rawValue
        ascendantRaw     = w.ascendant.rawValue
        sunDegree        = w.sunDegree
        moonDegree       = w.moonDegree
        ascendantDegree  = w.ascendantDegree
        houseStarts      = w.houseStarts
        planetPositions  = w.planets.map { PlanetStorage($0) }

        baziPillars = [p.baziData.year, p.baziData.month, p.baziData.day, p.baziData.hour].map { PillarStorage($0) }

        let wu = p.wuxingData
        wuxingBalance       = Dictionary(uniqueKeysWithValues: wu.balance.map { ($0.key.rawValue, $0.value) })
        dominantElement     = wu.dominant.rawValue
        weakestElement      = wu.weakest.rawValue
        wuxingInterpretation = wu.interpretation
    }

    func toCosmicProfile() -> CosmicProfile? {
        var bd = BirthData()
        bd.name       = name
        bd.birthPlace = birthPlace
        bd.birthDate  = birthDate
        bd.latitude   = latitude
        bd.longitude  = longitude
        bd.timezone   = timezone

        guard let sun  = ZodiacSign(rawValue: sunSignRaw),
              let moon = ZodiacSign(rawValue: moonSignRaw),
              let asc  = ZodiacSign(rawValue: ascendantRaw) else { return nil }

        let planets = planetPositions.compactMap { $0.toPlanetPosition() }

        let western = WesternData(
            sunSign: sun, moonSign: moon, ascendant: asc,
            sunDegree: sunDegree, moonDegree: moonDegree,
            ascendantDegree: ascendantDegree, planets: planets,
            houseStarts: houseStarts
        )

        guard baziPillars.count == 4 else { return nil }
        let bazi = BaZiData(
            year:  baziPillars[0].toPillar(type: .year)  ?? .fallback(.year),
            month: baziPillars[1].toPillar(type: .month) ?? .fallback(.month),
            day:   baziPillars[2].toPillar(type: .day)   ?? .fallback(.day),
            hour:  baziPillars[3].toPillar(type: .hour)  ?? .fallback(.hour)
        )

        let balance = Dictionary(uniqueKeysWithValues:
            wuxingBalance.compactMap { k, v -> (CosmicElement, Double)? in
                guard let el = CosmicElement(rawValue: k) else { return nil }
                return (el, v)
            }
        )
        let wuxing = WuXingData(
            balance: balance,
            dominant: CosmicElement(rawValue: dominantElement) ?? .water,
            weakest:  CosmicElement(rawValue: weakestElement)  ?? .metal,
            interpretation: wuxingInterpretation
        )

        return CosmicProfile(
            birthData: bd, westernData: western, baziData: bazi,
            wuxingData: wuxing, interpretation: interpretation, dailyQuote: dailyQuote
        )
    }
}

private struct PlanetStorage: Codable {
    let planet: String
    let degree: Double
    let sign: String
    let house: Int
    let isRetrograde: Bool

    init(_ p: PlanetPosition) {
        planet       = p.planet.rawValue
        degree       = p.degree
        sign         = p.sign.rawValue
        house        = p.house
        isRetrograde = p.isRetrograde
    }

    func toPlanetPosition() -> PlanetPosition? {
        guard let pl = Planet(rawValue: planet),
              let sg = ZodiacSign(rawValue: sign) else { return nil }
        return PlanetPosition(planet: pl, degree: degree, sign: sg, house: house, isRetrograde: isRetrograde)
    }
}

private struct PillarStorage: Codable {
    let stemChar: String
    let branchChar: String

    init(_ p: BaZiPillar) {
        stemChar   = p.stem.char
        branchChar = p.branch.char
    }

    func toPillar(type: BaZiPillar.PillarType) -> BaZiPillar? {
        guard let stem   = HeavenlyStemDatabase.stem(forChar: stemChar),
              let branch = EarthlyBranchDatabase.branch(forChar: branchChar) else { return nil }
        return BaZiPillar(type: type, stem: stem, branch: branch, hiddenStems: [])
    }
}

private struct BirthDataStorage: Codable {
    let name: String
    let birthDate: Date
    let birthPlace: String
    let latitude: Double
    let longitude: Double
    let timezone: String

    init(_ d: BirthData) {
        name       = d.name
        birthDate  = d.birthDate
        birthPlace = d.birthPlace
        latitude   = d.latitude
        longitude  = d.longitude
        timezone   = d.timezone
    }

    func toBirthData() -> BirthData {
        var d = BirthData()
        d.name       = name
        d.birthDate  = birthDate
        d.birthPlace = birthPlace
        d.latitude   = latitude
        d.longitude  = longitude
        d.timezone   = timezone
        return d
    }
}

// MARK: - Hilfserweiterungen

extension BaZiPillar {
    /// Fallback-Säule wenn Mapper fehlschlägt
    static func fallback(_ type: PillarType) -> BaZiPillar {
        let s = HeavenlyStemDatabase.all.first ?? HeavenlyStem(char: "壬", pinyin: "rén", english: "Water Yang", element: .water, isYang: true)
        let b = EarthlyBranchDatabase.all.first ?? EarthlyBranch(char: "子", animal: "Rat", animalEmoji: "🐀", element: .water)
        return BaZiPillar(type: type, stem: s, branch: b, hiddenStems: [])
    }
}
