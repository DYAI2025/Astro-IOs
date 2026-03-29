# iOS Code Review Fixes Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix 2 issues from code review: move hardcoded ElevenLabs agent IDs to Info.plist config, and propagate GeminiService errors to CosmicStore for UI visibility.

**Architecture:** ElevenLabs agent IDs move from the `ConvaiAgent` enum to `Info.plist` + `AppConfig.swift`, matching the existing pattern for `ELEVENLABS_AGENT_ID` and `SUPABASE_URL`. GeminiService gets a new throwing overload so CosmicStore can set `error` on failure while still falling back to template text.

**Tech Stack:** Swift 5.9+, SwiftUI, iOS 26+

---

### Task 1: Move ElevenLabs Agent IDs to Info.plist + AppConfig

**Files:**
- Modify: `bazodiac/bazodiac/Info.plist`
- Modify: `bazodiac/bazodiac/Config/AppConfig.swift`
- Modify: `bazodiac/bazodiac/Services/ElevenLabsService.swift`

**Step 1: Add agent IDs to Info.plist**

Add two new keys after the existing `NSMicrophoneUsageDescription` entry in `bazodiac/bazodiac/Info.plist`:

```xml
<key>ELEVENLABS_LEVI_AGENT_ID</key>
<string>agent_1801kje0zqc8e4b89swbt7wekawv</string>
<key>ELEVENLABS_EVE_AGENT_ID</key>
<string>agent_9101kmntjynwfz6t2ep687a6qb09</string>
```

**Step 2: Add AppConfig accessors**

In `bazodiac/bazodiac/Config/AppConfig.swift`, replace the single `elevenLabsAgentID` property with two agent-specific properties:

```swift
// Replace this:
static var elevenLabsAgentID: String {
    Bundle.main.object(forInfoDictionaryKey: "ELEVENLABS_AGENT_ID") as? String ?? ""
}

// With this:
static var elevenLabsLeviAgentID: String {
    Bundle.main.object(forInfoDictionaryKey: "ELEVENLABS_LEVI_AGENT_ID") as? String ?? ""
}

static var elevenLabsEveAgentID: String {
    Bundle.main.object(forInfoDictionaryKey: "ELEVENLABS_EVE_AGENT_ID") as? String ?? ""
}
```

Also update `leviEnabled` to use the new property:

```swift
static var leviEnabled: Bool {
    !elevenLabsLeviAgentID.isEmpty
}
```

**Step 3: Update ConvaiAgent to use AppConfig**

In `bazodiac/bazodiac/Services/ElevenLabsService.swift`, change the `agentId` computed property in the `ConvaiAgent` enum:

```swift
// Replace this:
var agentId: String {
    switch self {
    case .levi: return "agent_1801kje0zqc8e4b89swbt7wekawv"
    case .eve:  return "agent_9101kmntjynwfz6t2ep687a6qb09"
    }
}

// With this:
var agentId: String {
    switch self {
    case .levi: return AppConfig.elevenLabsLeviAgentID
    case .eve:  return AppConfig.elevenLabsEveAgentID
    }
}
```

**Step 4: Verify build**

Run:
```bash
cd bazodiac && xcodebuild build -scheme bazodiac -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -quiet 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 5: Commit**

```bash
git add bazodiac/bazodiac/Info.plist bazodiac/bazodiac/Config/AppConfig.swift bazodiac/bazodiac/Services/ElevenLabsService.swift
git commit -m "refactor(ios): move ElevenLabs agent IDs from source to Info.plist"
```

---

### Task 2: Propagate GeminiService Errors to CosmicStore

**Files:**
- Modify: `bazodiac/bazodiac/Services/GeminiService.swift`
- Modify: `bazodiac/bazodiac/CosmicStore.swift`

The strategy: GeminiService already falls back to template text on failure (this is correct — the user still gets content). The problem is that the user has no idea the AI interpretation failed. Solution: return both the fallback text AND a warning string that CosmicStore can surface in `error` temporarily.

**Step 1: Add a result type to GeminiService**

At the top of `bazodiac/bazodiac/Services/GeminiService.swift`, after the `GeminiDailyQuoteResponse` struct, add:

```swift
struct GeminiResult {
    let text: String
    let warning: String?  // non-nil when fallback was used
}
```

**Step 2: Change `interpretProfile` return type**

In `GeminiService.swift`, change `interpretProfile` to return `GeminiResult`:

```swift
func interpretProfile(results: BAFEAllResults, birthData: BirthData, lang: CosmicStore.Language) async -> GeminiResult {
```

In the success path (line 76), change:
```swift
return decoded.interpretation
```
to:
```swift
return GeminiResult(text: decoded.interpretation, warning: nil)
```

In the catch block (line 78-81), change:
```swift
print("⚠️ GeminiService: Interpretation fehlgeschlagen (\(error)) — Template-Fallback")
return templateInterpretation(results: results, birthData: birthData, lang: lang)
```
to:
```swift
let fallback = templateInterpretation(results: results, birthData: birthData, lang: lang)
let warning = lang == .german
    ? "KI-Interpretation nicht verfügbar — Template wird angezeigt."
    : "AI interpretation unavailable — showing template."
return GeminiResult(text: fallback, warning: warning)
```

**Step 3: Update CosmicStore to handle GeminiResult**

In `bazodiac/bazodiac/CosmicStore.swift`, in `submitBirthData()` (around line 150-153), change:

```swift
let interpretation = await GeminiService.shared.interpretProfile(
    results: results,
    birthData: birthData,
    lang: language
)
```
to:
```swift
let geminiResult = await GeminiService.shared.interpretProfile(
    results: results,
    birthData: birthData,
    lang: language
)
if let warning = geminiResult.warning {
    self.error = warning
}
```

Then update the `buildProfile` call (line 166-171) to use `geminiResult.text` instead of `interpretation`:

```swift
let newProfile = BAFEResponseMapper.buildProfile(
    from: results,
    birthData: birthData,
    interpretation: geminiResult.text,
    dailyQuote: quote
)
```

Do the same in `recalculate()` (around line 201-205):

```swift
let geminiResult = await GeminiService.shared.interpretProfile(
    results: results,
    birthData: birthData,
    lang: language
)
if let warning = geminiResult.warning {
    self.error = warning
}
let updated = BAFEResponseMapper.buildProfile(
    from: results,
    birthData: birthData,
    interpretation: geminiResult.text,
    dailyQuote: profile?.dailyQuote ?? ""
)
```

**Step 4: Verify build**

Run:
```bash
cd bazodiac && xcodebuild build -scheme bazodiac -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -quiet 2>&1 | tail -5
```
Expected: `** BUILD SUCCEEDED **`

**Step 5: Commit**

```bash
git add bazodiac/bazodiac/Services/GeminiService.swift bazodiac/bazodiac/CosmicStore.swift
git commit -m "fix(ios): propagate Gemini fallback warnings to CosmicStore.error for UI visibility"
```

---

### Notes

- **Dropped Task 1 (CosmicWeatherService @MainActor):** Already has `@MainActor` at line 69. The code review finding was a false positive.
- **No tests:** The Xcode project has `bazodiacTests` and `bazodiacUITests` targets but no existing tests. Adding a test infrastructure is out of scope for this bugfix plan. The build verification step confirms no regressions.
- **Info.plist agent IDs:** These are not secrets (they're public-facing agent identifiers, not API keys). Moving them to Info.plist is about configurability and binary hygiene, not security. The actual API authentication happens server-side.
