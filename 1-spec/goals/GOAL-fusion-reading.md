# GOAL-fusion-reading: Unified Fusion Astrology Reading

**Description**: Deliver a single, unified Fusion Astrology reading that combines Western Astrology (zodiac signs, planets, houses), Chinese BaZi (Four Pillars of Destiny), and Wu-Xing (Five Elements) into one coherent profile for every user. This is the core differentiator — no other app fuses these three systems mathematically.

**Status**: Draft

**Priority**: Must-have

**Source stakeholder**: [STK-end-user](../stakeholders.md), [STK-product-owner](../stakeholders.md)

## Success Criteria

- [ ] User enters birth data (date, time, place) once and receives a complete Fusion profile
- [ ] Profile includes Western chart (sun, moon, ascendant, 10 planets, 12 houses), BaZi pillars (year, month, day, hour), and Wu-Xing element balance
- [ ] Harmony Index H is computed as cosine similarity between Western and BaZi Wu-Xing vectors
- [ ] All calculations are performed by BAFE API with results mapped to iOS models
- [ ] Profile is persisted locally and available offline after initial calculation

## Related Artifacts

- User stories: [US-enter-birth-data](../user-stories/US-enter-birth-data.md), [US-view-sun-sign-detail](../user-stories/US-view-sun-sign-detail.md), [US-view-year-animal-detail](../user-stories/US-view-year-animal-detail.md), [US-view-element-detail](../user-stories/US-view-element-detail.md), [US-offline-access](../user-stories/US-offline-access.md)
- Requirements: [REQ-F-fusion-calculation](../requirements/REQ-F-fusion-calculation.md), [REQ-F-geocoding](../requirements/REQ-F-geocoding.md), [REQ-F-profile-persistence](../requirements/REQ-F-profile-persistence.md), [REQ-F-detail-sheets](../requirements/REQ-F-detail-sheets.md), [REQ-REL-bafe-fallback](../requirements/REQ-REL-bafe-fallback.md)
- Constraints: [CON-bafe-dependency](../constraints/CON-bafe-dependency.md)
