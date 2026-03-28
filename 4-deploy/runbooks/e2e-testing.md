# E2E Testing Runbook — Phase 1

## Prerequisites

- Xcode installed with iOS 26.2+ Simulator
- Internet connection (BAFE API + NOAA)
- Repository cloned and built (`xcodebuild ... build`)

## Startup

```bash
cd bazodiac
xcodebuild -project bazodiac.xcodeproj -scheme bazodiac \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -configuration Debug build
xcrun simctl install booted bazodiac.app
xcrun simctl launch booted com.BenjaminPoersch.bazodiac
```

## Test Scenarios

### 1. Birth Data Submission
1. Launch app → Splash screen → Choose "Deutsch"
2. Enter: Name "Test User", Date 15.01.1990, Time 14:30
3. Type "München" in birth place → autocomplete appears → select "München, Deutschland"
4. Green checkmark ✅ appears next to place field
5. Tap "Kosmischen Blueprint berechnen"
6. **Expected:** Loading spinner → Dashboard appears within 5s

### 2. Dashboard Verification
1. Header shows "Bazodiac", user name, "München, Deutschland"
2. Day Pulse or Day Trace card visible with date and Lissajous/rings visual
3. Three tiles: Sonne (Steinbock), Jahrestier (Snake/Schlange), Element (Holz)
4. Tap each tile → detail sheet opens with descriptions
5. Settings gear icon visible top-right

### 3. Day Mode
1. DAY-TRACE or DAY-PULSE label visible (gold or silver)
2. 2-3 sentence text, no astro jargon
3. Moon phase shown as subtext
4. If Kp ≥ 5: storm indicator visible

### 4. Charts Tab
1. Tap "Charts" → Western zodiac wheel renders
2. Planet dots visible at correct positions
3. Sign labels (AR/TA/GE...) around wheel
4. Big Three row: sign badges with element colors

### 5. Signatur Tab
1. Tap "Signatur" → BaZi Four Pillars view
2. Day Master highlighted
3. Four pillar cards with Chinese characters + element badges

### 6. Offline Mode
1. Enable Airplane Mode
2. Kill and relaunch app
3. **Expected:** Dashboard loads from cache, all tiles and Day mode visible
4. Tap "Recalculate" → error message "Internet required"

## Known Limitations

- Gemini interpretation requires Supabase JWT (not yet implemented) → template fallback used
- Companion WebSocket requires session start (manual tap)
- Quiz completion not persisted across app reinstalls (UserDefaults only)
