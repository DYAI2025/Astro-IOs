# Gap Resolution Plan — SDLC Spec Phase

## Goal
Resolve all 7 open gaps (2 Critical, 4 Important) so the Specification phase is clean for Design gate.

## Tasks

- [x] **C1a: Requirements from User Stories** — Derive REQ-F for each of the 11 user stories from their acceptance criteria. ~15 REQ-F files. → Verify: every US has ≥1 linked REQ in `Derived Requirements`
- [x] **C1b: Non-functional Requirements** — Add REQ-PERF (API response <3s), REQ-USA (bilingual DE/EN, no jargon), REQ-REL (offline cached profile, BAFE fallback). → Verify: ≥3 non-functional REQs exist
- [x] **C3: Constraint-derived Requirements** — REQ-SEC-no-keys-in-binary (from CON-no-api-key-client), REQ-USA-no-astro-jargon (from CON-no-esoteric-language), REQ-REL-bafe-fallback (from CON-bafe-dependency). → Verify: each CON with testable obligation has ≥1 REQ, bidirectional links set
- [x] **I1: Assumptions** — Create ASM-bafe-availability, ASM-elevenlabs-pricing, ASM-noaa-public-access with risk + verification plan. → Verify: 3 ASM files in assumptions/
- [x] **I2: US-offline-access** — "As end user, I want my profile available offline after first calculation." Link to GOAL-fusion-reading. → Verify: file exists, goal backlink updated
- [x] **I3: US-language-switch** — "As end user, I want to switch between DE and EN." Link to GOAL-app-store-launch. → Verify: file exists, goal backlink updated
- [x] **I4: US-verify-transparency** — "As end user, I want to know my reading is based on math, not randomness." Link to GOAL-mathematical-transparency. → Verify: file exists, goal has unique story
- [x] **Sync indexes** — Update all index tables in CLAUDE.spec.md + Current State in SDLC.md. → Verify: `grep _none.yet_ goals/*.md` returns 0
- [ ] **Fresh gap analysis** — Re-run to confirm 0 Critical, 0 Important. → Verify: recorded in SDLC.md Current State

## Done When
- [ ] 0 Critical gaps remaining
- [ ] 0 Important gaps remaining
- [ ] Every user story has ≥1 requirement
- [ ] Every constraint with testable obligation has ≥1 requirement
- [ ] Gap analysis recorded as fresh in SDLC.md
