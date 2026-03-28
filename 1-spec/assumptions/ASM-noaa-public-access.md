# ASM-noaa-public-access: NOAA SWPC API Remains Public

**Category**: Technical
**Status**: Unverified
**Risk if wrong**: Low — Day Pulse/Trace would lose cosmic weather layer but still function based on natal data alone; Kp-Index defaults to 0 (neutral)
**Source stakeholder**: [STK-developer](../stakeholders.md)

## Assumption

The NOAA Space Weather Prediction Center JSON API (https://services.swpc.noaa.gov/json/planetary_k_index_1m.json) will remain publicly accessible without API key or rate limiting.

## Verification Plan

- NOAA is a US government agency with a mandate for public data access — risk of removal is structurally low
- NASA DONKI serves as existing fallback (implemented in server.mjs)
- App gracefully defaults to Kp=0 if both sources fail

## Dependent Artifacts

- [GOAL-daily-personal-insight](../goals/GOAL-daily-personal-insight.md)
- [US-see-daily-mode](../user-stories/US-see-daily-mode.md)
