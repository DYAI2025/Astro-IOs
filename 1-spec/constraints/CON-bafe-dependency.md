# CON-bafe-dependency: BAFE API Dependency

**Category**: Technical

**Status**: Active

**Source stakeholder**: [STK-developer](../stakeholders.md)

## Description

All astrology calculations (Western chart, BaZi pillars, Wu-Xing vector, Fusion) depend on the external BAFE API. There is no local computation fallback in the iOS client.

## Rationale

Astronomical ephemeris calculations (planetary positions, house cusps, Chinese calendar conversions) require specialized libraries and datasets that are impractical to bundle in a mobile app. BAFE centralizes this complexity.

## Impact

- App requires internet connectivity for initial profile creation
- Cached profile allows offline access to existing readings (UserDefaults persistence)
- BAFE downtime blocks new user onboarding — template interpretation serves as degraded fallback
- API response mapping (BAFEResponseMapper) must handle partial failures gracefully
