# CON-no-api-key-client: No API Keys in Client Binary

**Category**: Technical

**Status**: Active

**Source stakeholder**: [STK-developer](../stakeholders.md)

## Description

No API keys (Gemini, ElevenLabs, Supabase service role, Stripe) may be stored in the iOS client binary. All authenticated API calls must be proxied through the server (server.mjs / Railway).

## Rationale

iOS binaries can be decompiled. Embedded keys are trivially extractable and would expose billing-sensitive services to abuse.

## Impact

## Derived Requirements
- [REQ-SEC-no-keys-in-binary](../requirements/REQ-SEC-no-keys-in-binary.md)

- BAFE and Gemini calls go through `/api/calculate/*` and `/api/interpret` server proxy
- ElevenLabs uses public agent WebSocket endpoints (no key needed for Convai agents)
- Supabase anon key (read-only, RLS-protected) is the only key in the client
- Server must remain deployed and reachable for core functionality
