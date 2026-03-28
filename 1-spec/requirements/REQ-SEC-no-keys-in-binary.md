# REQ-SEC-no-keys-in-binary: No Secret Keys in Client Binary

**Type**: Security
**Status**: Draft
**Priority**: Must-have
**Source**: [CON-no-api-key-client](../constraints/CON-no-api-key-client.md)
**Related story**: [US-enter-birth-data](../user-stories/US-enter-birth-data.md)

## Description

The iOS binary must not contain any API secret keys (Gemini, ElevenLabs API key, Supabase service role, Stripe). All authenticated API calls must be proxied through the server.

## Acceptance Criteria

- [ ] `strings bazodiac.app/bazodiac | grep -i "sk_\|key_\|secret"` returns no matches
- [ ] BAFE/Gemini calls route through Railway proxy (`/api/calculate/*`, `/api/interpret`)
- [ ] Only the Supabase anon key (read-only, RLS-protected) is present in the binary
- [ ] ElevenLabs uses public WebSocket agent endpoints (no API key needed)
