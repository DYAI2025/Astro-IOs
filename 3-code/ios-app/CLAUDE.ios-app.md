# iOS App

**Responsibility**: Native SwiftUI client — all UI rendering, state management, local persistence, real-time visual signatures, quiz engine, and AI companion chat interface.

**Technology**: Swift 5.9+ / SwiftUI / iOS 26.2+ / Xcode

## Interfaces

- HTTP POST → BAFE API (via Railway proxy): astrology calculations
- HTTP POST → Gemini API (via Railway proxy): interpretation generation
- WebSocket → ElevenLabs Convai: AI companion conversations
- HTTP GET → NOAA SWPC: cosmic weather (Kp-Index)
- MapKit/CoreLocation → Apple: geocoding + timezone resolution

## Requirements Addressed

| File | Type | Priority | Summary |
|------|------|----------|---------|
| [REQ-F-geocoding](../../1-spec/requirements/REQ-F-geocoding.md) | Functional | Must-have | Birth place autocomplete + lat/lon/tz |
| [REQ-F-fusion-calculation](../../1-spec/requirements/REQ-F-fusion-calculation.md) | Functional | Must-have | Parallel BAFE → CosmicProfile |
| [REQ-F-day-mode-selection](../../1-spec/requirements/REQ-F-day-mode-selection.md) | Functional | Must-have | Harmony Index → Pulse/Trace |
| [REQ-F-cosmic-weather](../../1-spec/requirements/REQ-F-cosmic-weather.md) | Functional | Must-have | NOAA Kp + moon phase |
| [REQ-F-companion-websocket](../../1-spec/requirements/REQ-F-companion-websocket.md) | Functional | Must-have | ElevenLabs WebSocket |
| [REQ-F-quiz-scoring](../../1-spec/requirements/REQ-F-quiz-scoring.md) | Functional | Should-have | Dimension scoring + profile matching |
| [REQ-F-profile-persistence](../../1-spec/requirements/REQ-F-profile-persistence.md) | Functional | Must-have | UserDefaults JSON persistence |
| [REQ-F-bilingual](../../1-spec/requirements/REQ-F-bilingual.md) | Functional | Must-have | DE/EN language support |
| [REQ-F-detail-sheets](../../1-spec/requirements/REQ-F-detail-sheets.md) | Functional | Must-have | Tappable Cosmic Triad sheets |
| [REQ-SEC-no-keys-in-binary](../../1-spec/requirements/REQ-SEC-no-keys-in-binary.md) | Security | Must-have | No secrets in binary |
| [REQ-USA-no-astro-jargon](../../1-spec/requirements/REQ-USA-no-astro-jargon.md) | Usability | Must-have | Poetic realism, no astro jargon |
| [REQ-REL-bafe-fallback](../../1-spec/requirements/REQ-REL-bafe-fallback.md) | Reliability | Must-have | Graceful offline/failure handling |
| [REQ-PERF-api-response](../../1-spec/requirements/REQ-PERF-api-response.md) | Performance | Should-have | Full calculation <5s |

## Relevant Decisions

| File | Title | Trigger |
|------|-------|---------|
<!-- No decisions recorded yet -->

## Source Code Location

All Swift source files live in `bazodiac/bazodiac/` (Xcode project root). Key directories:

- `bazodiac/bazodiac/*.swift` — Views, Models, Store
- `bazodiac/bazodiac/Services/` — API clients, persistence, engines
- `bazodiac/bazodiac/Config/` — AppConfig
- `bazodiac/bazodiac/Fonts/` — Cormorant Garamond TTFs
