# REQ-F-fusion-calculation: Fusion Profile Calculation via BAFE

**Type**: Functional
**Status**: Draft
**Priority**: Must-have
**Source story**: [US-enter-birth-data](../user-stories/US-enter-birth-data.md)

## Description

Submitting birth data triggers parallel BAFE API calls (bazi, western, wuxing, fusion) and maps responses to a CosmicProfile stored locally.

## Acceptance Criteria

- [ ] All 4 BAFE endpoints called in parallel (async let)
- [ ] BAFEResponseMapper produces valid WesternData, BaZiData, WuXingData
- [ ] CosmicProfile persisted in UserDefaults via PersistenceService
- [ ] Loading state shown during calculation; error state on failure
