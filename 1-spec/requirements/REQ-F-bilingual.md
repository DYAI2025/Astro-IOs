# REQ-F-bilingual: Bilingual Support (DE/EN)

**Type**: Functional
**Status**: Approved
**Priority**: Must-have
**Source story**: [US-language-switch](../user-stories/US-language-switch.md)

## Description

All user-facing text supports German and English. Language is selected on splash screen and persisted. Switching language regenerates dynamic content.

## Acceptance Criteria

- [ ] Language stored in UserDefaults, survives restart
- [ ] Tab labels, section headers, companion traits, info hints switch with language
- [ ] DayModeTextGenerator produces DE or EN text based on store.language
- [ ] Detail sheet descriptions are language-appropriate
