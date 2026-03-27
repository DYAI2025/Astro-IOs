//
//  bazodiacTests.swift
//  bazodiacTests
//

import Testing
@testable import bazodiac

// MARK: - CosmicElement Tests

struct CosmicElementTests {

    @Test func allCasesHaveUniqueChineseChars() {
        let chars = CosmicElement.allCases.map(\.chineseChar)
        #expect(Set(chars).count == 5, "Each element must have a unique Chinese character")
    }

    @Test func allCasesHaveUniqueGermanNames() {
        let names = CosmicElement.allCases.map(\.germanName)
        #expect(Set(names).count == 5, "Each element must have a unique German name")
    }

    @Test func generatingCycleIsComplete() {
        // Wood → Fire → Earth → Metal → Water → Wood
        var current = CosmicElement.wood
        var visited: [CosmicElement] = [current]
        for _ in 0..<4 {
            current = current.generates
            visited.append(current)
        }
        #expect(visited.count == 5)
        #expect(current.generates == .wood, "Generating cycle must loop back to Wood")
    }

    @Test func controllingCycleIsComplete() {
        // Wood → Earth → Water → Fire → Metal → Wood
        var current = CosmicElement.wood
        for _ in 0..<4 { current = current.controls }
        #expect(current.controls == .wood, "Controlling cycle must loop back to Wood")
    }

    @Test func allElementsHaveNonEmptySymbols() {
        for element in CosmicElement.allCases {
            #expect(!element.symbol.isEmpty,
                    "Element \(element.rawValue) must have a non-empty SF Symbol name")
        }
    }
}

// MARK: - WuXing Tests

struct WuXingTests {

    @Test func mockHasAllFiveElements() {
        let mock = WuXingData.mock
        #expect(mock.balance.keys.count == 5)
    }

    @Test func mockBalanceValuesAreNormalized() {
        for (element, value) in WuXingData.mock.balance {
            #expect(value >= 0.0 && value <= 1.0,
                    "Element \(element.rawValue) balance \(value) must be 0–1")
        }
    }

    @Test func mockDominantIsWater() {
        #expect(WuXingData.mock.dominant == .water)
    }

    @Test func mockWeakestIsMetal() {
        #expect(WuXingData.mock.weakest == .metal)
    }

    @Test func pentagonValuesCountMatchesElementCount() {
        #expect(WuXingData.mock.pentagonValues.count == CosmicElement.allCases.count)
    }
}

// MARK: - BaZi Tests

struct BaZiTests {

    @Test func mockHasFourPillars() {
        #expect(BaZiData.mock.allPillars.count == 4)
    }

    @Test func pillarTypesAreCorrect() {
        let mock = BaZiData.mock
        #expect(mock.year.type  == .year)
        #expect(mock.month.type == .month)
        #expect(mock.day.type   == .day)
        #expect(mock.hour.type  == .hour)
    }

    @Test func allPillarsHaveNonEmptyChars() {
        for pillar in BaZiData.mock.allPillars {
            #expect(!pillar.stem.char.isEmpty,   "Stem char empty for \(pillar.type.rawValue)")
            #expect(!pillar.branch.char.isEmpty, "Branch char empty for \(pillar.type.rawValue)")
            #expect(!pillar.branch.animalEmoji.isEmpty)
        }
    }

    @Test func pillarTypeLabelsAreNonEmpty() {
        for type_ in [BaZiPillar.PillarType.year, .month, .day, .hour] {
            #expect(!type_.englishLabel.isEmpty)
            #expect(!type_.germanLabel.isEmpty)
            #expect(!type_.description.isEmpty)
        }
    }
}

// MARK: - Western Astrology Tests

struct WesternTests {

    @Test func mockHasTenPlanets() {
        #expect(WesternData.mock.planets.count == 10)
    }

    @Test func mockHasTwelveHouses() {
        #expect(WesternData.mock.houseStarts.count == 12)
    }

    @Test func allPlanetDegreesAreInEclipticRange() {
        for planet in WesternData.mock.planets {
            #expect(planet.degree >= 0 && planet.degree < 360,
                    "\(planet.planet.rawValue) degree \(planet.degree) out of 0–360 range")
        }
    }

    @Test func zodiacSignStartDegreesAreSequential() {
        for (i, sign) in ZodiacSign.allCases.enumerated() {
            #expect(sign.startDegree == Double(i) * 30.0,
                    "\(sign.rawValue) startDegree should be \(Double(i) * 30.0)")
        }
    }

    @Test func allZodiacGlyphsAreNonEmpty() {
        for sign in ZodiacSign.allCases {
            #expect(!sign.glyph.isEmpty, "\(sign.rawValue) must have a glyph")
        }
    }

    @Test func allPlanetGlyphsAreNonEmpty() {
        for planet in Planet.allCases {
            #expect(!planet.glyph.isEmpty, "\(planet.rawValue) must have a glyph")
        }
    }
}

// MARK: - CosmicProfile Tests

struct CosmicProfileTests {

    @Test func mockHasNonEmptyInterpretation() {
        #expect(!CosmicProfile.mock.interpretation.isEmpty)
    }

    @Test func mockHasNonEmptyDailyQuote() {
        #expect(!CosmicProfile.mock.dailyQuote.isEmpty)
    }

    @Test func mockBirthPlaceIsSet() {
        #expect(!CosmicProfile.mock.birthData.birthPlace.isEmpty)
    }
}

// MARK: - CosmicStore Tests

@MainActor
struct CosmicStoreTests {

    @Test func initialPhaseIsSplash() {
        let store = CosmicStore()
        #expect(store.appPhase == .splash)
    }

    @Test func initialTabIsHome() {
        let store = CosmicStore()
        #expect(store.selectedTab == .home)
    }

    @Test func displayNameFallsBackWhenEmpty() {
        let store = CosmicStore()
        store.birthData.name = ""
        #expect(store.displayName == "Dein Kosmos")
    }

    @Test func displayNameUsesNameWhenSet() {
        let store = CosmicStore()
        store.birthData.name = "Layla"
        #expect(store.displayName == "Layla")
    }

    @Test func displayNameTrimsWhitespace() {
        let store = CosmicStore()
        store.birthData.name = "  Layla  "
        #expect(store.displayName == "Layla")
    }

    @Test func enterAppGoesToDashboardWhenProfileExists() {
        let store = CosmicStore()
        store.profile = .mock
        store.enterApp(language: .german)
        #expect(store.appPhase == .dashboard)
    }

    @Test func enterAppGoesToBirthFormWhenNoProfile() {
        let store = CosmicStore()
        store.profile = nil
        store.enterApp(language: .english)
        #expect(store.appPhase == .birthForm)
    }

    @Test func signOutResetsToSplash() {
        let store = CosmicStore()
        store.profile = .mock
        store.appPhase = .dashboard
        store.signOut()
        #expect(store.appPhase == .splash)
        #expect(store.profile == nil)
        #expect(store.birthData.name.isEmpty)
    }

    @Test func languageDefaultsToGerman() {
        let store = CosmicStore()
        #expect(store.language == .german)
    }

    @Test func allTabsHaveNonEmptyLabels() {
        for tab in CosmicStore.Tab.allCases {
            #expect(!tab.label.isEmpty)
            #expect(!tab.icon.isEmpty)
        }
    }
}
