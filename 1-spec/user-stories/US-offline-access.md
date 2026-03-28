# US-offline-access: Offline Access to Profile

**As a** end user, **I want** my Fusion profile to be available offline after the first calculation, **so that** I can view my chart, Day Pulse, and detail sheets without internet.

**Status**: Draft
**Priority**: Must-have
**Source stakeholder**: [STK-end-user](../stakeholders.md)
**Related goal**: [GOAL-fusion-reading](../goals/GOAL-fusion-reading.md)

## Acceptance Criteria

- Given I have completed my first calculation, when I open the app without internet, then I see my cached profile on the Atlas dashboard
- Given I am offline, when I tap a detail tile (sun sign, year animal, element), then the detail sheet opens with cached data
- Given I am offline, when I view Day Pulse/Trace, then the text from the last fetch is displayed
- Given I am offline, when I try to recalculate, then I see a message that internet is required

## Derived Requirements

- [REQ-F-profile-persistence](../requirements/REQ-F-profile-persistence.md), [REQ-REL-bafe-fallback](../requirements/REQ-REL-bafe-fallback.md)
