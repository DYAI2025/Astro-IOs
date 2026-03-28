# REQ-USA-no-astro-jargon: No Astrological Jargon in User-Facing Text

**Type**: Usability
**Status**: Draft
**Priority**: Must-have
**Source**: [CON-no-esoteric-language](../constraints/CON-no-esoteric-language.md)
**Related story**: [US-see-daily-mode](../user-stories/US-see-daily-mode.md), [US-verify-transparency](../user-stories/US-verify-transparency.md)

## Description

All user-facing text (Day Pulse/Trace, detail sheets, quiz results, companion greetings) must use poetic realism language. No planetary mechanics, no "Mercury retrograde", no esoteric explanations. The word "because" followed by a planetary explanation is forbidden.

## Acceptance Criteria

- [ ] Day Pulse/Trace texts pass manual review: no planet names, no aspect names, no house numbers in visible text
- [ ] Detail sheet descriptions reference personality qualities, not planetary positions
- [ ] AI companion system prompts explicitly instruct avoidance of astro jargon
- [ ] Internal code/models may use standard astrology terms (developer-facing only)
