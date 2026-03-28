# US-language-switch: Switch Language (DE/EN)

**As a** end user, **I want** to switch between German and English at any time, **so that** I can use the app in my preferred language.

**Status**: Approved
**Priority**: Must-have
**Source stakeholder**: [STK-end-user](../stakeholders.md)
**Related goal**: [GOAL-app-store-launch](../goals/GOAL-app-store-launch.md)

## Acceptance Criteria

- Given I am on the splash screen, when I choose "Deutsch" or "English", then the app language is set accordingly
- Given I am in the app, when all user-facing text is rendered, then it matches the selected language (labels, Day Pulse text, companion traits, quiz content, detail sheet descriptions)
- Given I restart the app, then my language preference is preserved
- Given I switch language, then the Day Pulse/Trace text regenerates in the new language

## Derived Requirements

- [REQ-F-bilingual](../requirements/REQ-F-bilingual.md)
