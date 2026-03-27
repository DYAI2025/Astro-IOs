# Bazodiac iOS — Platzhalter-Dokumentation & Implementierungsplan

> Stand: 2026-03-27  
> Zweck: Vollständige Erfassung aller Mocks, Stubs und hardcodierten Inhalte  
> im iOS-Client. Priorisiert nach Blockier-Wirkung auf echten Nutzerbetrieb.

---

## Systemübersicht

```
iPhone App (Swift/SwiftUI)
       │
       ├── BirthFormView  ──── [PH-1] submitBirthData() stub
       │                        [PH-2] kein Geocoding (lat/lon bleibt 0)
       │
       ├── CosmicStore    ──── [PH-3] CosmicProfile.mock statt BAFE-Antwort
       │                        [PH-4] keine Persistenz (kein Keychain/UserDefaults)
       │                        [PH-5] keine Supabase-Authentifizierung
       │
       ├── HomeView       ──── [PH-6] statische Tages-Interpretation
       │                        [PH-7] statisches Tages-Zitat
       │
       ├── WesternChartView─── [PH-8] hardcodierte Planeten-Positionen (Mock)
       │
       ├── BaZiView       ──── [PH-9] hardcodierte Vier-Säulen-Daten (Mock)
       │
       ├── WuXingView     ──── [PH-10] hardcodierte Element-Balancen (Mock)
       │
       ├── LeviView       ──── [PH-11] simulierte KI-Antworten (kein ElevenLabs)
       │                        [PH-12] Mikrofon-Button ohne echte Aufnahme
       │                        [PH-13] Sample-Conversation vorgeladen
       │
       ├── QuizzesView    ──── [PH-14] keine Quizfragen (nur Cluster-Hüllen)
       │                        [PH-15] kein Fortschritt-Tracking
       │
       └── bazodiacApp    ──── [PH-16] Light-Mode-Toggle ohne Wirkung
```

---

## Detaillierte Platzhalter

---

### PH-1 · CosmicStore.submitBirthData() — Fake API-Aufruf  
**Datei:** `CosmicStore.swift` · Zeile ~96  
**Priorität:** 🔴 KRITISCH — ohne Fix arbeitet die App nie mit echten Daten

```swift
// AKTUELL (Stub):
func submitBirthData() async {
    try? await Task.sleep(for: .seconds(2.5))   // ← gefälschtes Warten
    profile = CosmicProfile.mock                 // ← immer gleiche Daten
}
```

**Was fehlt:**
- Echten BAFE-API-Call (`POST /api/calculate/bazi`, `western`, `wuxing`, `fusion`, `tst`)
- Mapping BAFE-Response → iOS `CosmicProfile`
- Fehlerbehandlung mit `store.error`

**Vorhandene Web-Referenz:** `src/services/api.ts` → `calculateAll(data)`  
**BAFE Basis-URL:** `https://bafe.vercel.app` (via Proxy: `/api/calculate/…`)

**Ziel-Implementierung:**
```swift
func submitBirthData() async {
    guard !birthData.name.isEmpty,
          birthData.latitude != 0 else { return }
    isLoading = true; error = nil
    do {
        let result = try await BAFEService.shared.calculateAll(birthData: birthData)
        let interpretation = try await GeminiService.shared.interpret(result, lang: language)
        profile = CosmicProfileMapper.map(result, interpretation: interpretation, birthData: birthData)
        await SupabaseService.shared.saveProfile(profile!)
        withAnimation(.spring(duration: 0.7)) { appPhase = .dashboard }
    } catch {
        self.error = error.localizedDescription
    }
    isLoading = false
}
```

---

### PH-2 · BirthFormView — Kein Geocoding (lat/lon = 0)  
**Datei:** `BirthFormView.swift` · `BirthPlaceField`  
**Priorität:** 🔴 KRITISCH — BAFE API benötigt lat/lon für alle Berechnungen

```swift
// AKTUELL: Einfaches TextField, lat/lon bleiben 0
TextField("Stadt, Land", text: $store.birthData.birthPlace)
```

**Was fehlt:**
- Ortssuche mit Autocomplete (Google Places API oder Apple MapKit `MKLocalSearch`)
- Extraktion von `latitude`, `longitude`, `timezone` aus gewähltem Ort
- `BirthData` in `CosmicStore` muss `latitude`, `longitude`, `timezone` befüllen

**Ziel-Implementierung:** `MapKit MKLocalSearch` (kein API-Key nötig)  
oder Google Places (Schlüssel bereits in `.env.example`: `VITE_GOOGLE_PLACES_API_KEY`)

```swift
// Neues PlaceSearchField mit MKLocalSearchCompleter
struct PlaceSearchField: View {
    @StateObject private var completer = PlaceCompleter()
    // → bei Auswahl: store.birthData.latitude = result.placemark.coordinate.latitude
    //                store.birthData.longitude = result.placemark.coordinate.longitude
    //                store.birthData.timezone = TimeZone-Lookup via CLGeocoder
}
```

---

### PH-3 · CosmicProfile.mock — Statische Testdaten überall  
**Datei:** `CosmicModels.swift` · ab Zeile ~434  
**Priorität:** 🔴 KRITISCH

Die `.mock`-Instanz ist in **8 Stellen** hartcodiert eingesetzt (Previews OK, aber auch in Produktions-Pfaden):

| Stelle | Datei | Kritisch? |
|--------|-------|-----------|
| `submitBirthData()` | CosmicStore.swift:100 | ✅ Prod-Pfad |
| `recalculate()` | CosmicStore.swift:112 | ✅ Prod-Pfad |
| `bazodiacApp --skip-to-dashboard` | bazodiacApp.swift:28 | 🟡 Debug-only |
| Preview "Dashboard" | bazodiacApp.swift:89 | 🟢 Preview |
| Preview HomeView | HomeView.swift:425 | 🟢 Preview |
| Preview WesternChartView | WesternChartView.swift:505 | 🟢 Preview |
| Preview BaZiView | BaZiView.swift:414 | 🟢 Preview |
| Preview LeviView | LeviView.swift:481 | 🟢 Preview |

**Mockwerte die ersetzt werden müssen:**
```
Name:          "Layla"               → aus BirthData.name
Geburtsort:    "München, Deutschland" → aus BirthData.birthPlace
Sonne:         Steinbock 24.7°       → BAFE /western Body.Sun
Mond:          Skorpion 11.3°        → BAFE /western Body.Moon
Aszendent:     Zwillinge 7.9°        → BAFE /western Angles.Ascendant
Planeten:      10 feste Positionen   → BAFE /western Bodies.*
Häuser:        12 feste Positionen   → BAFE /western Houses.*
BaZi-Säulen:   己巳 / 癸丑 / 壬寅 / 癸未  → BAFE /bazi Pillars.*
WuXing-Werte:  Holz 0.45 …          → BAFE /wuxing wu_xing_vector
Interpretation: 3 Sätze Fließtext    → Gemini /api/interpret
Tages-Zitat:   1 Satz                → Gemini täglich rotierend
```

---

### PH-4 · Keine Persistenz  
**Datei:** `CosmicStore.swift`  
**Priorität:** 🔴 KRITISCH — App vergisst alles nach Neustart

**Was fehlt:**  
- `CosmicProfile` in `UserDefaults` oder `Keychain` speichern (lokales Offline-Caching)  
- `BirthData` persistent halten  
- Nach App-Neustart Profil aus Cache laden, kein erneutes Berechnen

**Ziel:**
```swift
// Im CosmicStore init:
init() {
    if let cached = PersistenceService.loadProfile() {
        self.profile = cached
        self.birthData = cached.birthData
        self.appPhase = .dashboard
    }
}
// Nach jedem erfolgreichen submitBirthData():
PersistenceService.save(profile)
```

---

### PH-5 · Keine Supabase-Authentifizierung  
**Datei:** `CosmicStore.swift`, `bazodiacApp.swift`  
**Priorität:** 🟠 HOCH — Für Multi-Device-Sync, ElevenLabs-Profil-Tool

**Was fehlt:**  
- Supabase Swift SDK (`supabase-swift`)  
- E-Mail/Magic-Link oder Apple-Sign-In Auth  
- `user_id` an BAFE-Calls anhängen (für `astro_profiles` Tabelle)  
- Profil aus Supabase laden wenn User bereits Account hat

**Datenbank-Schema bereits vorhanden:** `supabase-schema.sql`  
- Tabellen: `profiles`, `birth_data`, `astro_profiles`

---

### PH-6 & PH-7 · HomeView — Statische Tages-Inhalte  
**Datei:** `HomeView.swift` · `DailyInsightCard`, `DailyQuoteCard`  
**Priorität:** 🟠 HOCH — Kernerlebnis

```swift
// AKTUELL: Immer gleicher Text aus statischem Mock
Text(store.profile?.interpretation ?? "")  // ← einmalig berechnet, nie erneuert
Text(store.profile?.dailyQuote ?? "")      // ← statisch aus CosmicProfile.mock
```

**Was fehlt:**
- `dailyQuote`: täglich rotierendes Zitat — generiert von Gemini mit aktuellem Datum + Nutzer-Chart
- `interpretation`: Täglich aktualisierte "Tages-Energie" basierend auf aktuellen Transite
- Lokales Caching (kein Gemini-Call wenn Quote des Tages schon vorhanden)

**Ziel:**
```swift
// In CosmicStore:
func refreshDailyContent() async {
    guard let profile else { return }
    let today = Calendar.current.startOfDay(for: Date())
    if dailyRefreshDate == today { return }   // bereits heute geladen
    let quote = try? await GeminiService.shared.dailyQuote(profile: profile, lang: language)
    dailyQuote = quote ?? profile.dailyQuote
    dailyRefreshDate = today
}
```

---

### PH-8 · WesternChartView — Hardcodierte Planeten  
**Datei:** `CosmicModels.swift` · `WesternData.mock`  
**Priorität:** 🟠 HOCH

10 Planeten mit festen Ekliptik-Graden + 12 feste Haus-Cuspen müssen durch echte BAFE-Daten ersetzt werden.

**BAFE-Response-Struktur (aus `src/types/bafe.ts`):**
```typescript
bodies?: Record<string, { zodiac_sign?: number; longitude?: number }>
angles?: { Ascendant?: number; MC?: number }
houses?: Record<string, number>    // "1"–"12" → cusp degrees
```

**iOS-Mapper nötig:** `BAFEResponseMapper.mapWestern(raw:) → WesternData`

---

### PH-9 · BaZiView — Hardcodierte Vier Säulen  
**Datei:** `CosmicModels.swift` · `BaZiData.mock`  
**Priorität:** 🟠 HOCH

Fixe Säulen für 1990-01-15 14:30 München. Müssen aus BAFE `/bazi` kommen.

**BAFE-Response (aus `src/services/api.ts`):**
```typescript
pillars: { year, month, day, hour }
// Jede Säule: { stamm/stem, zweig/branch, tier/animal, element }
```

**iOS-Mapper nötig:** `BAFEResponseMapper.mapBaZi(raw:) → BaZiData`  
Inklusive Mapping: deutscher BAFE-Tier-Name → `EarthlyBranch.animal` (Englisch)

---

### PH-10 · WuXingView — Hardcodierte Element-Balancen  
**Datei:** `CosmicModels.swift` · `WuXingData.mock`  
**Priorität:** 🟠 HOCH

```swift
balance: [.wood: 0.45, .fire: 0.20, .earth: 0.60, .metal: 0.15, .water: 0.80]
```

**BAFE-Response:** `wu_xing_vector: { Holz: N, Feuer: N, Erde: N, Metall: N, Wasser: N }`  
Normalisierung: rohe Counts → 0.0–1.0 (dividiere durch Maximum)

---

### PH-11 · LeviView — Simulierte KI-Antworten  
**Datei:** `LeviView.swift` · `leviResponse(for:)` · Zeile ~194  
**Priorität:** 🟠 HOCH — Kernfeature

```swift
// AKTUELL: 5 hardcodierte Sätze, zufällig gewählt
private func leviResponse(for input: String) -> String {
    let responses = ["Dein Wasserelement...", "Die Spannung...", ...]
    return responses.randomElement() ?? responses[0]
}
```

**Ziel:** ElevenLabs Conversational AI REST API  
**Agent-ID:** bereits in `.env.example`: `VITE_ELEVENLABS_AGENT_ID`

**Implementierung (zwei Stufen):**

**Stufe A — Text-Chat via REST (schnell):**
```swift
struct ElevenLabsService {
    // POST https://api.elevenlabs.io/v1/convai/conversation
    func sendMessage(_ text: String, profile: CosmicProfile) async throws -> String
}
```

**Stufe B — Echte Voice (Ziel):**
- `AVAudioRecorder` für Aufnahme
- ElevenLabs STT → Text → Convai → TTS → `AVAudioPlayer`
- Alternativ: ElevenLabs SDK (wenn iOS-SDK verfügbar)

---

### PH-12 · LeviView — Mikrofon-Button ohne Funktion  
**Datei:** `LeviView.swift` · `LeviControlBar`  
**Priorität:** 🟡 MITTEL

```swift
// AKTUELL: Toggle-State, keine echte Aufnahme
isListening.toggle()
```

**Was fehlt:**
- `AVFoundation` Import + `AVAudioRecorder`
- Mikrofon-Permission (`NSMicrophoneUsageDescription` in Info.plist)
- Aufnahme → `Data` → ElevenLabs STT → Text in `inputText`

---

### PH-13 · LeviView — Vorgeladene Sample-Conversation  
**Datei:** `LeviView.swift` · Zeile ~28 und ~465  
**Priorität:** 🟡 MITTEL

```swift
@State private var messages: [Message] = Message.sampleConversation  // ← immer vorgeladen
```

**Was fehlt:**
- Leer starten: `@State private var messages: [Message] = []`
- Echte Levi-Begrüßung beim ersten Session-Start via ElevenLabs
- Conversation-History in UserDefaults oder Supabase speichern

---

### PH-14 · QuizzesView — Cluster-Hüllen ohne Fragen  
**Datei:** `QuizModels.swift` · `QuizCluster.mockClusters`  
**Priorität:** 🟡 MITTEL

5 Cluster mit 18 Quizzes — aber kein einziger `Question`-Typ, keine Antwortoptionen.

**Was fehlt:**
```swift
// Neues Modell:
struct QuizQuestion: Identifiable {
    let id = UUID()
    let text: String
    let answers: [QuizAnswer]
    let correctIndex: Int?         // nil für "alle gültig" (Persönlichkeits-Quizzes)
    let cosmicTag: String          // z.B. "fire-dominant", "capricorn-sun"
}

struct QuizAnswer: Identifiable {
    let id = UUID()
    let text: String
    let weight: [String: Double]   // kosmische Gewichtung für Persönlichkeits-Score
}
```

**Quizfragen-Quellen:**
- Statisch im Code (schnell, kein Backend): Fragen für jeden Cluster hardcoden
- Oder Gemini-generiert: personalisiert basierend auf Nutzer-Chart

---

### PH-15 · QuizzesView — Kein Fortschritt-Tracking  
**Datei:** `QuizzesView.swift` / `QuizModels.swift`  
**Priorität:** 🟡 MITTEL

`QuizStatus` Enum existiert (`.locked`, `.available`, `.completed`), aber:
- Kein Mechanismus der Status ändert
- Kein Score gespeichert
- Kein `UserDefaults`/Supabase-Speicherung

**Was fehlt:** `QuizProgressService` — speichert `[quizId: QuizResult]` lokal

---

### PH-16 · bazodiacApp — Light-Mode-Toggle ohne Wirkung  
**Datei:** `bazodiacApp.swift` · Zeile ~23  
**Priorität:** 🟡 MITTEL

```swift
// AKTUELL: Ignoriert CosmicTheme-Toggle komplett
.preferredColorScheme(.dark)    // ← hardcoded
```

**Was fehlt:**
- `CosmicStore` um `var theme: CosmicTheme = .dark` erweitern
- `RootView` und alle Views mit `@Environment(\.cosmicTheme)` versorgen
- `.preferredColorScheme` dynamisch setzen: `theme.isDark ? .dark : .light`

---

## Abhängigkeitsgraph

```
PH-2 (Geocoding) ──────────────────────────┐
                                            ▼
PH-1 (submitBirthData) ──► PH-3 (Mock ersetzen)
                                   │
          ┌────────────────────────┤
          ▼                        ▼                ▼
    PH-8 (Western)         PH-9 (BaZi)     PH-10 (WuXing)
          │                        │
          └──────────────┬─────────┘
                         ▼
              PH-6/7 (Tages-Inhalte)     PH-11 (Levi KI)
                         │
                    PH-4 (Persistenz)
                         │
                    PH-5 (Supabase Auth)
```

---

## Implementierungsplan — 5 Phasen

---

### Phase 1 · Fundament (1–2 Tage)
> Ziel: Echte Berechnungen, kein Mock mehr in Prod-Pfaden

| Task | Datei(en) | Aufwand |
|------|-----------|---------|
| 1.1 `BAFEService.swift` — URLSession-Client für alle 5 Endpunkte | neu | M |
| 1.2 `BAFEResponseMapper.swift` — BAFE JSON → iOS Models | neu | M |
| 1.3 `CosmicStore.submitBirthData()` auf echten Call umstellen | CosmicStore.swift | S |
| 1.4 `PlaceSearchField` mit `MKLocalSearch` + Timezone | BirthFormView.swift | M |
| 1.5 `CosmicProfile.mock` aus Prod-Pfaden entfernen | CosmicStore.swift | S |

**Akzeptanzkriterien:**  
- User gibt München + Datum ein → echte Planeten-Positionen im Chart
- Fehlermeldung wenn API nicht erreichbar

---

### Phase 2 · Interpretation & Persistenz (1–2 Tage)
> Ziel: KI-Text + App überlebt Neustart

| Task | Datei(en) | Aufwand |
|------|-----------|---------|
| 2.1 `GeminiService.swift` — `/api/interpret` aufrufen | neu | M |
| 2.2 `PersistenceService.swift` — JSON in UserDefaults | neu | S |
| 2.3 `CosmicStore.init` lädt cached Profil | CosmicStore.swift | S |
| 2.4 `DailyContentService` — Zitat + Tages-Energie mit TTL 1 Tag | neu | M |
| 2.5 Interpretation-Fallback (Template) wie Web-App | neu | S |

---

### Phase 3 · Light Mode & Polish (0.5 Tage)
> Ziel: Theme-Toggle funktioniert vollständig

| Task | Datei(en) | Aufwand |
|------|-----------|---------|
| 3.1 `CosmicStore.theme: CosmicTheme` + Persistenz | CosmicStore.swift | S |
| 3.2 `ThemeToggleButton` in HomeView + SplashView | HomeView.swift | S |
| 3.3 `.preferredColorScheme` dynamisch | bazodiacApp.swift | S |
| 3.4 Alle Views: `.background(theme.background)` statt hartcodiert | alle Views | M |

---

### Phase 4 · Levi Voice AI (2–3 Tage)
> Ziel: Echter KI-Companion mit Kontext

| Task | Datei(en) | Aufwand |
|------|-----------|---------|
| 4.1 `ElevenLabsService.swift` — REST Text-Chat | neu | M |
| 4.2 Levi bekommt Nutzer-Chart als System-Kontext | LeviView.swift | S |
| 4.3 `leviResponse()` ersetzt durch echten API-Call | LeviView.swift | S |
| 4.4 Conversation leert sich beim Start, Begrüßung via API | LeviView.swift | S |
| 4.5 `AVFoundation` — echte Mikrofon-Aufnahme → Transkription | LeviView.swift | L |
| 4.6 Conversation in UserDefaults persistieren | neu | S |

---

### Phase 5 · Quiz-Content (2–3 Tage)
> Ziel: Spielbare Quizzes mit echtem Inhalt

| Task | Datei(en) | Aufwand |
|------|-----------|---------|
| 5.1 `QuizQuestion` + `QuizAnswer` Modelle | QuizModels.swift | S |
| 5.2 Fragen für alle 18 Quizzes schreiben (statisch, DE) | QuizModels.swift | L |
| 5.3 `QuizPlayView` — Frage-für-Frage UI | neu | M |
| 5.4 `QuizProgressService` — Fortschritt in UserDefaults | neu | S |
| 5.5 Quiz-Status nach Abschluss setzen | QuizzesView.swift | S |
| 5.6 Ergebnis-Screen mit kosmischer Auswertung | neu | M |

---

### Phase 6 · Supabase Auth (optional, 1–2 Tage)
> Ziel: Multi-Device + ElevenLabs Profil-Tool

| Task | Datei(en) | Aufwand |
|------|-----------|---------|
| 6.1 `supabase-swift` Package hinzufügen | Package.swift | S |
| 6.2 `AuthView` — E-Mail Magic Link oder Apple Sign-In | neu | M |
| 6.3 Profil nach Login aus `astro_profiles` laden | CosmicStore.swift | M |
| 6.4 Profil nach Berechnung in Supabase speichern | neu | S |
| 6.5 ElevenLabs Profil-Tool (`/api/profile/:userId`) | Server-side | M |

---

## Aufwandsschätzung gesamt

| Phase | Tage | Blockiert durch |
|-------|------|-----------------|
| Phase 1 — Fundament | 1–2 | BAFE API erreichbar, lat/lon |
| Phase 2 — Interpretation | 1–2 | Phase 1 |
| Phase 3 — Light Mode | 0.5 | — |
| Phase 4 — Levi Voice | 2–3 | ElevenLabs Agent-ID |
| Phase 5 — Quiz Content | 2–3 | — |
| Phase 6 — Supabase | 1–2 | Supabase Keys |
| **Gesamt MVP** | **~5–7 Tage** | |

---

## Neue Dateien die erstellt werden müssen

```
bazodiac/
├── Services/
│   ├── BAFEService.swift           # URLSession API-Client (5 Endpunkte)
│   ├── BAFEResponseMapper.swift    # JSON → CosmicProfile
│   ├── GeminiService.swift         # /api/interpret aufrufen
│   ├── PersistenceService.swift    # UserDefaults JSON-Codec
│   ├── DailyContentService.swift   # Tages-Zitat mit TTL
│   ├── ElevenLabsService.swift     # Levi Voice REST
│   └── PlaceSearchService.swift    # MKLocalSearch + CLGeocoder
├── Config/
│   └── AppConfig.swift             # API-URLs, Keys aus Bundle
└── Extensions/
    └── BirthData+BAFE.swift        # BirthData → BAFE-Payload Konverter
```

---

## Sofort-Quickwins (< 1 Stunde, kein Backend nötig)

1. **PH-16 Light Mode**: `CosmicStore.theme` + `.preferredColorScheme` dynamisch → 20 Min.
2. **PH-13 Levi leer starten**: `messages = []` statt `sampleConversation` → 2 Min.
3. **PH-15 Quiz-Status**: Dummy-Toggle beim Abschließen → 10 Min.
4. **PH-4 Name persistieren**: `UserDefaults.standard["playerName"] = birthData.name` → 5 Min.
