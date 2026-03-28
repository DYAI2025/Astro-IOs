# US-enter-birth-data: Enter Birth Data

**As a** end user, **I want** to enter my birth date, time, and place once, **so that** the app can calculate my complete Fusion Astrology profile.

**Status**: Draft
**Priority**: Must-have
**Source stakeholder**: [STK-end-user](../stakeholders.md)
**Related goal**: [GOAL-fusion-reading](../goals/GOAL-fusion-reading.md)

## Acceptance Criteria

- Given I am on the birth form, when I enter name, date, time and select a place from autocomplete, then my coordinates and timezone are resolved
- Given I tap "Calculate", when the BAFE API responds, then I see my complete Fusion profile on the dashboard
- Given the API fails, when I tap "Calculate", then I see an error message and can retry

## Derived Requirements

- [REQ-F-fusion-calculation](../requirements/REQ-F-fusion-calculation.md), [REQ-SEC-no-keys-in-binary](../requirements/REQ-SEC-no-keys-in-binary.md), [REQ-PERF-api-response](../requirements/REQ-PERF-api-response.md), [REQ-REL-bafe-fallback](../requirements/REQ-REL-bafe-fallback.md), [REQ-F-geocoding](../requirements/REQ-F-geocoding.md)
