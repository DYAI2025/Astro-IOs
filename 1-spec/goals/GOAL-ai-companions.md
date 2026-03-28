# GOAL-ai-companions: Two Distinct AI Companions

**Description**: Offer two AI voice companions — Levi (analytical, clear, profound) and Eve (direct, ironic, honest, close) — that converse with the user about their natal chart, daily energy, and life questions. Both share the same Fusion Astrology knowledge but differ in personality and communication style.

**Status**: Draft

**Priority**: Must-have

**Source stakeholder**: [STK-end-user](../stakeholders.md), [STK-ai-companion](../stakeholders.md)

## Success Criteria

- [ ] Both agents connect via ElevenLabs Conversational AI WebSocket
- [ ] User's full natal chart (Western + BaZi + Wu-Xing) is sent as system context on session start
- [ ] Levi traits: analytical, clear, profound — dark blue/gold visual identity
- [ ] Eve traits: direct, ironic, honest, close — violet/silver visual identity
- [ ] Agent selection via Companions tab with distinct personality cards
- [ ] Fallback to local preset responses when WebSocket unavailable
- [ ] Bilingual: DE and EN based on language setting

## Related Artifacts

- User stories: _none yet_
- Requirements: _none yet_
- Constraints: [CON-no-api-key-client](../constraints/CON-no-api-key-client.md), [CON-no-esoteric-language](../constraints/CON-no-esoteric-language.md)
