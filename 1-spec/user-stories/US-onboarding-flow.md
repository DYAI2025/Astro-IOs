# US-onboarding-flow: First-Run Onboarding

**As a** end user, **I want** a smooth first-run experience from splash to my first reading, **so that** I understand the app's value within 2 minutes.

**Status**: Draft
**Priority**: Must-have
**Source stakeholder**: [STK-end-user](../stakeholders.md)
**Related goal**: [GOAL-app-store-launch](../goals/GOAL-app-store-launch.md)

## Acceptance Criteria

- Given I launch the app for the first time, then I see the cinematic splash with zodiac scroll animation
- Given I choose a language (DE/EN), then I am taken to the birth data form
- Given I submit valid birth data, then a loading state shows while the profile is calculated
- Given the calculation completes, then I am taken to the Atlas dashboard with my Fusion profile
- Given I relaunch the app, then I skip the splash and go directly to the dashboard (cached profile)

## Derived Requirements

- [REQ-F-bilingual](../requirements/REQ-F-bilingual.md), [REQ-F-profile-persistence](../requirements/REQ-F-profile-persistence.md)
