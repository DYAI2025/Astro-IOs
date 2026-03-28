// DayModeTextGenerator.swift
// Bazodiac iOS — Textgenerierung für Day Pulse / Day Trace
//
// KEIN Astro-Vokabular. Kein "weil". Kein Erklären.
// Pulse: poetischer Realismus, atmosphärisch, sensorisch, 2–3 Sätze
// Trace: direkt, geladen, handlungsorientiert, benennt Natal-Archetyp-Qualitäten
//
// Die Sprache ist alltagsnah, nicht esoterisch.

import Foundation

enum DayModeTextGenerator {

    static func generate(
        mode: DayMode,
        intensity: Double,
        profile: CosmicProfile,
        weather: CosmicWeather,
        language: CosmicStore.Language
    ) -> String {
        let sun = profile.westernData.sunSign
        let moon = profile.westernData.moonSign
        let dominant = profile.wuxingData.dominant
        let dayMaster = profile.baziData.day.stem

        let isDE = language == .german
        let hasStorm = weather.kpIndex >= 5

        if mode == .pulse {
            return isDE
                ? pulseDE(sun: sun, dominant: dominant, weather: weather, intensity: intensity)
                : pulseEN(sun: sun, dominant: dominant, weather: weather, intensity: intensity)
        } else {
            var text = isDE
                ? traceDE(sun: sun, moon: moon, dayMaster: dayMaster, intensity: intensity)
                : traceEN(sun: sun, moon: moon, dayMaster: dayMaster, intensity: intensity)

            // Magnetsturm-Extrasatz bei Intensity > 0.7 + Kp ≥ 5
            if hasStorm && intensity > 0.7 {
                text += isDE
                    ? " Die Erde summt heute lauter als sonst."
                    : " The Earth hums louder than usual today."
            }

            return text
        }
    }

    // MARK: - PULSE (Deutsch) — poetischer Realismus

    private static func pulseDE(sun: ZodiacSign, dominant: CosmicElement, weather: CosmicWeather, intensity: Double) -> String {
        // Element-basierte Atmosphäre + Mondphase-Stimmung
        let elementText: String
        switch dominant {
        case .water:
            elementText = intensity < 0.3
                ? "Wasser fließt heute ohne Widerstand. Du auch."
                : "Etwas Tiefes bewegt sich unter der Oberfläche. Lass es."
        case .fire:
            elementText = intensity < 0.3
                ? "Wärme liegt in der Luft, nicht die laute Art. Die stille."
                : "Das Feuer brennt gleichmäßig. Ein guter Tag, um etwas zu kochen — im wörtlichen Sinne."
        case .wood:
            elementText = intensity < 0.3
                ? "Etwas wächst. Du merkst es vielleicht erst morgen."
                : "Der Boden unter dir ist fest heute. Steh auf ihm."
        case .earth:
            elementText = intensity < 0.3
                ? "Erde trägt heute. Rhythmus ist da — du kannst dich anlehnen."
                : "Heute ist ein Tag für Hände in der Erde. Buchstäblich oder nicht."
        case .metal:
            elementText = intensity < 0.3
                ? "Klarheit liegt in der Luft wie Reif am Morgen."
                : "Die Dinge sind heute schärfer als sonst. Nutze das."
        }

        // Mond-Stimmung
        let moonText: String
        switch weather.moonPhase {
        case .newMoon:
            moonText = "Stille Nacht, offenes Blatt."
        case .fullMoon:
            moonText = "Alles ist beleuchtet. Auch das, was du lieber im Dunkeln lässt."
        case .waxingCrescent, .firstQuarter, .waxingGibbous:
            moonText = "Der Mond nimmt zu. Deine Pläne auch."
        case .waningCrescent, .lastQuarter, .waningGibbous:
            moonText = "Weniger ist heute die richtige Richtung."
        }

        return "\(elementText) \(moonText)"
    }

    // MARK: - PULSE (English)

    private static func pulseEN(sun: ZodiacSign, dominant: CosmicElement, weather: CosmicWeather, intensity: Double) -> String {
        let elementText: String
        switch dominant {
        case .water:
            elementText = intensity < 0.3
                ? "Water flows without resistance today. So do you."
                : "Something deep is moving beneath the surface. Let it."
        case .fire:
            elementText = intensity < 0.3
                ? "Warmth in the air, not the loud kind. The quiet kind."
                : "The fire burns steady. A good day to cook something — literally."
        case .wood:
            elementText = intensity < 0.3
                ? "Something is growing. You might notice it tomorrow."
                : "The ground beneath you is solid today. Stand on it."
        case .earth:
            elementText = intensity < 0.3
                ? "Earth carries today. The rhythm is there — you can lean in."
                : "Today is a day for hands in the soil. Literally or not."
        case .metal:
            elementText = intensity < 0.3
                ? "Clarity in the air like morning frost."
                : "Things are sharper than usual today. Use it."
        }

        let moonText: String
        switch weather.moonPhase {
        case .newMoon:        moonText = "Quiet night, open page."
        case .fullMoon:       moonText = "Everything is lit. Even what you'd rather keep in the dark."
        case .waxingCrescent, .firstQuarter, .waxingGibbous:
            moonText = "The moon is growing. So are your plans."
        case .waningCrescent, .lastQuarter, .waningGibbous:
            moonText = "Less is the right direction today."
        }

        return "\(elementText) \(moonText)"
    }

    // MARK: - TRACE (Deutsch) — direkt, geladen, Archetyp-Qualitäten

    private static func traceDE(sun: ZodiacSign, moon: ZodiacSign, dayMaster: HeavenlyStem, intensity: Double) -> String {
        // Benennt Qualitäten aus dem Natal-Archetyp des Users
        let sunQuality = archetypeQualityDE(sun)
        let moonQuality = moonTraitDE(moon)

        if intensity > 0.6 {
            return "\(sunQuality) Du schaust heute genauer hin als andere. \(moonQuality)"
        } else {
            return "\(sunQuality) \(moonQuality)"
        }
    }

    private static func archetypeQualityDE(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries:       return "Dein Impuls kommt heute schneller als dein Kopf. Lass ihn."
        case .taurus:      return "Dein Gespür für das Richtige ist heute besonders wach."
        case .gemini:      return "Dein Radar für Zwischentöne läuft auf Hochtouren."
        case .cancer:      return "Dein Schutzinstinkt greift heute. Frag dich: für wen genau?"
        case .leo:         return "Dein Auftritt zählt heute. Nicht laut — aber präsent."
        case .virgo:       return "Dein Blick für Details wird heute gebraucht. Schau genau hin."
        case .libra:       return "Dein Gleichgewichtssinn spürt heute eine Schieflage. Korrigiere sie."
        case .scorpio:     return "Dein detektivischer Instinkt bekommt heute was zu tun."
        case .sagittarius: return "Dein Temperament könnte heute positiv eingesetzt werden."
        case .capricorn:   return "Dein Langzeitdenken trifft heute auf eine kurzfristige Gelegenheit."
        case .aquarius:    return "Dein Anderssein ist heute die richtige Antwort."
        case .pisces:      return "Du spürst heute etwas, das andere noch nicht sehen."
        }
    }

    private static func moonTraitDE(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries:       return "Die Ungeduld will genutzt werden — nicht bekämpft."
        case .taurus:      return "Bleib bei dem, was sich richtig anfühlt. Heute stimmt es."
        case .gemini:      return "Ein Gespräch heute wird wichtiger als du denkst."
        case .cancer:      return "Jemand braucht dich heute. Du weißt schon, wer."
        case .leo:         return "Zeig, was du kannst. Heute sieht man es."
        case .virgo:       return "Die kleinen Dinge machen heute den Unterschied."
        case .libra:       return "Eine Entscheidung steht an. Beide Seiten haben Recht."
        case .scorpio:     return "Vertrau dem, was du unter der Oberfläche siehst."
        case .sagittarius: return "Der Horizont ist heute näher als er aussieht."
        case .capricorn:   return "Struktur gibt dir heute Freiheit, nicht Enge."
        case .aquarius:    return "Dein unorthodoxer Gedanke ist heute der beste."
        case .pisces:      return "Das Gefühl, das du nicht benennen kannst, ist die Antwort."
        }
    }

    // MARK: - TRACE (English)

    private static func traceEN(sun: ZodiacSign, moon: ZodiacSign, dayMaster: HeavenlyStem, intensity: Double) -> String {
        let sunQ = archetypeQualityEN(sun)
        let moonQ = moonTraitEN(moon)
        if intensity > 0.6 {
            return "\(sunQ) You'll see more clearly than most today. \(moonQ)"
        } else {
            return "\(sunQ) \(moonQ)"
        }
    }

    private static func archetypeQualityEN(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries:       return "Your impulse arrives before your mind today. Let it."
        case .taurus:      return "Your sense for what's right is especially awake today."
        case .gemini:      return "Your radar for subtleties is running at full speed."
        case .cancer:      return "Your protective instinct kicks in today. Ask: for whom exactly?"
        case .leo:         return "Your presence matters today. Not loud — but felt."
        case .virgo:       return "Your eye for detail is needed today. Look closely."
        case .libra:       return "Your sense of balance detects something off today. Correct it."
        case .scorpio:     return "Your detective instinct has work to do today."
        case .sagittarius: return "Your temperament could be channeled positively today."
        case .capricorn:   return "Your long-term thinking meets a short-term opportunity today."
        case .aquarius:    return "Your uniqueness is the right answer today."
        case .pisces:      return "You sense something today that others can't see yet."
        }
    }

    private static func moonTraitEN(_ sign: ZodiacSign) -> String {
        switch sign {
        case .aries:       return "The impatience wants to be used — not fought."
        case .taurus:      return "Stay with what feels right. Today it is."
        case .gemini:      return "A conversation today will matter more than you think."
        case .cancer:      return "Someone needs you today. You already know who."
        case .leo:         return "Show what you've got. Today they'll see it."
        case .virgo:       return "The small things make the difference today."
        case .libra:       return "A decision is waiting. Both sides have merit."
        case .scorpio:     return "Trust what you see beneath the surface."
        case .sagittarius: return "The horizon is closer than it looks today."
        case .capricorn:   return "Structure gives you freedom today, not confinement."
        case .aquarius:    return "Your unorthodox thought is the best one today."
        case .pisces:      return "The feeling you can't name is the answer."
        }
    }
}
