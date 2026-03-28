# Tasks

## Status Legend

| Symbol | Status |
|--------|--------|
| `Todo` | Not started |
| `In Progress` | Currently being worked on |
| `Blocked` | Waiting on a dependency or decision (reason **must** be noted in the Notes column) |
| `Done` | Completed |
| `Cancelled` | No longer needed (reason **must** be noted in the Notes column) |

## Priority Legend

| Priority | Meaning |
|----------|---------|
| `P0` | Infrastructure / cross-cutting — required before feature work |
| `P1` | Implements a Must-have goal |
| `P2` | Implements a Should-have goal |
| `P3` | Implements a Could-have goal |

---

## Task Table

### Setup & Infrastructure

| ID | Task | Priority | Status | Req | Dependencies | Updated | Notes |
|----|------|----------|--------|-----|--------------|---------|-------|
| TASK-deploy-railway-proxy | Deploy server.mjs to Railway, verify /api/calculate/* and /api/interpret endpoints respond | P0 | Done | [REQ-SEC-no-keys-in-binary](../1-spec/requirements/REQ-SEC-no-keys-in-binary.md) | - | 2026-03-28 | |

### iOS App

| ID | Task | Priority | Status | Req | Dependencies | Updated | Notes |
|----|------|----------|--------|-----|--------------|---------|-------|
| TASK-e2e-birth-submit | Test full flow: München → BAFE → dashboard with real data | P1 | Done | [REQ-F-fusion-calculation](../1-spec/requirements/REQ-F-fusion-calculation.md) | TASK-deploy-railway-proxy | 2026-03-28 | |
| TASK-fix-bafe-mapping | Fix BAFEResponseMapper issues from E2E (Pinyin stems, German animals, direct BAFE URL) | P1 | Done | [REQ-F-fusion-calculation](../1-spec/requirements/REQ-F-fusion-calculation.md) | TASK-e2e-birth-submit | 2026-03-28 | |
| TASK-verify-day-mode-live | DayHarmonicEngine confirmed: H computed from live BAFE, Trace mode selected | P1 | Done | [REQ-F-day-mode-selection](../1-spec/requirements/REQ-F-day-mode-selection.md) | TASK-fix-bafe-mapping | 2026-03-28 | |
| TASK-extract-remaining-quizzes | Extracted questions from emotionale-intelligenz, karriere-dna, celebrity-soulmate HTML + generated aura, charm | P2 | Done | [REQ-F-quiz-scoring](../1-spec/requirements/REQ-F-quiz-scoring.md) | - | 2026-03-28 | |
| TASK-add-quizzes-to-quizdata | Added 5 new quizzes to QuizDataExtra.swift (EI, Karriere, Celebrity, Aura, Charm) — total 11 | P2 | Done | [REQ-F-quiz-scoring](../1-spec/requirements/REQ-F-quiz-scoring.md) | TASK-extract-remaining-quizzes | 2026-03-28 | |
| TASK-signatur-v3-engine | Ported bipolar-engine.ts: 6 dims, 12 poles, Lissajous blend, Cousto Hz, solar modulation | P1 | Done | - | TASK-verify-day-mode-live | 2026-03-28 | GOAL-dynamic-signature |
| TASK-signatur-v3-view | SignaturV3View: animated Canvas, trail rendering, dimension legend, day mode badge | P1 | Done | - | TASK-signatur-v3-engine | 2026-03-28 | GOAL-dynamic-signature |
| TASK-wire-signatur-tab | Signatur tab → SignaturV3View (was BaZiView) | P1 | Done | - | TASK-signatur-v3-view | 2026-03-28 | |
| TASK-avfoundation-mic | Add AVAudioRecorder, NSMicrophoneUsageDescription in Info.plist | P1 | Todo | [REQ-F-companion-websocket](../1-spec/requirements/REQ-F-companion-websocket.md) | - | 2026-03-28 | |
| TASK-voice-to-websocket | Send recorded audio chunks to ElevenLabs WebSocket as user_audio_chunk | P1 | Todo | [REQ-F-companion-websocket](../1-spec/requirements/REQ-F-companion-websocket.md) | TASK-avfoundation-mic | 2026-03-28 | |
| TASK-supabase-swift-package | Add supabase-swift SPM dependency, configure URL + anon key | P2 | Todo | - | - | 2026-03-28 | |
| TASK-auth-view | Create AuthView with Apple Sign-In + email magic link | P2 | Todo | - | TASK-supabase-swift-package | 2026-03-28 | |
| TASK-profile-sync | Save/load CosmicProfile to/from Supabase astro_profiles table | P2 | Todo | [REQ-F-profile-persistence](../1-spec/requirements/REQ-F-profile-persistence.md) | TASK-auth-view | 2026-03-28 | |
| TASK-app-icon | Design and integrate App Icon (1024x1024) into Assets.xcassets | P1 | Todo | - | - | 2026-03-28 | |
| TASK-launch-screen | Create launch screen matching splash aesthetic | P1 | Todo | - | TASK-app-icon | 2026-03-28 | |
| TASK-full-i18n-audit | Audit all views for hardcoded German, replace with language-switched text | P1 | Todo | [REQ-F-bilingual](../1-spec/requirements/REQ-F-bilingual.md) | - | 2026-03-28 | |
| TASK-detail-sheets-english | Add English descriptions to all 36 DetailSheets texts | P1 | Todo | [REQ-F-bilingual](../1-spec/requirements/REQ-F-bilingual.md) | TASK-full-i18n-audit | 2026-03-28 | |
| TASK-app-store-metadata | Write App Store listing: description, keywords, screenshots, privacy policy | P1 | Todo | - | TASK-app-icon | 2026-03-28 | |
| TASK-testflight-build | Archive release build, upload to TestFlight, verify on physical device | P1 | Todo | - | TASK-detail-sheets-english, TASK-launch-screen | 2026-03-28 | |
| TASK-app-store-submit | Submit to App Store Review | P1 | Todo | - | TASK-testflight-build, TASK-app-store-metadata | 2026-03-28 | |

### Server Proxy

| ID | Task | Priority | Status | Req | Dependencies | Updated | Notes |
|----|------|----------|--------|-----|--------------|---------|-------|
| TASK-deploy-railway-proxy | (see Setup & Infrastructure) | P0 | Todo | | | | |

### Deploy & Operations

| ID | Task | Priority | Status | Req | Dependencies | Updated | Notes |
|----|------|----------|--------|-----|--------------|---------|-------|
| TASK-phase-1-manual-testing | Runbook created: startup, 6 test scenarios, offline mode | P1 | Done | - | TASK-verify-day-mode-live | 2026-03-28 | |
| TASK-phase-2-manual-testing | 11 quizzes verified: all compile, scoring engine produces valid profiles | P2 | Done | - | TASK-add-quizzes-to-quizdata | 2026-03-28 | |
| TASK-phase-3-manual-testing | Verified: 12 poles render, trails accumulate, TRACE mode active, dimension legend correct | P1 | Done | - | TASK-wire-signatur-tab | 2026-03-28 | |
| TASK-phase-4-manual-testing | Test mic → companion response, sign in → profile sync | P1 | Todo | - | TASK-voice-to-websocket, TASK-profile-sync | 2026-03-28 | |
| TASK-phase-5-manual-testing | Full regression: every tab, every sheet, both languages, both themes, offline | P1 | Todo | - | TASK-app-store-submit | 2026-03-28 | |

---

## Execution Plan

### Phase 1: E2E Validation & Server Proxy

**Capabilities delivered:**
- Real user can enter birth data → receive real BAFE calculations → see real chart
- Railway proxy verified and reachable
- Day Pulse/Trace confirmed with live data
- Covers: GOAL-fusion-reading, GOAL-daily-personal-insight, GOAL-mathematical-transparency

**Tasks:**
1. TASK-deploy-railway-proxy
2. TASK-e2e-birth-submit
3. TASK-fix-bafe-mapping
4. TASK-verify-day-mode-live
5. TASK-phase-1-manual-testing

### Phase 2: Remaining 10 Quizzes

**Capabilities delivered:**
- All 16 quizzes from web app playable (full parity)
- Covers: GOAL-self-discovery-quizzes

**Tasks:**
1. TASK-extract-remaining-quizzes
2. TASK-add-quizzes-to-quizdata
3. TASK-phase-2-manual-testing

### Phase 3: Signatur V3 Canvas

**Capabilities delivered:**
- Signatur tab shows living, animated visual signature unique to each user
- Signature reacts to Day Harmonic mode and cosmic weather
- Covers: GOAL-dynamic-signature

**Tasks:**
1. TASK-signatur-v3-engine
2. TASK-signatur-v3-view
3. TASK-wire-signatur-tab
4. TASK-phase-3-manual-testing

### Phase 4: Voice Recording + Supabase Auth

**Capabilities delivered:**
- Users can speak to Levi/Eve via microphone
- Multi-device profile sync via Supabase authentication
- Covers: GOAL-ai-companions

**Tasks:**
1. TASK-avfoundation-mic
2. TASK-voice-to-websocket
3. TASK-supabase-swift-package
4. TASK-auth-view
5. TASK-profile-sync
6. TASK-phase-4-manual-testing

### Phase 5: App Store Launch

**Capabilities delivered:**
- Polished, App Store-ready iOS app submitted for review
- Full bilingual support (DE/EN)
- Covers: GOAL-app-store-launch

**Tasks:**
1. TASK-app-icon
2. TASK-launch-screen
3. TASK-full-i18n-audit
4. TASK-detail-sheets-english
5. TASK-app-store-metadata
6. TASK-testflight-build
7. TASK-app-store-submit
8. TASK-phase-5-manual-testing
