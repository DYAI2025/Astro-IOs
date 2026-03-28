# GOAL-daily-personal-insight: Data-Driven Daily Personal Insight

**Description**: Provide a personalized daily insight every morning that fuses the user's natal chart with real-time cosmic weather (geomagnetic activity, moon phase). The insight is either a Day Pulse (calm, poetic, ~65-70% of days) or a Day Trace (charged, action-oriented, ~30-35% of days), determined by the Harmony Index — never both.

**Status**: Draft

**Priority**: Must-have

**Source stakeholder**: [STK-end-user](../stakeholders.md)

## Success Criteria

- [ ] Day mode (Pulse vs Trace) is computed from Harmony Index H (threshold 0.50)
- [ ] Live Kp-Index fetched from NOAA SWPC (15-min cache)
- [ ] Moon phase computed locally (synodic month calculation, no API)
- [ ] Text is 2-3 sentences, no astro jargon, poetic realism style
- [ ] Magnetic storm extra sentence only when Kp ≥ 5 AND intensity > 0.7
- [ ] Visual differs: Pulse shows concentric rings, Trace shows Lissajous curves
- [ ] Content refreshes daily, cached until next day

## Related Artifacts

- User stories: [US-see-daily-mode](../user-stories/US-see-daily-mode.md)
- Requirements: [REQ-F-day-mode-selection](../requirements/REQ-F-day-mode-selection.md), [REQ-F-cosmic-weather](../requirements/REQ-F-cosmic-weather.md)
- Constraints: [CON-no-esoteric-language](../constraints/CON-no-esoteric-language.md)
