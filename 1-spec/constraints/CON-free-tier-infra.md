# CON-free-tier-infra: Free/Low-Cost Infrastructure

**Category**: Business

**Status**: Active

**Source stakeholder**: [STK-product-owner](../stakeholders.md)

## Description

Backend infrastructure must run on free or low-cost tiers until revenue justifies scaling. Current stack: Railway (server proxy), Supabase free tier (auth + database), NOAA public API (cosmic weather), Google Fonts CDN.

## Rationale

No external funding. Operational costs must remain near zero during development and early launch. Revenue model (subscriptions/IAP) will fund scaling once validated.

## Impact

- Railway free tier: 500 hours/month — sufficient for proxy server
- Supabase free tier: 500MB database, 50K auth users, 2GB storage
- NOAA SWPC: public, no key, rate-limited but sufficient (15-min cache)
- ElevenLabs: usage-based pricing — AI companion conversations cost per minute
- Gemini API: server-side proxy with rate limiting to control costs
- No dedicated CDN or custom domain infrastructure initially
