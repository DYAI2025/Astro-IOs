# Server Proxy

**Responsibility**: Express.js proxy server that routes iOS client requests to BAFE and Gemini APIs, adds server-side API keys, serves space weather data, and handles ElevenLabs tool webhooks.

**Technology**: Node.js / Express (`server.mjs`) / Deployed on Railway

## Interfaces

- HTTP ← iOS client: receives `/api/calculate/*`, `/api/interpret`, `/api/space-weather`
- HTTP → BAFE API: forwards astrology calculation requests with auth
- HTTP → Gemini API: forwards interpretation requests with API key
- HTTP → NOAA SWPC / NASA DONKI: space weather (with fallback chain)
- HTTP ← ElevenLabs: tool webhook for `/api/profile/:userId`

## Requirements Addressed

| File | Type | Priority | Summary |
|------|------|----------|---------|
| [REQ-SEC-no-keys-in-binary](../../1-spec/requirements/REQ-SEC-no-keys-in-binary.md) | Security | Must-have | Proxy holds API keys server-side |
| [REQ-REL-bafe-fallback](../../1-spec/requirements/REQ-REL-bafe-fallback.md) | Reliability | Must-have | NOAA→DONKI fallback chain |
| [REQ-PERF-api-response](../../1-spec/requirements/REQ-PERF-api-response.md) | Performance | Should-have | Proxy adds minimal latency |

## Relevant Decisions

| File | Title | Trigger |
|------|-------|---------|
<!-- No decisions recorded yet -->

## Source Code Location

`server.mjs` at repository root. Configuration via environment variables (Railway dashboard).
