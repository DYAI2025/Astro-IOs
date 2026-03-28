# ASM-elevenlabs-pricing: ElevenLabs Pricing Remains Feasible

**Category**: Business
**Status**: Unverified
**Risk if wrong**: Medium — AI companions become too expensive to offer; would need to limit conversation minutes or switch to alternative TTS/LLM
**Source stakeholder**: [STK-product-owner](../stakeholders.md)

## Assumption

ElevenLabs Conversational AI pricing will remain within feasible bounds for a bootstrapped product during the launch phase. Current estimate: ~$0.01-0.03 per conversation minute.

## Verification Plan

- Track per-user conversation minutes in first 30 days post-launch
- Set budget alert at $50/month total ElevenLabs spend
- Identify fallback: local LLM (Ollama) or server-side Gemini text-only companion

## Dependent Artifacts

- [GOAL-ai-companions](../goals/GOAL-ai-companions.md)
- [CON-free-tier-infra](../constraints/CON-free-tier-infra.md)
