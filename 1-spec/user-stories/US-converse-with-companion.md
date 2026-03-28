# US-converse-with-companion: Converse with AI Companion

**As a** end user, **I want** to chat with my chosen companion about my chart and life questions, **so that** I get personalized guidance in a conversational format.

**Status**: Draft
**Priority**: Must-have
**Source stakeholder**: [STK-end-user](../stakeholders.md)
**Related goal**: [GOAL-ai-companions](../goals/GOAL-ai-companions.md)

## Acceptance Criteria

- Given I tap "Start" on a companion, then a WebSocket connects to ElevenLabs with my natal chart as context
- Given the session is active, when I type a message and tap send, then the companion responds with chart-aware text
- Given the WebSocket disconnects, when I type a message, then a local fallback response is shown
- Given I tap "End", then the session closes and the waveform stops

## Derived Requirements

- [REQ-F-companion-websocket](../requirements/REQ-F-companion-websocket.md)
