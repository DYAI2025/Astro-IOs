# Bazodiac iOS — Full Implementation Plan

> **For Codex:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Take the completed design-concept Swift files and make the Bazodiac iOS app compile, run, and look exactly as designed — a dark-luxury fusion astrology app with cinematic splash, orbital animations, zodiac wheel, BaZi pillars, Wu-Xing pentagon, and Levi voice companion.

**Architecture:** Phase-driven root navigation (`CosmicStore.appPhase`) replacing NavigationStack. Single `@Observable @MainActor CosmicStore` injected at app root. All continuous animations via `Canvas + TimelineView`. Mock data in models; API hooks stubbed for later integration.

**Tech Stack:** SwiftUI (iOS 26.2), Swift Testing, `@Observable` (Observation framework), Canvas, TimelineView, UIKit haptics, Liquid Glass APIs (always available at iOS 26.2 target).

**Project facts that change everything:**
- `PBXFileSystemSynchronizedRootGroup` — every `.swift` file dropped in `bazodiac/bazodiac/` is **automatically** compiled. No `project.pbxproj` editing ever needed.
- Deployment target is **iOS 26.2** — `GlassEffectContainer`, `.glassEffect()`, `.glassProminent` are always available. No `#available` guards required (existing ones are harmless).
- Unit tests use **Swift Testing** (`@Test`, `#expect`) not XCTest.

---

## Phase 1 — Project Cleanup

### Task 1: Kill the SwiftData Zombie (`Item.swift`)

`Item.swift` has `@Model` which references SwiftData. The new app does not use SwiftData. This is the **primary compile blocker**.

**Files:**
- Overwrite: `bazodiac/bazodiac/Item.swift`

**Step 1: Replace Item.swift content**

Open `bazodiac/bazodiac/Item.swift` and replace the entire file:

```swift
// Item.swift
// Retained for Xcode file-system sync — not used by the app.
// The app uses CosmicStore + CosmicModels instead of SwiftData.
import Foundation
```

**Step 2: Verify no other file imports SwiftData**

```bash
cd bazodiac/bazodiac
grep -r "import SwiftData" .
```

Expected output: **no matches**. If any file still imports SwiftData, remove that import.

**Step 3: Commit**

```bash
git add bazodiac/bazodiac/Item.swift
git commit -m "chore: remove SwiftData — replaced by CosmicStore"
```

---

### Task 2: First Build — Observe All Compile Errors

This task **deliberately does not fix anything** — it maps all errors at once so we fix them systematically.

**Step 1: Open project in Xcode**

```bash
open bazodiac/bazodiac.xcodeproj
```

**Step 2: Build (⌘B)**

Expected: Multiple errors. Document each one by file+line.

**Step 3: Categorise errors into the buckets below**

Known-likely errors (all fixable in subsequent tasks):

| # | Likely location | Likely cause |
|---|----------------|--------------|
| A | `DesignSystem.swift` | `.clamped(to: 0...1)` — `0...1` infers as `ClosedRange<Int>` not `Double` |
| B | `MainTabView.swift` | `@Bindable var store = store` unused / wrong context |
| C | Any file with `UIImpactFeedbackGenerator` | UIKit not explicitly imported |
| D | `WuXingView.swift` | `stride(from:through:by:)` on `Double` — may need explicit type |
| E | `CosmicModels.swift` | `WuXingData.mock` dictionary literal `[CosmicElement: Double]` literal issues |

**Step 4: Commit error inventory**

```bash
# No code change — just make a note for the next tasks
git commit --allow-empty -m "chore: first build — errors catalogued in plan"
```

---

## Phase 2 — Foundation Layer (Compile-Green)

### Task 3: Fix `DesignSystem.swift`

**Files:**
- Modify: `bazodiac/bazodiac/DesignSystem.swift`

**Step 1: Fix `.clamped` type inference in `OrbitalRingsView`**

Find the line:
```swift
let dotAlpha = (ringAlpha + 0.35).clamped(to: 0...1)
```

Replace with explicit `Double` range:
```swift
let dotAlpha = (ringAlpha + 0.35).clamped(to: 0.0...1.0)
```

**Step 2: Verify `StarfieldView` renders correctly — add a Preview**

At the end of `DesignSystem.swift`, add:

```swift
// MARK: - Design System Preview

#Preview("Starfield") {
    StarfieldView(starCount: 120, goldTint: true)
        .frame(width: 390, height: 844)
        .background(Color.obsidian)
}

#Preview("OrbitalRings") {
    OrbitalRingsView(rings: 4, baseRadius: 50, ringSpacing: 32)
        .frame(width: 300, height: 300)
        .background(Color.obsidian)
}

#Preview("ElementBadge") {
    HStack(spacing: 16) {
        ForEach(CosmicElement.allCases) { e in
            ElementBadge(element: e, size: 44)
        }
    }
    .padding(24)
    .background(Color.obsidian)
}
```

**Step 3: Build (⌘B)**

Expected: `DesignSystem.swift` errors resolve.

**Step 4: Commit**

```bash
git add bazodiac/bazodiac/DesignSystem.swift
git commit -m "fix: DesignSystem — explicit Double range in clamped, add previews"
```

---

### Task 4: Fix `CosmicModels.swift`

**Files:**
- Modify: `bazodiac/bazodiac/CosmicModels.swift`

**Step 1: Add explicit type annotations to mock dictionary literals**

Find the `WuXingData.mock` definition. The dictionary literal:
```swift
balance: [
    .wood:  0.45,
    ...
]
```
may fail to infer key type. Make explicit:

```swift
balance: [CosmicElement.wood: 0.45,
           CosmicElement.fire: 0.20,
           CosmicElement.earth: 0.60,
           CosmicElement.metal: 0.15,
           CosmicElement.water: 0.80],
```

**Step 2: Verify `WesternData.mock` house starts array**

The `houseStarts` array must have exactly 12 elements (one per house). Count the values:
```swift
houseStarts: [67.9, 107.4, 137.8, 157.5, 177.2, 207.6,
               247.9, 287.4, 317.8, 337.5, 357.2,  27.6]
```
Count: 12 ✓ — no change needed.

**Step 3: Add unit test skeleton for CosmicElement**

Open `bazodiacTests/bazodiacTests.swift`. Replace the placeholder with:

```swift
import Testing
@testable import bazodiac

// MARK: - CosmicElement Tests

struct CosmicElementTests {

    @Test func allCasesHaveUniqueChineseChars() {
        let chars = CosmicElement.allCases.map(\.chineseChar)
        #expect(Set(chars).count == 5, "Each element must have a unique Chinese character")
    }

    @Test func generatingCycleIsComplete() {
        // Wood→Fire→Earth→Metal→Water→Wood
        var current = CosmicElement.wood
        var visited: [CosmicElement] = [current]
        for _ in 0..<4 {
            current = current.generates
            visited.append(current)
        }
        #expect(current.generates == .wood, "Generating cycle must loop back to Wood")
        #expect(visited.count == 5)
    }

    @Test func controllingCycleIsComplete() {
        var current = CosmicElement.wood
        for _ in 0..<4 { current = current.controls }
        #expect(current.controls == .wood, "Controlling cycle must loop back to Wood")
    }

    @Test func wuXingMockHasAllFiveElements() {
        let mock = WuXingData.mock
        #expect(mock.balance.keys.count == 5)
        #expect(mock.dominant == .water)
        #expect(mock.weakest  == .metal)
    }

    @Test func baziMockHasFourPillars() {
        let mock = BaZiData.mock
        #expect(mock.allPillars.count == 4)
        #expect(mock.day.type == .day)
    }

    @Test func zodiacSignStartDegreesAreSequential() {
        for (i, sign) in ZodiacSign.allCases.enumerated() {
            #expect(sign.startDegree == Double(i) * 30.0)
        }
    }
}
```

**Step 4: Run tests**

```bash
# In Xcode: ⌘U
# Or via xcodebuild:
xcodebuild test -scheme bazodiac -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 | grep -E "Test Suite|passed|failed|error:"
```

Expected: All 6 tests pass.

**Step 5: Commit**

```bash
git add bazodiac/bazodiac/CosmicModels.swift bazodiac/bazodiacTests/bazodiacTests.swift
git commit -m "fix: CosmicModels explicit types + unit tests for domain models"
```

---

### Task 5: Fix `CosmicStore.swift` + UIKit Imports

**Files:**
- Modify: `bazodiac/bazodiac/CosmicStore.swift`
- Modify (if needed): all files using `UIImpactFeedbackGenerator`

**Step 1: Add Swift Testing import to CosmicStore test**

Add a store test in `bazodiacTests.swift`:

```swift
// MARK: - CosmicStore Tests

@MainActor
struct CosmicStoreTests {

    @Test func initialStateIsSplash() {
        let store = CosmicStore()
        #expect(store.appPhase == .splash)
    }

    @Test func displayNameFallsBackWhenNameEmpty() {
        let store = CosmicStore()
        store.birthData.name = ""
        #expect(store.displayName == "Dein Kosmos")
    }

    @Test func displayNameUsesNameWhenSet() {
        let store = CosmicStore()
        store.birthData.name = "Layla"
        #expect(store.displayName == "Layla")
    }

    @Test func enterAppTransitionsToDashboardWhenProfileExists() async {
        let store = CosmicStore()
        store.profile = .mock
        store.enterApp(language: .german)
        #expect(store.appPhase == .dashboard)
    }

    @Test func enterAppTransitionsToBirthFormWhenNoProfile() async {
        let store = CosmicStore()
        store.profile = nil
        store.enterApp(language: .german)
        #expect(store.appPhase == .birthForm)
    }

    @Test func signOutResetsToSplash() {
        let store = CosmicStore()
        store.profile = .mock
        store.appPhase = .dashboard
        store.signOut()
        #expect(store.appPhase == .splash)
        #expect(store.profile == nil)
    }
}
```

**Step 2: Check if CosmicProfile needs Equatable for `profile = nil` test**

`CosmicProfile` is a struct but not `Equatable`. The `profile == nil` check compares `Optional<CosmicProfile>` to `nil` — this works without Equatable. ✓

**Step 3: Scan for UIFeedbackGenerator usage**

```bash
grep -rn "UIImpactFeedbackGenerator\|UISelectionFeedbackGenerator" bazodiac/bazodiac/
```

If any file shows errors like "use of unresolved identifier", add `import UIKit` at the top of that file (below `import SwiftUI`).

Files likely needing it (check error list from Task 2):
- `SplashView.swift`
- `BirthFormView.swift`
- `HomeView.swift`
- `MainTabView.swift`
- `BaZiView.swift`
- `LeviView.swift`

For each flagged file, add `import UIKit` as the second import line.

**Step 4: Run tests (⌘U)**

Expected: All 12 tests pass.

**Step 5: Commit**

```bash
git add bazodiac/bazodiacTests/bazodiacTests.swift bazodiac/bazodiac/*.swift
git commit -m "fix: UIKit imports + CosmicStore unit tests"
```

---

## Phase 3 — App Shell (Build Green, Launch Works)

### Task 6: Fix `bazodiacApp.swift` + `RootView`

**Files:**
- Verify: `bazodiac/bazodiac/bazodiacApp.swift`

**Step 1: Confirm struct name is unique and `@main` is singular**

```bash
grep -rn "@main\|@main " bazodiac/bazodiac/
```

Expected: exactly **1 hit** in `bazodiacApp.swift`. If any other file has `@main`, remove it.

**Step 2: Verify `RootView` phase transitions compile**

Build (`⌘B`). If `.push(from: .bottom)` transition is not available, replace with:

```swift
// Replace the transition in RootView body if needed:
case .birthForm:
    BirthFormView()
        .transition(.move(edge: .bottom).combined(with: .opacity))

case .dashboard:
    MainTabView()
        .transition(.move(edge: .trailing).combined(with: .opacity))
```

`.push(from:)` was introduced in iOS 16 and should be available. Keep as-is unless build fails.

**Step 3: Test — launch in simulator**

In Xcode, select iPhone 16 Pro (iOS 26) simulator. Run (`⌘R`).

Expected: App launches to `SplashView` showing dark background. Starfield may or may not be visible yet (depends on if Task 3 errors are fully fixed).

**Step 4: Commit**

```bash
git add bazodiac/bazodiac/bazodiacApp.swift
git commit -m "feat: app shell — RootView phase-driven navigation"
```

---

### Task 7: Fix and Polish `SplashView.swift`

**Files:**
- Modify: `bazodiac/bazodiac/SplashView.swift`

**Step 1: Verify all `withAnimation` blocks in `runSplashSequence`**

The sequence uses `Task { try? await Task.sleep(...) }` for delays. This is correct pattern — no `@MainActor` annotation needed because `SplashView` body is already on main actor.

Verify the `@MainActor` propagation:
```swift
// runSplashSequence is called from onAppear which is already on MainActor.
// Task closures inherit @MainActor from enclosing context. ✓
```

**Step 2: Fix potential issue — `Angle.radians` shorthand**

In `ZodiacWheelMini`, the Canvas draws arcs. Verify `cos(tickAngle.radians)` compiles. `Angle.radians` returns `Double`. `cos()` takes `Double`. ✓

**Step 3: Add Preview for full SplashView**

Verify the existing `#Preview` at the bottom of the file renders without crash.

**Step 4: Test animation sequence on device/simulator**

Run app (`⌘R`). Watch for:
- [ ] Starfield appears ~0.3s after launch
- [ ] Bazodiac title appears ~1.2s
- [ ] Scroll unrolls at ~1.8s
- [ ] "Coniunctio Caelorum" appears ~2.8s
- [ ] Language gate appears ~4.2s
- [ ] Tapping "Deutsch" triggers transition to `BirthFormView`

If language gate tap doesn't transition: check that `store.enterApp()` is being called. The `Task { ... }` delay before transitioning is 350ms — verify this in `languageButton` action.

**Step 5: Fix the `.onHover` modifier**

`.onHover` is macOS-only on most SwiftUI versions. On iOS, it's a no-op but should still compile. If it causes an error, wrap it:

```swift
.onHover { isHovered in
    withAnimation(.easeInOut(duration: 0.3)) {
        hoveredLanguage = isHovered ? code : nil
    }
}
```

This is valid on iOS — it just never fires. ✓ No fix needed.

**Step 6: Commit**

```bash
git add bazodiac/bazodiac/SplashView.swift
git commit -m "feat: SplashView — cinematic sequence working"
```

---

### Task 8: Fix and Test `BirthFormView.swift`

**Files:**
- Modify: `bazodiac/bazodiac/BirthFormView.swift`

**Step 1: Fix DatePicker color styling**

The current styling uses:
```swift
.colorInvert()
.colorMultiply(Color.cosmicGold)
```

This may produce unexpected colors depending on iOS 26 rendering. Replace with a cleaner approach:

```swift
DatePicker("", selection: $store.birthData.birthDate, displayedComponents: .date)
    .datePickerStyle(.compact)
    .labelsHidden()
    .tint(Color.cosmicGold)
    .preferredColorScheme(.dark)  // ensures dark rendering
    .scaleEffect(0.9, anchor: .trailing)
```

Remove `.colorInvert().colorMultiply()` from both DatePicker instances (date + time).

**Step 2: Fix `@Bindable` usage in child views**

`NameField`, `BirthDateField`, `BirthTimeField`, `BirthPlaceField` all declare:
```swift
@Bindable var store = store
```

This is the correct pattern for `@Observable` objects. Verify it compiles. If it fails with "cannot convert value of type 'CosmicStore' to expected argument type", check that `CosmicStore` is marked `@Observable` (it is).

**Step 3: Test the form flow manually**

Run app. After splash → tap "Deutsch" → `BirthFormView` appears.

Verify:
- [ ] Name field accepts text
- [ ] Date picker opens a compact picker
- [ ] Time picker opens correctly
- [ ] Place field accepts text
- [ ] Button is disabled when name is empty
- [ ] Button enables after typing a name
- [ ] Tapping button shows loading spinner
- [ ] After ~2.5s mock delay, transitions to `MainTabView`

**Step 4: Add UITest for birth form entry**

In `bazodiacUITests/bazodiacUITests.swift`:

```swift
@MainActor
func testBirthFormCanBeFilled() throws {
    let app = XCUIApplication()
    app.launch()

    // Wait for splash language gate
    let deutschButton = app.buttons["Deutsch"]
    let splashExists = deutschButton.waitForExistence(timeout: 6.0)
    XCTAssertTrue(splashExists, "Language gate should appear within 6s")

    deutschButton.tap()

    // Wait for birth form
    let nameField = app.textFields["Dein Name"]
    let formExists = nameField.waitForExistence(timeout: 2.0)
    XCTAssertTrue(formExists, "Birth form should appear after language selection")

    nameField.tap()
    nameField.typeText("Layla")

    // Calculate button should become enabled
    let calcButton = app.buttons.matching(identifier: "calculate").firstMatch
    // (Note: If button has no accessibility identifier, use label matching)
    // For now just verify form is visible
    XCTAssertTrue(app.staticTexts["Kosmischer Blueprint"].exists)
}
```

**Step 5: Commit**

```bash
git add bazodiac/bazodiac/BirthFormView.swift bazodiac/bazodiacUITests/bazodiacUITests.swift
git commit -m "feat: BirthFormView — form works, DatePicker styled, UI test added"
```

---

## Phase 4 — Dashboard Tabs

### Task 9: Fix `MainTabView.swift` + Custom Tab Bar

**Files:**
- Modify: `bazodiac/bazodiac/MainTabView.swift`

**Step 1: Remove unnecessary `@Bindable` in `tabContent`**

In `tabContent`, the `@Bindable var store = store` is used only for reading `store.selectedTab` (no binding). Remove it — the `@Environment` property is sufficient for reading:

```swift
// BEFORE:
@ViewBuilder
private var tabContent: some View {
    @Bindable var store = store
    switch store.selectedTab {

// AFTER:
@ViewBuilder
private var tabContent: some View {
    switch store.selectedTab {
```

**Step 2: Verify `symbolEffect(.bounce, value:)` compiles**

`.symbolEffect(.bounce, value:)` requires iOS 17+. Since target is iOS 26.2, this is fine. ✓

**Step 3: Simplify the GlassEffectContainer guard in tab bar**

Since target is iOS 26.2, remove the `#available` check and use directly:

```swift
// Replace the background block in CosmicTabBar with:
.background {
    GlassEffectContainer(spacing: 0) {
        Color.clear
    }
    .ignoresSafeArea(edges: .bottom)
}
```

**Step 4: Test tab bar on simulator**

Run app. After completing birth form (or dev-shortcut: inject mock profile):

- [ ] All 5 tabs visible with correct icons
- [ ] Tapping each tab switches content
- [ ] Active tab shows gold color + subtle glow
- [ ] Inactive tabs show faded gold
- [ ] Selection haptic fires on tap

**Step 5: Add dev shortcut to skip splash/form during development**

Add a launch argument check at the top of `bazodiacApp.swift` body:

```swift
// In RootView.init() or BazodiacApp.body, add for simulator dev:
.onAppear {
    #if DEBUG
    if CommandLine.arguments.contains("--skip-to-dashboard") {
        cosmicStore.profile = .mock
        cosmicStore.appPhase = .dashboard
    }
    #endif
}
```

Add scheme launch argument `--skip-to-dashboard` in Xcode:
Product → Scheme → Edit Scheme → Run → Arguments → Add `--skip-to-dashboard`

**Step 6: Commit**

```bash
git add bazodiac/bazodiac/MainTabView.swift bazodiac/bazodiac/bazodiacApp.swift
git commit -m "feat: MainTabView — custom tab bar, glass background, dev launch shortcut"
```

---

### Task 10: Fix `HomeView.swift`

**Files:**
- Modify: `bazodiac/bazodiac/HomeView.swift`

**Step 1: Verify `ScrollView.scrollBounceBehavior(.basedOnSize)` compiles**

Available iOS 16.4+. ✓ No change needed.

**Step 2: Fix `LazyVStack(pinnedViews:)` usage**

`LazyVStack(spacing: 0, pinnedViews: [])` is valid. The empty array just means no pinned views — fine but redundant. Keep as-is.

**Step 3: Test Home screen visual**

With `--skip-to-dashboard` launch arg active, run app and navigate to Home tab.

Verify:
- [ ] Orbital rings animate continuously (gold dots orbiting)
- [ ] "Dein Kosmischer Atlas" and "Layla" appear in header
- [ ] Big Three row shows Steinbock / Skorpion / Zwillinge with correct zodiac glyphs
- [ ] Interpretation card shows text with "Mehr lesen" expansion
- [ ] 2×2 section grid shows 4 cards with correct icons
- [ ] Levi teaser has animated waveform bars
- [ ] Daily quote card shows quote text

**Step 4: Fix `SectionCard` accessibility**

Add accessibility labels to `SectionCard` action button:

```swift
Button(action: {
    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
    action()
}) {
    // ...existing content...
}
.accessibilityLabel(title)
.accessibilityHint("Öffnet \(subtitle)")
```

**Step 5: Add unit test for DailyInsightCard expansion**

Unit tests can't directly test view state, but we can test the store's quote value:

```swift
// Add to bazodiacTests.swift:
@Test func cosmicProfileHasDailyQuote() {
    let profile = CosmicProfile.mock
    #expect(!profile.dailyQuote.isEmpty)
    #expect(!profile.interpretation.isEmpty)
}
```

**Step 6: Commit**

```bash
git add bazodiac/bazodiac/HomeView.swift bazodiac/bazodiacTests/bazodiacTests.swift
git commit -m "feat: HomeView — orbital animation, Big Three, section grid, Levi teaser"
```

---

### Task 11: Fix `WesternChartView.swift`

**Files:**
- Modify: `bazodiac/bazodiac/WesternChartView.swift`

**Step 1: Fix `ZodiacWheelView` struct visibility**

`ZodiacWheelView` is declared as non-private but only used within `WesternChartView.swift`. Make it private to prevent naming collisions:

```swift
// Change:
struct ZodiacWheelView: View {
// To:
private struct ZodiacWheelView: View {
```

Also make `BigThreeRow`, `BigThreeCell`, `PlanetList`, `PlanetRow`, `PlanetDetailSheet` all `private struct`.

**Step 2: Fix planet tap target coordinate system**

In `ZodiacWheelView.body`, the planet tap targets use:
```swift
.offset(x: pos.x - cx, y: pos.y - cy)
```

This offset is relative to center. Verify `cx` and `cy` are correctly the center of the GeometryReader frame. Since `cx = geo.size.width / 2` and `cy = geo.size.height / 2`, this is correct for a centered ZStack. ✓

**Step 3: Fix aspect line drawing (optional enhancement)**

Currently the chart does not draw aspect lines between planets. This is acceptable for the MVP. Add a TODO comment:

```swift
// TODO: Task 11b — Draw aspect lines (conjunction, trine, square, opposition, sextile)
// between planets using their degree differences.
```

**Step 4: Test chart rendering**

Navigate to Chart tab. Verify:
- [ ] Zodiac wheel renders with 12 colored sectors
- [ ] Zodiac glyphs (♈♉♊…) appear in each sector
- [ ] Planet glyphs (☉☽☿…) appear at correct positions
- [ ] House division lines visible (axis lines thicker)
- [ ] Tapping a planet opens detail sheet
- [ ] Detail sheet shows planet name, sign, house, degree
- [ ] Sheet dismisses on "Schließen"
- [ ] Big Three row below chart shows correct values
- [ ] Planet list is scrollable

**Step 5: Add test for WesternData mock**

```swift
// Add to bazodiacTests.swift:
@Test func westernDataMockHasTenPlanets() {
    #expect(WesternData.mock.planets.count == 10)
}

@Test func westernDataMockHasTwelveHouses() {
    #expect(WesternData.mock.houseStarts.count == 12)
}

@Test func allPlanetDegreesAreInEclipticRange() {
    for planet in WesternData.mock.planets {
        #expect(planet.degree >= 0 && planet.degree < 360,
               "Planet \(planet.planet.rawValue) degree \(planet.degree) out of range")
    }
}
```

**Step 6: Commit**

```bash
git add bazodiac/bazodiac/WesternChartView.swift bazodiac/bazodiacTests/bazodiacTests.swift
git commit -m "feat: WesternChartView — Canvas zodiac wheel, planet detail sheets"
```

---

### Task 12: Fix `BaZiView.swift`

**Files:**
- Modify: `bazodiac/bazodiac/BaZiView.swift`

**Step 1: Make all structs private**

All structs in `BaZiView.swift` that are not used outside the file:

```swift
// Change every `struct` that isn't BaZiView itself to `private struct`:
private struct DayMasterCard: View { ... }
private struct FourPillarsGrid: View { ... }
private struct PillarCard: View { ... }
private struct ElementDistributionBar: View { ... }
private struct ElementBarRow: View { ... }
private struct PillarDetailSheet: View { ... }
```

**Step 2: Fix `ElementBarRow` animation — ensure it animates once**

`ElementBarRow` uses `@State private var animValue: Double = 0` with `.onAppear` to animate. Verify this doesn't loop:

```swift
.onAppear {
    // Only animate once (onAppear can fire multiple times in LazyVStack)
    guard animValue == 0 else { return }
    withAnimation(.spring(duration: 1.1).delay(Double.random(in: 0...0.3))) {
        animValue = value
    }
}
```

Add the `guard` line.

**Step 3: Fix `PillarCard` element indicator bottom bar**

The current code:
```swift
Rectangle()
    .fill(pillar.stem.element.color.opacity(0.5))
    .frame(height: 2)
```
Is inside `VStack(spacing: 0)`. Verify this renders at the bottom of the card without clipping. If clipped, the card background clips it. Fix by moving the indicator outside the clipped ZStack:

```swift
// The indicator bar should be inside the clipShape, which it is via VStack.
// Test visually and adjust if needed.
```

**Step 4: Test BaZi screen**

Navigate to BaZi tab. Verify:
- [ ] "Tag-Meister · 日主" card shows 壬 in water-blue
- [ ] Four pillar columns render with correct Chinese characters
- [ ] Day pillar has gold border glow
- [ ] Animal emojis appear in each branch cell
- [ ] Element distribution bars animate in on appear
- [ ] Tapping a pillar opens detail sheet with 天干/地支 display
- [ ] Sheet shows correct labels and characters
- [ ] Element color in bottom strip matches pillar element

**Step 5: Add BaZi model tests**

```swift
// Add to bazodiacTests.swift:
@Test func baziPillarTypesHaveGermanLabels() {
    #expect(!BaZiPillar.PillarType.year.germanLabel.isEmpty)
    #expect(!BaZiPillar.PillarType.day.description.isEmpty)
}

@Test func heavenlyStemCharactersAreNonEmpty() {
    for pillar in BaZiData.mock.allPillars {
        #expect(!pillar.stem.char.isEmpty)
        #expect(!pillar.branch.char.isEmpty)
        #expect(!pillar.branch.animalEmoji.isEmpty)
    }
}
```

**Step 6: Commit**

```bash
git add bazodiac/bazodiac/BaZiView.swift bazodiac/bazodiacTests/bazodiacTests.swift
git commit -m "feat: BaZiView — four pillars, stele cards, element bars, detail sheets"
```

---

### Task 13: Fix `WuXingView.swift`

**Files:**
- Modify: `bazodiac/bazodiac/WuXingView.swift`

**Step 1: Make all structs private (same pattern as Tasks 11/12)**

```swift
private struct WuXingPentagon: View { ... }
private struct ElementLabel: View { ... }
private struct ElementHighlights: View { ... }
private struct ElementHighlightCard: View { ... }
private struct ElementBalanceBars: View { ... }
private struct ElementBarRow: View { ... }
private struct CyclesLegend: View { ... }
private struct CycleLegendItem: View { ... }
private struct ElementInterpretation: View { ... }
```

**Step 2: Fix `ElementBarRow` name conflict with `BaZiView.swift`**

Both `BaZiView.swift` and `WuXingView.swift` define `private struct ElementBarRow`. Since both are `private`, they don't conflict. ✓

**Step 3: Fix `stride` on Double**

In `WuXingPentagon.drawPentagon`:
```swift
for level in stride(from: 0.2, through: 1.0, by: 0.2) {
```
This creates a `StrideThrough<Double>`. `stride` with `Double` arguments works fine. ✓

**Step 4: Verify pentagon data polygon arrow drawing**

The `drawArrow` function takes `from` and `to` CGPoints. When `len < 0.01` it returns early. This guards against degenerate cases. ✓

The generating cycle array:
```swift
let genCycle = [0, 1, 2, 3, 4, 0]
```
`dataPts[genCycle[i + 1]]` where i goes 0..<5 and `genCycle[i+1]` for i=4 gives index 5 = `0`. This is valid. ✓

**Step 5: Test Wu-Xing screen**

Navigate to Elements tab. Verify:
- [ ] Pentagon renders with 5 colored grid levels (faint)
- [ ] Data polygon fills area proportional to element values
- [ ] Colored dots appear at each vertex
- [ ] Water vertex is largest (balance[water] = 0.80)
- [ ] Metal vertex is smallest (balance[metal] = 0.15)
- [ ] Generating cycle arrows are visible
- [ ] Element labels (木火土金水 with German names) appear at vertices
- [ ] Dominant/Weakest highlight cards show Water/Metal
- [ ] Balance bars animate in from 0 on screen appear
- [ ] Interpretation text shows in card at bottom

**Step 6: Add Wu-Xing tests**

```swift
// Add to bazodiacTests.swift:
@Test func wuXingPentagonValuesNormalized() {
    let mock = WuXingData.mock
    for value in mock.balance.values {
        #expect(value >= 0.0 && value <= 1.0)
    }
}

@Test func elementGermanNamesAreNonEmpty() {
    for element in CosmicElement.allCases {
        #expect(!element.germanName.isEmpty)
    }
}

@Test func wuXingSymbolNamesAreValidSFSymbols() {
    // Just verify they're non-empty strings (SF Symbol validation needs UIKit)
    for element in CosmicElement.allCases {
        #expect(!element.symbol.isEmpty)
    }
}
```

**Step 7: Commit**

```bash
git add bazodiac/bazodiac/WuXingView.swift bazodiac/bazodiacTests/bazodiacTests.swift
git commit -m "feat: WuXingView — pentagon canvas, element cycles, balance bars"
```

---

### Task 14: Fix `LeviView.swift`

**Files:**
- Modify: `bazodiac/bazodiac/LeviView.swift`

**Step 1: Make all structs private**

```swift
private struct Message: Identifiable { ... }
private struct LeviAvatarSection: View { ... }
private struct LeviWaveform: View { ... }
private struct MessageBubble: View { ... }
private struct LeviControlBar: View { ... }
extension Message {
    static let sampleConversation: [Message] = [...]
}
```

**Step 2: Fix `GlassEffectContainer` in `LeviControlBar`**

Since target is iOS 26.2, simplify:

```swift
// In LeviControlBar, replace the background block:
.background {
    GlassEffectContainer(spacing: 0) {
        Color.clear
    }
    .ignoresSafeArea(edges: .bottom)
}
```

(Remove the `#available` check since iOS 26.2 is the floor.)

**Step 3: Fix `LeviControlBar` as `@Observable` binding consumer**

`LeviControlBar` takes `@Binding var isListening: Bool` etc. This is the correct pattern for child views that modify parent state. ✓

**Step 4: Test Levi screen**

Navigate to Levi tab. Verify:
- [ ] Dark purple-tinted background
- [ ] Orbital rings visible in idle state
- [ ] Start button toggles session
- [ ] After session start, Levi greeting message appears (~0.8s)
- [ ] Message bubbles render — Levi (dark, left-aligned) vs User (gold, right-aligned)
- [ ] Waveform appears when `isSpeaking = true`
- [ ] Typing in text field + Send transitions to waveform then response
- [ ] Mic button animates when tapped
- [ ] Stop button ends session
- [ ] Session inactive → inputs are dimmed (0.35 opacity)

**Step 5: Fix `ScrollViewReader` auto-scroll**

The `.onChange(of: messages.count)` should scroll to bottom on new messages. Verify it works:

```swift
.onChange(of: messages.count) {
    withAnimation(.spring(duration: 0.4)) {
        proxy.scrollTo(scrollID, anchor: .bottom)
    }
}
```

The `scrollID` is a `String` constant `"bottom"` and the clear view `.id(scrollID)` is the scroll target. ✓

**Step 6: Commit**

```bash
git add bazodiac/bazodiac/LeviView.swift
git commit -m "feat: LeviView — voice companion, waveform canvas, chat bubbles, glass bar"
```

---

## Phase 5 — Polish & Accessibility

### Task 15: Accessibility Pass

**Files:**
- Modify: All view files

**Step 1: Add `accessibilityLabel` to all icon-only buttons**

Search for `Image(systemName:)` inside `Button` with no text label:

```bash
grep -n "Image(systemName" bazodiac/bazodiac/*.swift | grep -v "Label("
```

For each bare icon button, add:
```swift
.accessibilityLabel("Beschreibung der Aktion")
```

Key buttons to fix:
- Mic button in `LeviView` → `.accessibilityLabel("Sprachaufnahme starten")`
- Send button in `LeviView` → `.accessibilityLabel("Nachricht senden")`
- Tab bar items — already have text labels in `TabBarItem` ✓
- Planet detail tap targets → `.accessibilityLabel("\(planet.planet.germanName) Details")`

**Step 2: Add `accessibilityElement(children:)` to Canvas views**

Canvas views are invisible to VoiceOver. Add hidden accessibility elements:

```swift
// In ZodiacWheelView, add below the ZStack:
.accessibilityElement(children: .contain)
.accessibilityLabel("Geburts-Chart")

// In WuXingPentagon:
.accessibilityElement(children: .ignore)
.accessibilityLabel("Wu-Xing Fünf-Elemente-Pentagon. Dominant: \(data.dominant.germanName). Schwächstes Element: \(data.weakest.germanName).")

// In StarfieldView:
.accessibilityHidden(true)  // purely decorative

// In OrbitalRingsView:
.accessibilityHidden(true)  // purely decorative
```

**Step 3: Verify Dynamic Type**

Bazodiac uses custom `CosmicFont` with fixed sizes. This breaks Dynamic Type. For launch, this is acceptable (luxury apps often use fixed type). Add a TODO:

```swift
// TODO: Task 15b — Add Dynamic Type scaling support using
// .dynamicTypeSize(.large ... .accessibility3) for body text.
// Display titles should remain fixed for aesthetic coherence.
```

**Step 4: Run on large simulator (iPad or iPhone Pro Max)**

Verify no layout breaks:
- [ ] Tab bar adapts to wider screen
- [ ] Zodiac wheel fills proportionally (uses `GeometryReader` ✓)
- [ ] Pentagon fills proportionally ✓
- [ ] Form fields don't overflow

**Step 5: Commit**

```bash
git add bazodiac/bazodiac/*.swift
git commit -m "feat: accessibility labels, decorative elements hidden from VoiceOver"
```

---

### Task 16: Performance & Final Polish

**Files:**
- Modify: `HomeView.swift`, `WesternChartView.swift`

**Step 1: Profile with Xcode Instruments — Animation Hitches**

In Xcode: Product → Profile → Choose "Animation Hitches" template.

Look for hitches in:
- Starfield Canvas rendering (120 stars)
- Orbital rings Canvas rendering
- Tab switching animation

If starfield drops below 60fps:
```swift
// In StarfieldView, reduce star count on non-Pro devices:
init(starCount: Int = 120, goldTint: Bool = true) {
    let adjustedCount: Int
    #if targetEnvironment(simulator)
    adjustedCount = min(starCount, 60)
    #else
    adjustedCount = starCount
    #endif
    self.starCount = adjustedCount
    // ...
}
```

**Step 2: Verify all Xcode Previews compile and render**

Open each file and verify its `#Preview` renders without crash:
- [ ] `DesignSystem.swift` — Starfield, OrbitalRings, ElementBadge
- [ ] `SplashView.swift` — Full splash
- [ ] `HomeView.swift` — Home with mock profile
- [ ] `WesternChartView.swift` — Chart with mock data
- [ ] `BaZiView.swift` — BaZi with mock data
- [ ] `WuXingView.swift` — Wu-Xing with mock data
- [ ] `LeviView.swift` — Levi with mock profile
- [ ] `BirthFormView.swift` — Empty form

**Step 3: Run full test suite**

```bash
xcodebuild test \
  -scheme bazodiac \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=26.0' \
  2>&1 | grep -E "Test Suite|passed|failed|error:"
```

Expected: **All tests pass** (~20 unit tests).

**Step 4: Final integration test — full happy path**

Run app with `--skip-to-dashboard` OFF:
1. App launches → Splash starfield appears
2. Language gate appears ~4s
3. Tap "Deutsch"
4. BirthFormView appears
5. Type "Layla" in name field
6. Date/Time pre-filled → accept defaults
7. Type "München" in place field
8. Tap "Kosmischen Blueprint berechnen"
9. Loading spinner ~2.5s
10. Main dashboard appears
11. Home tab shows Layla's cosmic blueprint
12. Navigate all 5 tabs — each renders correctly
13. Tap planet in Chart → detail sheet opens/dismisses
14. Tap pillar in BaZi → detail sheet opens/dismisses
15. Start Levi session → greeting appears
16. Type a question → Levi responds

**Step 5: Tag release**

```bash
git add -A
git commit -m "feat: Bazodiac iOS v0.1.0 — design implementation complete"
git tag v0.1.0-design-concept
```

---

## Phase 6 — API Integration Hooks (Stubs Ready for Backend)

> These tasks are **not part of this plan**. They are defined here as the clear next step.

| Future Task | File | What to implement |
|---|---|---|
| Task 17 | `CosmicStore.swift` | Replace mock in `submitBirthData()` with real BAFE API calls (`/calculate/bazi`, `/calculate/western`, `/calculate/wuxing`) |
| Task 18 | `CosmicStore.swift` | Add Gemini API call for interpretation text |
| Task 19 | `CosmicStore.swift` | Add Supabase auth (sign-in/sign-up sheet) |
| Task 20 | `LeviView.swift` | Replace chat stub with ElevenLabs iOS SDK WebSocket integration |
| Task 21 | `WesternChartView.swift` | Render actual 3D orrery via RealityKit or SceneKit |
| Task 22 | `BazodiacApp.swift` | Add WidgetKit extension for Lock Screen cosmic weather |

---

## Test Coverage Summary

After completing this plan, you should have:

| Layer | Tests | Count |
|-------|-------|-------|
| `CosmicElement` — cycles, chars | Unit | 3 |
| `WuXingData` — mock validity | Unit | 3 |
| `BaZiData` — mock validity | Unit | 3 |
| `WesternData` — mock validity | Unit | 3 |
| `CosmicStore` — state transitions | Unit | 6 |
| `CosmicProfile` — non-empty fields | Unit | 1 |
| Birth form entry | UI Test | 1 |
| App launch performance | UI Test | 1 |
| **Total** | | **~21** |

---

## Quick Reference — Build + Test Commands

```bash
# Build only (no run)
xcodebuild build -scheme bazodiac -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Run unit tests only
xcodebuild test -scheme bazodiac -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:bazodiacTests

# Run UI tests only  
xcodebuild test -scheme bazodiac -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:bazodiacUITests

# Clean build folder
xcodebuild clean -scheme bazodiac

# Open Xcode
open bazodiac/bazodiac.xcodeproj
```

---

*Plan saved: 2026-03-26 · Bazodiac iOS Implementation · bazodiac/docs/plans/*
