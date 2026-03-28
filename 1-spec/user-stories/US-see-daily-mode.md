# US-see-daily-mode: See Daily Pulse or Trace

**As a** end user, **I want** to see exactly one daily insight (Pulse or Trace) when I open the app, **so that** I start my day with a personalized, data-driven reflection.

**Status**: Approved
**Priority**: Must-have
**Source stakeholder**: [STK-end-user](../stakeholders.md)
**Related goal**: [GOAL-daily-personal-insight](../goals/GOAL-daily-personal-insight.md)

## Acceptance Criteria

- Given my Harmony Index H < 0.50, when I open the Atlas tab, then I see "DAY-PULSE" with concentric rings and a poetic 2-3 sentence text
- Given my Harmony Index H ≥ 0.50, when I open the Atlas tab, then I see "DAY-TRACE" with Lissajous curves and a direct, action-oriented 2-3 sentence text
- Given a geomagnetic storm (Kp ≥ 5) and intensity > 0.7, then the Trace text includes one extra sentence
- Given it is the same calendar day, when I reopen the app, then the same mode and text are shown (cached)

## Derived Requirements

- [REQ-USA-no-astro-jargon](../requirements/REQ-USA-no-astro-jargon.md), [REQ-F-cosmic-weather](../requirements/REQ-F-cosmic-weather.md), [REQ-F-day-mode-selection](../requirements/REQ-F-day-mode-selection.md)
