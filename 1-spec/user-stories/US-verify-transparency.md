# US-verify-transparency: Trust Through Mathematical Transparency

**As a** end user, **I want** to know that my reading is based on traceable mathematics rather than random generation, **so that** I trust the app as a mental model framework and not esoteric fortune-telling.

**Status**: Approved
**Priority**: Must-have
**Source stakeholder**: [STK-end-user](../stakeholders.md)
**Related goal**: [GOAL-mathematical-transparency](../goals/GOAL-mathematical-transparency.md)

## Acceptance Criteria

- Given I view my profile, when element balances are shown, then the percentages are derived from explicit Wu-Xing vector normalization (not random)
- Given I see Day Pulse or Trace, when the mode label is shown, then it was determined by the Harmony Index formula (H = cosine similarity, threshold 0.50)
- Given I complete a quiz, when scores are displayed, then they were computed by dimension aggregation and normalization 0-100
- Given two users enter the same birth data, then they receive identical Fusion profiles (deterministic)

## Derived Requirements

- [REQ-USA-no-astro-jargon](../requirements/REQ-USA-no-astro-jargon.md)
