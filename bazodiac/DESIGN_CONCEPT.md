# Bazodiac iOS — Design Concept
*Native iOS reimagining of the Bazodiac web app*

---

## Overview

The Bazodiac iOS app translates the web experience (dark-luxury astrology platform) into a first-class native iOS product. Every design decision is intentional — the obsidian/gold palette, the Chinese character typography, the orbital animations — all port directly from the web aesthetic while leveraging iOS-native capabilities.

---

## Design System

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `obsidian` | `#00050A` | Primary background (deep space black) |
| `cosmicGold` | `#D4AF37` | Primary accent — all text, icons, borders |
| `goldDeep` | `#8B6914` | Muted gold for secondary elements |
| `cosmicAsh` | `#1A1C1E` | Card backgrounds |
| `cosmicInk` | `#1E2A3A` | Secondary dark surfaces |
| `elementWood` | `#52A853` | 木 Wood element |
| `elementFire` | `#EA4335` | 火 Fire element |
| `elementEarth` | `#FBBC05` | 土 Earth element |
| `elementMetal` | `#C8D4E4` | 金 Metal element |
| `elementWater` | `#4285F4` | 水 Water element |

### Typography

The web uses **Sora** (sans) + **Cormorant Garamond** (serif). iOS native equivalents:

| Role | Font | Usage |
|------|------|-------|
| Display | SF Pro (ultraLight serif design) | Titles, headings |
| Heading | SF Pro (light) | Section labels, names |
| Body | SF Pro (light serif design) | Interpretation text, descriptions |
| Label | SF Pro (medium, 9pt, tracked 5+) | Uppercase caps labels |
| Mono | SF Mono (light) | Degrees, coordinates, dates |
| Chinese | System CJK (ultraLight) | 天干 地支 五行 glyphs |

### Glass Effects

- **iOS 26+**: Native `.glassEffect(.regular)` via Liquid Glass API
- **iOS 17–25**: `.ultraThinMaterial` with gold `strokeBorder` overlay
- All glass elements wrapped in `GlassEffectContainer` on iOS 26+

---

## App Architecture

### Navigation Flow

```
BazodiacApp
└── RootView (phase-driven, no NavigationStack needed)
    ├── SplashView          (.splash phase)
    ├── BirthFormView       (.birthForm phase — first launch)
    └── MainTabView         (.dashboard phase)
        ├── HomeView        (Tab: Kosmos)
        ├── WesternChartView (Tab: Chart)
        ├── BaZiView        (Tab: BaZi)
        ├── WuXingView      (Tab: Wu-Xing)
        └── LeviView        (Tab: Levi)
```

### State Management

- Single `@Observable @MainActor class CosmicStore` injected as `.environment()`
- No `ObservableObject` — modern iOS 17 `Observation` framework
- `AppPhase` enum drives root navigation transitions
- `@Bindable var store = store` in children needing two-way bindings

---

## Screen Designs

### 1. SplashView — Cinematic Intro

**Phase sequence**: `blank → starfield → title → subtitle → gate`

- **Starfield**: `Canvas` + `TimelineView(.animation)` — 140 gold-tinted stars twinkle with random phase/speed offsets. Zero UIKit.
- **Ephemeris scroll**: Unrolls from a collapsed capsule (like the web's scroll animation) revealing a mini zodiac wheel drawn with Canvas.
- **"Bazodiac" title**: SF Serif display font, gold gradient, spring entrance animation
- **Language gate**: Two minimal border-buttons (Deutsch / English) with gold hover glow. Triggers `store.enterApp(language:)`.

```
┌─────────────────────────────────┐
│ ✦ ✦  ✦    ✦   ✦  ✦  ✦          │  ← Starfield
│                                 │
│      Fusion Firmaments          │  ← Gold tracking label
│    ┌───────────────────┐        │
│    │ ▄▄  zodiac wheel  │        │  ← Scroll unroll
│    └───────────────────┘        │
│                                 │
│           Bazodiac              │  ← Display title
│      Coniunctio Caelorum        │  ← Italic serif
│                                 │
│   [ Deutsch ]  [ English ]      │  ← Language gate
│     Wähle deine Erfahrung       │
└─────────────────────────────────┘
```

### 2. BirthFormView — Cosmic Blueprint Entry

- Dark obsidian card with staggered field reveal (name → date → time → place)
- Each field in a `FormRow` with a gold SF Symbol icon + tracking label + input
- `DatePicker` styled with `.tint(.cosmicGold)` + color invert trick
- Pulsing "Calculate" button with animated border aura
- Disabled state while `isLoading`, shows `ProgressView` with gold tint

### 3. HomeView — Cosmic Blueprint Dashboard

```
┌─────────────────────────────────┐
│  ○──●──○──●  (orbital rings)    │  ← OrbitalRingsView canvas animation
│                                 │
│     ✦ Dein Kosmischer Atlas     │
│           Layla                 │  ← store.displayName
│      München, Deutschland       │
│                                 │
│  ☉ Sonne  ☽ Mond  ↑ Aszendent  │  ← BigThreeBadges
│  Steinbock Skorpion Zwillinge   │
│                                 │
│  ┌──────────────────────────┐   │
│  │ ✦ Tages-Interpretation   │   │  ← DailyInsightCard
│  │ Deine kosmische Signatur │   │
│  │ vereint die Erdbeständig-│   │
│  │ keit … [Mehr lesen]      │   │
│  └──────────────────────────┘   │
│                                 │
│  ┌──────────┐ ┌──────────────┐  │
│  │ ⊙ Chart  │ │ ⋮ BaZi Säul.│  │  ← 2×2 section grid
│  └──────────┘ └──────────────┘  │
│  ┌──────────┐ ┌──────────────┐  │
│  │ ⬠ Wu-Xing│ │ ∿ Levi       │  │
│  └──────────┘ └──────────────┘  │
│                                 │
│  ∿∿∿∿  Levi Bazi · Sprechen ▸  │  ← LeviTeaser
│                                 │
│  " Dein Chart ist kein Urteil " │  ← DailyQuoteCard
└─────────────────────────────────┘
```

### 4. WesternChartView — Birth Chart

Full zodiac wheel rendered with `Canvas`:
- **12 zodiac sectors**: Colored by element (fire/earth/air/water), with Unicode glyphs (♈–♓)
- **House divisions**: 12 house cusp lines, axis lines (1/7, 4/10) thicker
- **Planet positions**: Gold dots at ecliptic degree, glyph labels above
- **Planet list**: Scrollable rows with `sheet(item:)` for detail

The wheel rotates so the Ascendant sits at the 9 o'clock position (traditional chart orientation).

### 5. BaZiView — Four Pillars of Destiny

```
┌─────────────────────────────────┐
│ 日主  Day Master                │
│  壬   Yang Wasser               │  ← DayMasterCard — highlighted
│       (Element badge)           │
│                                 │
│  年柱  月柱  日柱  時柱          │  ← Four pillar columns
│  ┌──┐  ┌──┐  ┌──┐  ┌──┐        │
│  │己│  │癸│  │壬│  │癸│  Stems  │
│  │  │  │  │  │  │  │  │        │
│  │巳│  │丑│  │寅│  │未│  Branch│
│  │🐍│  │🐂│  │🐅│  │🐐│        │
│  └──┘  └──┘  └──┘  └──┘        │
│                                 │
│  Elementen-Verteilung (bars)    │
│  木 Holz  ████░░░░  45%         │
│  火 Feuer ██░░░░░░  20%         │
│  ...                            │
└─────────────────────────────────┘
```

Each pillar card has a colored bottom stripe for the element. The day pillar gets a gold border glow (it's the "Day Master"). Tapping any pillar opens a `sheet(item:)` detail view.

### 6. WuXingView — Five Elements Pentagon

`Canvas`-drawn pentagon:
- **5 grid pentagons** at 20% increments (radar chart grid)
- **Axis lines** from center to each vertex
- **Data polygon**: Filled with gold opacity, bordered, showing element balance
- **Element dots**: Colored circles at each vertex
- **Generating cycle arrows (相生)**: Animated arrows flowing Wood→Fire→Earth→Metal→Water
- **Element labels**: Overlay positioned at outer vertices

Below the pentagon: animated balance bars that spring-animate on appear.

### 7. LeviView — AI Voice Companion

```
┌─────────────────────────────────┐
│  ∿ Levi Bazi     [Start ▸]      │  ← Header + session toggle
│                                 │
│     ○ (orbital rings idle)      │  ← Avatar section
│   or                            │  
│   ▁▃▅▇▅▃▁ (waveform speaking)  │  ← Canvas waveform when active
│                                 │
│  Levi: Willkommen. Ich bin ...  │  ← Message bubbles
│        [dark levi bubble]       │
│                   User: Was...  │
│              [gold user bubble] │
│  Levi: Dein Day Master ist 壬 … │
│                                 │
│  ┌───────────────────┐ 🎤 ➤    │  ← Control bar (glass on iOS 26+)
│  │ Stelle Levi eine F│         │
│  └───────────────────┘         │
└─────────────────────────────────┘
```

The waveform (`TimelineView` + `Canvas`) animates differently for speaking vs. listening states. The control bar uses Liquid Glass on iOS 26+.

---

## Custom Tab Bar

```
┌────────────────────────────────────────┐
│  🌙      ⊙      ⋮      ⬠      ∿∿     │
│ Kosmos  Chart  BaZi  Wu-Xing  Levi    │
└────────────────────────────────────────┘
```

- Active tab: gold icon + gold caption + subtle circular glow
- Inactive tabs: 35% opacity gold
- Background: Liquid Glass on iOS 26+, obsidian + gold top gradient on iOS 17-25
- `symbolEffect(.bounce)` on tap
- `UISelectionFeedbackGenerator` on tab change

---

## Animation Philosophy

| Animation | Technique | Duration |
|-----------|-----------|----------|
| Starfield twinkle | `Canvas` + `TimelineView(.animation)` | Continuous |
| Orbital rings | `Canvas` + `TimelineView` | Continuous |
| Splash reveal | `withAnimation(.spring)` + `Task.sleep` sequence | ~5s total |
| Screen transitions | `.push(from:)` + `.opacity` | 0.6s |
| Card entrance | `.spring(duration: 0.9).delay(n * 0.15)` stagger | Per screen |
| Bar chart fill | `.spring(duration: 1.1)` on appear | 1.1s |
| Pentagon data | `.scaleEffect` + `.opacity` | 1.0s |
| Tab switch | `.spring(duration: 0.35, bounce: 0.2)` | 0.35s |
| Button press | `scaleEffect(0.96)` via `DragGesture` | Immediate |

---

## iOS-Specific Features

### Haptics
- `UIImpactFeedbackGenerator(.medium)` — CTA buttons, session start
- `UIImpactFeedbackGenerator(.light)` — Card taps, pillar selection
- `UISelectionFeedbackGenerator` — Tab switches, planet selection

### Sheets
- All detail views use `.sheet(item:)` — model-based, sheet owns dismiss
- `presentationDetents([.fraction(0.42)])` for compact planet/pillar sheets
- `presentationBackground(Color.cosmicAsh)` for dark sheet chrome

### Live Activities (Future)
- Daily transit update as Lock Screen widget
- "Today's Cosmic Weather" with sun/moon positions

### Widgets (Future)
- Small: Today's sign + element balance indicator
- Medium: Big Three (Sun/Moon/ASC) + daily quote
- Large: Full BaZi pillar grid

---

## File Structure

```
bazodiac/
├── bazodiacApp.swift     — App entry, RootView phase navigation
├── DesignSystem.swift    — Colors, typography, ViewModifiers, StarfieldView, OrbitalRingsView
├── CosmicModels.swift    — All domain models (BirthData, WesternData, BaZiData, WuXingData, CosmicProfile)
├── CosmicStore.swift     — @Observable @MainActor global state
├── SplashView.swift      — Cinematic intro with Canvas starfield + ephemeris scroll
├── BirthFormView.swift   — Data entry with staggered reveal
├── MainTabView.swift     — Custom tab bar navigation
├── HomeView.swift        — Dashboard with orbital animation
├── WesternChartView.swift — Canvas zodiac wheel + planet list
├── BaZiView.swift        — Four pillars stele cards + element bars
├── WuXingView.swift      — Pentagon Canvas + balance bars + cycles
└── LeviView.swift        — Voice companion with Canvas waveform
```

---

## SwiftUI Best Practices Applied

- ✅ `@Observable` (not `ObservableObject`) for CosmicStore
- ✅ `@MainActor` on observable class
- ✅ `@State private` for all internal state
- ✅ `@Bindable` for injected `@Observable` needing bindings
- ✅ `Canvas` + `TimelineView` for all continuous animations
- ✅ `.sheet(item:)` for all sheets — sheet owns dismiss
- ✅ `NavigationStack` not `NavigationView` (not needed for this phase-based flow)
- ✅ `foregroundStyle()` not `foregroundColor()`
- ✅ `clipShape(.rect(cornerRadius:))` not `.cornerRadius()`
- ✅ `#available(iOS 26, *)` with fallback for all Liquid Glass
- ✅ No `UIScreen.main.bounds`
- ✅ No `GeometryReader` except where essential
- ✅ Stable `ForEach` identity (all models have `let id = UUID()`)
- ✅ `.task` for async work
- ✅ Button not `onTapGesture` for all interactive elements
- ✅ `symbolEffect` for SF Symbol animations

---

## Next Steps for Production

1. **API Integration**: Replace `CosmicStore.submitBirthData()` mock with real BAFE API calls + Gemini interpretation
2. **Auth**: Add Supabase authentication (sign-in/sign-up sheet triggered from BirthFormView)
3. **Voice**: Integrate ElevenLabs iOS SDK in LeviView for real voice interaction
4. **3D Orrery**: Port Three.js orrery to RealityKit or SceneKit for a native 3D solar system view
5. **Widgets**: Implement WidgetKit extension for home screen cosmic weather
6. **Live Activities**: Daily transit updates on Lock Screen
7. **Payments**: Stripe integration for premium tier via StoreKit 2
8. **Persistence**: CloudKit or Supabase sync for cross-device profile

---

*Design by Bazodiac · iOS Concept 2026*
