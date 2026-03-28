# REQ-REL-bafe-fallback: Graceful BAFE API Failure Handling

**Type**: Reliability
**Status**: Draft
**Priority**: Must-have
**Source**: [CON-bafe-dependency](../constraints/CON-bafe-dependency.md)
**Related story**: [US-enter-birth-data](../user-stories/US-enter-birth-data.md), [US-offline-access](../user-stories/US-offline-access.md)

## Description

When the BAFE API is unreachable or returns errors, the app must degrade gracefully: show an error message for new calculations, serve cached profile for returning users, and provide template-based interpretation fallback.

## Acceptance Criteria

- [ ] BAFE timeout set to 20s per endpoint; individual endpoint failures do not block others (parallel with fallback)
- [ ] Returning user with cached profile can use all features offline (Atlas, detail sheets, Day Pulse/Trace from cache)
- [ ] New user without profile sees clear error: "Calculation requires internet connection" with retry button
- [ ] Template interpretation (GeminiService fallback) provides a basic reading when Gemini proxy is unreachable
