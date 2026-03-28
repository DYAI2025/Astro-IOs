// DetailSheets.swift
// Bazodiac iOS — Detail-Ansichten für die drei Kacheln
//
// 1. SunSignDetailSheet  → Sonnenzeichen + Mond + Aszendent
// 2. YearAnimalDetailSheet → Jahrestier + Tagesmeister + Stunde + Monat
// 3. WuXingDetailSheet → Dominantes Element + alle 5 Anteile

import SwiftUI

// MARK: - 1. Sonnenzeichen Detail

struct SunSignDetailSheet: View {
    let profile: CosmicProfile
    let language: CosmicStore.Language
    @Environment(\.cosmicTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    private var w: WesternData { profile.westernData }
    private var isDE: Bool { language == .german }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                sheetHandle
                    .padding(.bottom, 20)

                // ── Sonnenzeichen (Hauptzeichen) ─────────────────
                signHero(
                    label: isDE ? "DEIN SONNENZEICHEN" : "YOUR SUN SIGN",
                    sign: w.sunSign,
                    degree: w.sunDegree,
                    sfSymbol: "sun.max.fill"
                )
                .padding(.bottom, 28)

                Text(sunSignDescription(w.sunSign))
                    .font(CosmicFont.bodySerif(15))
                    .foregroundStyle(theme.textSecondary)
                    .lineSpacing(6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                GoldLine().padding(.horizontal, 24).padding(.bottom, 20)

                // ── Mondzeichen ──────────────────────────────────
                signRow(
                    label: isDE ? "Mondzeichen" : "Moon Sign",
                    sign: w.moonSign,
                    degree: w.moonDegree,
                    sfSymbol: "moon.fill",
                    description: moonDescription(w.moonSign)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // ── Aszendent ────────────────────────────────────
                signRow(
                    label: isDE ? "Aszendent" : "Ascendant",
                    sign: w.ascendant,
                    degree: w.ascendantDegree,
                    sfSymbol: "arrow.up.circle",
                    description: ascendantDescription(w.ascendant)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Reusable Components

    private var sheetHandle: some View {
        Capsule()
            .fill(theme.gold.opacity(0.25))
            .frame(width: 36, height: 3)
            .padding(.top, 12)
    }

    private func signHero(label: String, sign: ZodiacSign, degree: Double, sfSymbol: String) -> some View {
        VStack(spacing: 12) {
            Text(label)
                .goldLabel(0.5)
                .tracking(5)

            ZStack {
                Circle()
                    .fill(sign.element.color.opacity(0.15))
                    .frame(width: 80, height: 80)
                Circle()
                    .strokeBorder(sign.element.color.opacity(0.4), lineWidth: 1)
                    .frame(width: 80, height: 80)
                Image(systemName: sfSymbol)
                    .font(.system(size: 32, weight: .thin))
                    .foregroundStyle(sign.element.color)
            }

            Text(sign.germanName)
                .font(CosmicFont.display(32))
                .foregroundStyle(theme.textPrimary)

            Text(String(format: "%.1f°", degree))
                .font(CosmicFont.mono(13))
                .foregroundStyle(theme.textTertiary)
        }
    }

    private func signRow(label: String, sign: ZodiacSign, degree: Double, sfSymbol: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(sign.element.color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: sfSymbol)
                        .font(.system(size: 18, weight: .thin))
                        .foregroundStyle(sign.element.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label).goldLabel(0.4)
                    HStack(spacing: 8) {
                        Text(sign.germanName)
                            .font(CosmicFont.heading(17, weight: .light))
                            .foregroundStyle(theme.textPrimary)
                        Text(String(format: "%.1f°", degree))
                            .font(CosmicFont.mono(11))
                            .foregroundStyle(theme.textTertiary)
                    }
                }
                Spacer()
            }

            Text(description)
                .font(CosmicFont.bodySerif(14))
                .foregroundStyle(theme.textSecondary)
                .lineSpacing(5)
        }
        .padding(16)
        .cosmicCard(cornerRadius: 14)
    }

    // MARK: - Beschreibungen

    private func sunSignDescription(_ sign: ZodiacSign) -> String {
        let de: [ZodiacSign: String] = [
            .aries: "Dein Widder-Feuer treibt dich voran — Pioniergeist, Mut und der unwiderstehliche Drang, Erster zu sein. Du lebst mit einer Intensität, die andere mitreißt.",
            .taurus: "Dein Stier-Wesen ist die Verkörperung von Beständigkeit. Du weißt, was gut ist, und du lässt es dir nicht nehmen. Sinnlichkeit und Geduld sind deine stärksten Waffen.",
            .gemini: "Dein Zwillinge-Geist tanzt zwischen Welten. Kommunikation ist dein Element, Neugierde dein Motor. Du siehst immer beide Seiten — und findest oft eine dritte.",
            .cancer: "Dein Krebs-Herz schützt, was es liebt. Tiefe emotionale Intelligenz und die Fähigkeit, Räume des Vertrauens zu schaffen — das ist dein Geschenk an die Welt.",
            .leo: "Dein Löwe strahlt, weil er nicht anders kann. Großzügigkeit, Wärme und ein natürliches Charisma, das Räume füllt — nicht aus Eitelkeit, sondern aus purer Lebensfreude.",
            .virgo: "Dein Jungfrau-Blick sieht, was anderen entgeht. Analytische Brillanz, gepaart mit einem tiefen Wunsch nach Ordnung und Perfektion — du machst die Welt besser, Detail für Detail.",
            .libra: "Dein Waage-Wesen sucht Harmonie in allem. Beziehungen, Ästhetik, Gerechtigkeit — du bist die diplomatische Kraft, die Balance schafft wo Chaos herrscht.",
            .scorpio: "Dein Skorpion kennt die Tiefe wie kein anderes Zeichen. Intensität ist nicht deine Schwäche — sie ist deine Fähigkeit, unter die Oberfläche zu blicken und Wahrheit zu finden.",
            .sagittarius: "Dein Schütze-Geist sucht immer den größeren Horizont. Optimismus, Abenteuerlust und ein unerschütterlicher Glaube daran, dass es noch mehr gibt — das treibt dich an.",
            .capricorn: "Dein Steinbock trägt die Weisheit der Berge. Ausdauer, strategisches Denken und eine Disziplin, die andere staunen lässt — du erreichst Gipfel, die andere nur von fern bewundern.",
            .aquarius: "Dein Wassermann sieht die Zukunft, bevor sie eintrifft. Unkonventionelles Denken, humanitäre Vision und der Mut, anders zu sein — das macht dich zum Visionär.",
            .pisces: "Dein Fische-Wesen spürt, was andere nicht sehen. Intuition, Empathie und eine Verbindung zum Unsichtbaren — du lebst zwischen den Welten und bereicherst beide.",
        ]
        if !isDE {
            let en: [ZodiacSign: String] = [
                .aries: "Your Aries fire drives you forward — pioneer spirit, courage, and an irresistible urge to be first. You live with an intensity that sweeps others along.",
                .taurus: "Your Taurus essence is the embodiment of steadfastness. You know what's good, and you hold on to it. Sensuality and patience are your strongest weapons.",
                .gemini: "Your Gemini mind dances between worlds. Communication is your element, curiosity your engine. You always see both sides — and often find a third.",
                .cancer: "Your Cancer heart protects what it loves. Deep emotional intelligence and the ability to create spaces of trust — that's your gift to the world.",
                .leo: "Your Leo shines because it can't help it. Generosity, warmth, and a natural charisma that fills rooms — not from vanity, but from pure joie de vivre.",
                .virgo: "Your Virgo eye sees what others miss. Analytical brilliance paired with a deep desire for order and perfection — you make the world better, detail by detail.",
                .libra: "Your Libra essence seeks harmony in everything. Relationships, aesthetics, justice — you are the diplomatic force that creates balance where chaos reigns.",
                .scorpio: "Your Scorpio knows depth like no other sign. Intensity is not your weakness — it's your ability to look beneath the surface and find truth.",
                .sagittarius: "Your Sagittarius spirit always seeks the bigger horizon. Optimism, adventure, and an unshakable belief that there's always more — that drives you.",
                .capricorn: "Your Capricorn carries the wisdom of mountains. Endurance, strategic thinking, and a discipline that leaves others in awe.",
                .aquarius: "Your Aquarius sees the future before it arrives. Unconventional thinking, humanitarian vision, and the courage to be different.",
                .pisces: "Your Pisces senses what others can't see. Intuition, empathy, and a connection to the invisible — you live between worlds and enrich both.",
            ]
            return en[sign] ?? ""
        }
        return de[sign] ?? ""
    }

    private func moonDescription(_ sign: ZodiacSign) -> String {
        let de: [ZodiacSign: String] = [
            .aries: "Dein emotionales Temperament ist schnell und direkt. Du brauchst Action, um dich lebendig zu fühlen.",
            .taurus: "Emotionale Sicherheit durch Beständigkeit. Du brauchst das Vertraute, um dich fallenlassen zu können.",
            .gemini: "Deine Gefühle fließen durch Worte. Gespräche sind dein Ventil — Schweigen macht dich unruhig.",
            .cancer: "Tiefe Empfindsamkeit und ein Gedächtnis für Gefühle. Du trägst die Stimmungen anderer mit dir.",
            .leo: "Dein emotionales Selbst braucht Anerkennung und Wärme. Du gibst großzügig — und brauchst das zurück.",
            .virgo: "Du verarbeitest Gefühle analytisch. Ordnung im Außen schafft Ruhe im Inneren.",
            .libra: "Harmonie ist dein emotionales Grundbedürfnis. Konflikte erschüttern dich tiefer als du zeigst.",
            .scorpio: "Emotionale Tiefe ohne Vergleich. Du fühlst alles intensiver — und vergisst nichts.",
            .sagittarius: "Dein emotionales Selbst braucht Freiheit und Horizont. Einengung erstickst du.",
            .capricorn: "Emotionale Zurückhaltung, die Stärke ist, nicht Kälte. Du zeigst Gefühle durch Taten.",
            .aquarius: "Du verarbeitest Gefühle durch Distanz und Überblick. Das ist kein Mangel — es ist Schutz.",
            .pisces: "Grenzenlose Empathie. Du absorbierst die Gefühle deiner Umgebung wie ein Schwamm.",
        ]
        if !isDE {
            let en: [ZodiacSign: String] = [
                .aries: "Your emotional temperament is fast and direct. You need action to feel alive.",
                .taurus: "Emotional security through consistency. You need the familiar to let go.",
                .gemini: "Your feelings flow through words. Conversations are your outlet — silence makes you restless.",
                .cancer: "Deep sensitivity and a memory for emotions. You carry others' moods with you.",
                .leo: "Your emotional self needs recognition and warmth. You give generously — and need it back.",
                .virgo: "You process feelings analytically. Order outside creates calm inside.",
                .libra: "Harmony is your emotional baseline. Conflicts shake you deeper than you show.",
                .scorpio: "Emotional depth without comparison. You feel everything more intensely — and forget nothing.",
                .sagittarius: "Your emotional self needs freedom and horizon. Confinement suffocates you.",
                .capricorn: "Emotional restraint that is strength, not coldness. You show feelings through actions.",
                .aquarius: "You process emotions through distance and overview. That's not a lack — it's protection.",
                .pisces: "Boundless empathy. You absorb the emotions of your environment like a sponge.",
            ]
            return en[sign] ?? ""
        }
        return de[sign] ?? ""
    }

    private func ascendantDescription(_ sign: ZodiacSign) -> String {
        let de: [ZodiacSign: String] = [
            .aries: "Du wirkst energisch und direkt. Dein erster Eindruck: jemand, der weiß, was er will.",
            .taurus: "Du strahlst Ruhe und Verlässlichkeit aus. Menschen fühlen sich in deiner Nähe geerdet.",
            .gemini: "Du wirkst kommunikativ und vielseitig. Dein Charme liegt in deiner intellektuellen Neugierde.",
            .cancer: "Du wirkst fürsorglich und zugänglich. Deine Außenwirkung: jemand, dem man vertrauen kann.",
            .leo: "Du wirkst charismatisch und warmherzig. Dein Auftritt füllt Räume — ohne es zu forcieren.",
            .virgo: "Du wirkst kompetent und aufmerksam. Dein erster Eindruck: jemand, der die Details sieht.",
            .libra: "Du wirkst charmant und ausgeglichen. Dein Auftreten schafft sofort eine angenehme Atmosphäre.",
            .scorpio: "Du wirkst intensiv und geheimnisvoll. Dein Blick verrät: hier ist mehr als man sieht.",
            .sagittarius: "Du wirkst offen und optimistisch. Dein erster Eindruck: jemand, der das Leben feiert.",
            .capricorn: "Du wirkst seriös und kompetent. Dein Auftreten vermittelt: hier steht jemand mit Substanz.",
            .aquarius: "Du wirkst individuell und unkonventionell. Dein erster Eindruck: erfrischend anders.",
            .pisces: "Du wirkst sanft und empathisch. Dein Auftreten: jemand, der zwischen den Zeilen liest.",
        ]
        if !isDE {
            let en: [ZodiacSign: String] = [
                .aries: "You come across as energetic and direct. First impression: someone who knows what they want.",
                .taurus: "You radiate calm and reliability. People feel grounded in your presence.",
                .gemini: "You seem communicative and versatile. Your charm lies in intellectual curiosity.",
                .cancer: "You appear caring and approachable. Your impression: someone trustworthy.",
                .leo: "You seem charismatic and warm. Your presence fills rooms — without forcing it.",
                .virgo: "You appear competent and attentive. First impression: someone who sees the details.",
                .libra: "You come across as charming and balanced. Your demeanor creates comfort instantly.",
                .scorpio: "You seem intense and mysterious. Your look reveals: there's more here than meets the eye.",
                .sagittarius: "You appear open and optimistic. First impression: someone who celebrates life.",
                .capricorn: "You seem serious and capable. Your presence conveys: substance.",
                .aquarius: "You appear individual and unconventional. First impression: refreshingly different.",
                .pisces: "You seem gentle and empathic. Your presence: someone who reads between the lines.",
            ]
            return en[sign] ?? ""
        }
        return de[sign] ?? ""
    }
}

// MARK: - 2. Jahrestier Detail (BaZi)

struct YearAnimalDetailSheet: View {
    let profile: CosmicProfile
    let language: CosmicStore.Language
    @Environment(\.cosmicTheme) private var theme

    private var bazi: BaZiData { profile.baziData }
    private var isDE: Bool { language == .german }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(theme.gold.opacity(0.25))
                    .frame(width: 36, height: 3)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                // ── Jahrestier (Hero) ──────────────────────────
                Text(isDE ? "DEIN JAHRESTIER" : "YOUR YEAR ANIMAL")
                    .goldLabel(0.5)
                    .tracking(5)
                    .padding(.bottom, 12)

                // Tier-Charakter
                ZStack {
                    Circle()
                        .fill(bazi.year.branch.element.color.opacity(0.15))
                        .frame(width: 100, height: 100)
                    Circle()
                        .strokeBorder(bazi.year.branch.element.color.opacity(0.4), lineWidth: 1)
                        .frame(width: 100, height: 100)
                    VStack(spacing: 4) {
                        Text(bazi.year.branch.char)
                            .font(CosmicFont.chinese(36, weight: .light))
                            .foregroundStyle(bazi.year.branch.element.color)
                        Text(bazi.year.branch.animal)
                            .font(CosmicFont.label(8))
                            .tracking(2)
                            .foregroundStyle(bazi.year.branch.element.color.opacity(0.8))
                    }
                }
                .padding(.bottom, 16)

                Text(bazi.year.branch.animal)
                    .font(CosmicFont.display(28))
                    .foregroundStyle(theme.textPrimary)
                    .padding(.bottom, 4)

                Text(yearAnimalDescription(bazi.year.branch.animal))
                    .font(CosmicFont.bodySerif(14))
                    .foregroundStyle(theme.textSecondary)
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)

                GoldLine().padding(.horizontal, 24).padding(.bottom, 20)

                // ── Tagesmeister ─────────────────────────────────
                pillarRow(
                    label: isDE ? "Tagesmeister (Day Master)" : "Day Master",
                    stem: bazi.day.stem,
                    branch: bazi.day.branch,
                    description: isDE
                        ? "Dein wahres Selbst — die Kernessenz deiner Persönlichkeit im BaZi-System."
                        : "Your true self — the core essence of your personality in the BaZi system."
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 14)

                // ── Monatsäule ────────────────────────────────────
                pillarRow(
                    label: isDE ? "Monatssäule" : "Month Pillar",
                    stem: bazi.month.stem,
                    branch: bazi.month.branch,
                    description: isDE
                        ? "Dein Antrieb und deine Karriere-Energie — was dich nach vorne treibt."
                        : "Your drive and career energy — what propels you forward."
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 14)

                // ── Stundensäule ──────────────────────────────────
                pillarRow(
                    label: isDE ? "Stundensäule" : "Hour Pillar",
                    stem: bazi.hour.stem,
                    branch: bazi.hour.branch,
                    description: isDE
                        ? "Dein verborgenes Selbst — die Seite, die nur wenige kennen."
                        : "Your hidden self — the side only few ever see."
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func pillarRow(label: String, stem: HeavenlyStem, branch: EarthlyBranch, description: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                // Stem + Branch Zeichen
                HStack(spacing: 4) {
                    Text(stem.char)
                        .font(CosmicFont.chinese(28, weight: .light))
                        .foregroundStyle(stem.element.color)
                    Text(branch.char)
                        .font(CosmicFont.chinese(28, weight: .light))
                        .foregroundStyle(branch.element.color)
                }
                .frame(width: 60)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label).goldLabel(0.4)
                    Text("\(stem.english) · \(branch.animal)")
                        .font(CosmicFont.heading(14, weight: .light))
                        .foregroundStyle(theme.textPrimary)
                }
                Spacer()

                ElementBadge(element: stem.element, size: 28)
            }

            Text(description)
                .font(CosmicFont.bodySerif(13))
                .foregroundStyle(theme.textSecondary)
                .lineSpacing(4)
        }
        .padding(16)
        .cosmicCard(cornerRadius: 14)
    }

    private func yearAnimalDescription(_ animal: String) -> String {
        let descriptions: [String: String] = [
            "Rat":     "Die Ratte ist clever, anpassungsfähig und voller Einfallsreichtum. Du findest Wege, wo andere Mauern sehen.",
            "Ox":      "Der Ochse verkörpert Ausdauer und stille Stärke. Du baust, was Bestand hat — geduldig und unerschütterlich.",
            "Tiger":   "Der Tiger trägt Mut und Magnetismus. Du betrittst einen Raum und die Energie verändert sich. Furchtlos und lebendig.",
            "Rabbit":  "Der Hase steht für Anmut und diplomatisches Geschick. Du navigierst durch Konflikte mit einer Eleganz, die entwaffnet.",
            "Dragon":  "Der Drache ist Vision und Kraft in Reinform. Du denkst größer als andere — und hast die Energie, es umzusetzen.",
            "Snake":   "Die Schlange besitzt tiefe Weisheit und Intuition. Du siehst unter die Oberfläche der Dinge — immer.",
            "Horse":   "Das Pferd verkörpert Freiheit und Lebenskraft. Du brauchst Bewegung, Raum und den Wind in deinem Gesicht.",
            "Goat":    "Die Ziege steht für Kreativität und Sanftheit. Deine künstlerische Seele sieht Schönheit, wo andere Alltag sehen.",
            "Monkey":  "Der Affe ist Intelligenz und Verspieltheit. Du löst Probleme mit einer Leichtigkeit, die andere verblüfft.",
            "Rooster": "Der Hahn steht für Präzision und Ehrlichkeit. Du sagst, was ist — direkt, klar und ohne Umschweife.",
            "Dog":     "Der Hund verkörpert Loyalität und Gerechtigkeitssinn. Du stehst zu deinen Menschen — kompromisslos und treu.",
            "Pig":     "Das Schwein steht für Großzügigkeit und Genuss. Du lebst mit einer Warmherzigkeit, die ansteckend ist.",
        ]
        return descriptions[animal] ?? "Ein einzigartiges Wesen mit kosmischer Tiefe."
    }
}

// MARK: - 3. Wu-Xing Detail (Dominantes Element + alle 5 Anteile)

struct WuXingDetailSheet: View {
    let profile: CosmicProfile
    let language: CosmicStore.Language
    @Environment(\.cosmicTheme) private var theme

    private var wu: WuXingData { profile.wuxingData }
    private var isDE: Bool { language == .german }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Capsule()
                    .fill(theme.gold.opacity(0.25))
                    .frame(width: 36, height: 3)
                    .padding(.top, 12)
                    .padding(.bottom, 20)

                // ── Dominantes Element (Hero) ─────────────────────
                Text(isDE ? "DEIN DOMINANTES ELEMENT" : "YOUR DOMINANT ELEMENT")
                    .goldLabel(0.5)
                    .tracking(5)
                    .padding(.bottom, 12)

                ZStack {
                    Circle()
                        .fill(wu.dominant.color.opacity(0.18))
                        .frame(width: 100, height: 100)
                    Circle()
                        .strokeBorder(wu.dominant.color.opacity(0.4), lineWidth: 1)
                        .frame(width: 100, height: 100)
                    VStack(spacing: 4) {
                        Text(wu.dominant.chineseChar)
                            .font(CosmicFont.chinese(36, weight: .light))
                            .foregroundStyle(wu.dominant.color)
                        Image(systemName: wu.dominant.symbol)
                            .font(.system(size: 14, weight: .thin))
                            .foregroundStyle(wu.dominant.color.opacity(0.6))
                    }
                }
                .padding(.bottom, 12)

                Text(wu.dominant.germanName)
                    .font(CosmicFont.display(28))
                    .foregroundStyle(theme.textPrimary)
                    .padding(.bottom, 4)

                Text(elementDescription(wu.dominant))
                    .font(CosmicFont.bodySerif(14))
                    .foregroundStyle(theme.textSecondary)
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)

                GoldLine().padding(.horizontal, 24).padding(.bottom, 20)

                // ── Alle 5 Elemente: Verteilung ──────────────────
                Text(isDE ? "DEINE ELEMENT-VERTEILUNG" : "YOUR ELEMENT DISTRIBUTION")
                    .goldLabel(0.4)
                    .tracking(4)
                    .padding(.bottom, 16)

                VStack(spacing: 12) {
                    ForEach(sortedElements(), id: \.0) { element, value in
                        elementBar(element: element, value: value)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // ── Schwächstes Element ──────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        ElementBadge(element: wu.weakest, size: 28)
                        Text(isDE ? "Schwächstes Element: \(wu.weakest.germanName)" : "Weakest Element: \(wu.weakest.germanName)")
                            .font(CosmicFont.heading(13, weight: .light))
                            .foregroundStyle(theme.textPrimary)
                    }
                    Text(weakElementAdvice(wu.weakest))
                        .font(CosmicFont.bodySerif(13))
                        .foregroundStyle(theme.textSecondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .cosmicCard(cornerRadius: 14)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func sortedElements() -> [(CosmicElement, Double)] {
        CosmicElement.allCases.map { el in
            (el, wu.balance[el] ?? 0)
        }.sorted { $0.1 > $1.1 }
    }

    private func elementBar(element: CosmicElement, value: Double) -> some View {
        HStack(spacing: 12) {
            ElementBadge(element: element, size: 28)

            Text(element.germanName)
                .font(CosmicFont.heading(13, weight: .light))
                .foregroundStyle(theme.textPrimary)
                .frame(width: 55, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(theme.goldFaint)
                        .frame(height: 8)
                    Capsule()
                        .fill(element.color.opacity(0.75))
                        .frame(width: geo.size.width * value, height: 8)
                }
            }
            .frame(height: 8)

            Text("\(Int(value * 100))%")
                .font(CosmicFont.mono(11))
                .foregroundStyle(theme.textTertiary)
                .frame(width: 36, alignment: .trailing)
        }
    }

    private func elementDescription(_ element: CosmicElement) -> String {
        switch element {
        case .water: return "Wasser fließt, passt sich an und findet immer einen Weg. Deine Stärke ist Intuition, Tiefe und die Fähigkeit, unter die Oberfläche zu schauen. Du navigierst durch das Leben wie ein Fluss — manchmal still, manchmal reißend, aber immer in Bewegung."
        case .fire: return "Feuer transformiert, inspiriert und wärmt. Deine Energie ist ansteckend, dein Enthusiasmus unwiderstehlich. Du bringst Licht in dunkle Räume und hast den Mut, das zu verbrennen, was nicht mehr dient."
        case .wood: return "Holz wächst, auch durch Beton hindurch. Deine Stärke ist Wachstum, Flexibilität und ein unerschütterlicher Lebenswille. Du biegst dich im Sturm, brichst aber nie."
        case .earth: return "Erde trägt alles. Deine Stärke ist Beständigkeit, Verlässlichkeit und die Fähigkeit, anderen Halt zu geben. Du bist der Grund, auf dem andere bauen."
        case .metal: return "Metall formt, schneidet und reflektiert. Deine Stärke ist Klarheit, Präzision und ein scharfer Geist, der das Wesentliche vom Überflüssigen trennt."
        }
    }

    private func weakElementAdvice(_ element: CosmicElement) -> String {
        switch element {
        case .water: return "Wenig Wasser-Energie bedeutet, dass Intuition und emotionale Tiefe Wachstumsfelder für dich sind. Meditation und Zeit am Wasser können helfen."
        case .fire: return "Wenig Feuer-Energie lädt dich ein, mehr Begeisterung und Spontanität zuzulassen. Kreative Ausdrucksformen stärken dieses Element."
        case .wood: return "Wenig Holz-Energie bedeutet, dass Flexibilität und Neuanfänge Bereiche zum Üben sind. Zeit in der Natur nährt dieses Element."
        case .earth: return "Wenig Erd-Energie weist auf ein Wachstumsfeld bei Stabilität und Verlässlichkeit hin. Routinen und Erdung helfen."
        case .metal: return "Wenig Metall-Energie bedeutet, dass Struktur und klare Grenzen Wachstumsbereiche sind. Aufräumen und Ordnung schaffen stärkt dieses Element."
        }
    }
}
