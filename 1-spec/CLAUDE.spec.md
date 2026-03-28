Phase-specific instructions for the **Specification** phase. Extends [../CLAUDE.md](../CLAUDE.md).

## Purpose

This phase defines **what** we're building and **why**. Focus on clarity, measurability, and alignment with stakeholder needs.

## Phase artifacts

| Artifact | Location | Purpose |
|----------|----------|---------|
| Stakeholders | [`stakeholders.md`](stakeholders.md) | Roles with interests and influence |
| Goals | [`goals/`](goals/) | High-level outcomes |
| User Stories | [`user-stories/`](user-stories/) | User-facing capabilities |
| Requirements | [`requirements/`](requirements/) | Testable system requirements |
| Assumptions | [`assumptions/`](assumptions/) | Beliefs taken as true but not verified |
| Constraints | [`constraints/`](constraints/) | Hard limits on design and implementation |

---

## AI Guidelines

### Per-artifact guidance

**Stakeholders**: ask who uses, funds, operates, or is affected by the system. Record influence level honestly — it drives conflict resolution. Add entries to [`stakeholders.md`](stakeholders.md).

**Goals**: decompose vague ideas into concrete, measurable outcomes. Use MoSCoW priority consistently.
Status lifecycle: `Draft → Approved → Achieved → Deprecated`. Only a human can approve or deprecate. The agent marks `Achieved` when all success criteria are met (linked requirements implemented).

**User Stories**: use "As a [role], I want [capability], so that [benefit]." The role must be an existing stakeholder ID. Acceptance criteria at the story level are high-level; detailed criteria live in requirements.
Status lifecycle: `Draft → Approved → Implemented → Deprecated`. Only a human can approve or deprecate. The agent marks `Implemented` when all linked requirements reach `Implemented`.

**Requirements**: use clear, testable language (not "should be fast" — use "response time < 200ms at p95"). Choose the correct requirement class.
Requirement classes: `REQ-F` Functional, `REQ-PERF` Performance, `REQ-SEC` Security, `REQ-REL` Reliability, `REQ-USA` Usability, `REQ-MNT` Maintainability, `REQ-PORT` Portability, `REQ-SCA` Scalability, `REQ-COMP` Compliance.
Status lifecycle: `Draft → Approved → Implemented → Deprecated`. Only a human can approve or deprecate. The agent marks `Implemented` when all linked tasks reach Done.

**Assumptions**: always record the risk level (what happens if wrong?) and a verification plan when possible.
Status lifecycle: `Unverified → Verified | Invalidated`. The agent marks `Verified` when the verification plan confirms the assumption. Only a human can mark `Invalidated` (triggers impact analysis on dependent artifacts).

**Constraints**: consider technical (platforms, dependencies), business (budget, timeline, team size), and operational (hosting, compliance) categories.
Status lifecycle: `Active → Lifted`. Only a human can lift a constraint.

### Conflict resolution

A conflict exists when two or more requirements cannot both be satisfied as stated.

**Never resolve a conflict silently.** Always surface it before acting.

1. **Identify**: note conflicting requirement IDs, source stakeholders, influence levels, and why they are incompatible.
2. **Ask the user**: present what makes them incompatible, stakeholders and influence levels, two or more resolution options, and a recommended option if one is clearly better.
3. **Wait for explicit approval** before modifying any file.
4. **Apply**: update affected requirement files and index rows. Update dependent user stories or goals if affected. Record a decision if the resolution imposes a recurring constraint.
5. **Verify**: no artifacts remain in a conflicting state after resolution.

### Assumption invalidation

When an assumption is found to be wrong or no longer holds:

1. **Identify impact**: list all artifacts (requirements, user stories, decisions) that depend on the invalidated assumption.
2. **Ask the user**: present the invalidated assumption, the affected artifacts, and proposed adjustments or alternatives.
3. **Wait for explicit approval** before modifying any file.
4. **Apply**: change the assumption's Status to `Invalidated`. Update or flag all dependent artifacts as directed.
5. **Verify**: no artifacts remain based on the invalidated assumption without acknowledgment.

### Artifact deprecation

When an artifact (goal, user story, requirement) is no longer relevant:

1. Propose deprecation to the user with rationale and downstream impact.
2. Wait for explicit approval.
3. Change Status to `Deprecated` in the artifact file. Update its index row.
4. Check for dependent artifacts — flag any that reference the deprecated item.

---

## Decisions Relevant to This Phase

| File | Title | Trigger |
|------|-------|---------|
<!-- Add rows as decisions are recorded. File column: [DEC-kebab-name](../decisions/DEC-kebab-name.md) -->

---

## Linking to Other Phases

- Goals, user stories, constraints, assumptions, and requirements are referenced in design documents (`2-design/`)
- Requirements determine the development tasks in `3-code/tasks.md`; each task references the requirements it fulfills
- Acceptance criteria inform test cases (`3-code/`)

---

## Goals Index

| File | Priority | Status | Summary |
|------|----------|--------|---------|
| [GOAL-fusion-reading](goals/GOAL-fusion-reading.md) | Must-have | Approved | Unified Fusion Astrology reading from Western + BaZi + Wu-Xing |
| [GOAL-daily-personal-insight](goals/GOAL-daily-personal-insight.md) | Must-have | Approved | Data-driven Day Pulse / Day Trace daily insight with cosmic weather |
| [GOAL-ai-companions](goals/GOAL-ai-companions.md) | Must-have | Approved | Two AI companions (Levi & Eve) with natal chart context |
| [GOAL-self-discovery-quizzes](goals/GOAL-self-discovery-quizzes.md) | Should-have | Approved | Personality quizzes feeding into dynamic Fusion profile |
| [GOAL-app-store-launch](goals/GOAL-app-store-launch.md) | Must-have | Approved | Polished App Store-ready iOS app |
| [GOAL-dynamic-signature](goals/GOAL-dynamic-signature.md) | Must-have | Approved | Personal dynamic visual signature driven by Fusion signal |
| [GOAL-mathematical-transparency](goals/GOAL-mathematical-transparency.md) | Must-have | Approved | Every calculation traceable to documented formulas |

---

## User Stories Index

| File | Role | Priority | Status | Summary |
|------|------|----------|--------|---------|
| [US-enter-birth-data](user-stories/US-enter-birth-data.md) | End User | Must-have | Approved | Enter birth data and receive Fusion profile |
| [US-view-sun-sign-detail](user-stories/US-view-sun-sign-detail.md) | End User | Must-have | Approved | Tap sun sign → detail with moon + ascendant |
| [US-view-year-animal-detail](user-stories/US-view-year-animal-detail.md) | End User | Must-have | Approved | Tap year animal → BaZi pillars detail |
| [US-view-element-detail](user-stories/US-view-element-detail.md) | End User | Must-have | Approved | Tap element → Wu-Xing balance detail |
| [US-see-daily-mode](user-stories/US-see-daily-mode.md) | End User | Must-have | Approved | See Day Pulse or Day Trace on app open |
| [US-choose-companion](user-stories/US-choose-companion.md) | End User | Must-have | Approved | Choose between Levi and Eve |
| [US-converse-with-companion](user-stories/US-converse-with-companion.md) | End User | Must-have | Approved | Chat with companion about chart and life |
| [US-play-quiz](user-stories/US-play-quiz.md) | End User | Should-have | Approved | Play quiz and see result profile |
| [US-onboarding-flow](user-stories/US-onboarding-flow.md) | End User | Must-have | Approved | First-run splash → birth form → dashboard |
| [US-switch-theme](user-stories/US-switch-theme.md) | End User | Should-have | Approved | Toggle dark/light theme |
| [US-view-signature](user-stories/US-view-signature.md) | End User | Must-have | Approved | View personal dynamic signature on Signatur tab |
| [US-offline-access](user-stories/US-offline-access.md) | End User | Must-have | Approved | Profile available offline after first calculation |
| [US-language-switch](user-stories/US-language-switch.md) | End User | Must-have | Approved | Switch between DE and EN |
| [US-verify-transparency](user-stories/US-verify-transparency.md) | End User | Must-have | Approved | Trust that reading is math-based, not random |

---

## Requirements Index

| File | Type | Priority | Status | Summary |
|------|------|----------|--------|---------|
| [REQ-SEC-no-keys-in-binary](requirements/REQ-SEC-no-keys-in-binary.md) | Security | Must-have | Approved | No secret keys in iOS binary |
| [REQ-USA-no-astro-jargon](requirements/REQ-USA-no-astro-jargon.md) | Usability | Must-have | Approved | No astrological jargon in user-facing text |
| [REQ-REL-bafe-fallback](requirements/REQ-REL-bafe-fallback.md) | Reliability | Must-have | Approved | Graceful BAFE failure with cached fallback |
| [REQ-F-geocoding](requirements/REQ-F-geocoding.md) | Functional | Must-have | Approved | Birth place autocomplete + lat/lon/tz resolution |
| [REQ-F-fusion-calculation](requirements/REQ-F-fusion-calculation.md) | Functional | Must-have | Approved | Parallel BAFE calls → CosmicProfile |
| [REQ-F-day-mode-selection](requirements/REQ-F-day-mode-selection.md) | Functional | Must-have | Approved | Pulse/Trace via Harmony Index H |
| [REQ-F-cosmic-weather](requirements/REQ-F-cosmic-weather.md) | Functional | Must-have | Approved | NOAA Kp-Index + moon phase integration |
| [REQ-F-companion-websocket](requirements/REQ-F-companion-websocket.md) | Functional | Must-have | Approved | ElevenLabs WebSocket for Levi & Eve |
| [REQ-F-quiz-scoring](requirements/REQ-F-quiz-scoring.md) | Functional | Should-have | Approved | Dimension scoring + profile matching |
| [REQ-F-profile-persistence](requirements/REQ-F-profile-persistence.md) | Functional | Must-have | Approved | UserDefaults JSON persistence |
| [REQ-F-bilingual](requirements/REQ-F-bilingual.md) | Functional | Must-have | Approved | DE/EN language support |
| [REQ-F-detail-sheets](requirements/REQ-F-detail-sheets.md) | Functional | Must-have | Approved | Tappable detail sheets for Cosmic Triad |
| [REQ-PERF-api-response](requirements/REQ-PERF-api-response.md) | Performance | Should-have | Approved | Full calculation within 5s |

---

## Assumptions Index

| File | Category | Status | Risk | Summary |
|------|----------|--------|------|---------|
| [ASM-bafe-availability](assumptions/ASM-bafe-availability.md) | Technical | Unverified | High | BAFE API remains available with <3s latency |
| [ASM-elevenlabs-pricing](assumptions/ASM-elevenlabs-pricing.md) | Business | Unverified | Medium | ElevenLabs per-minute pricing stays feasible |
| [ASM-noaa-public-access](assumptions/ASM-noaa-public-access.md) | Technical | Unverified | Low | NOAA SWPC API stays public, no key needed |

---

## Constraints Index

| File | Category | Status | Summary |
|------|----------|--------|---------|
| [CON-ios-only](constraints/CON-ios-only.md) | Technical | Active | MVP targets iOS 26.2+ only; no Android/web parity for launch |
| [CON-no-api-key-client](constraints/CON-no-api-key-client.md) | Technical | Active | No API keys in client binary; all sensitive calls proxied through server |
| [CON-bafe-dependency](constraints/CON-bafe-dependency.md) | Technical | Active | All astrology calculations depend on external BAFE API; no local fallback |
| [CON-solo-founder](constraints/CON-solo-founder.md) | Business | Active | Single founder; AI agents do bulk of implementation |
| [CON-free-tier-infra](constraints/CON-free-tier-infra.md) | Business | Active | Infrastructure must run on free/low-cost tiers until revenue |
| [CON-no-esoteric-language](constraints/CON-no-esoteric-language.md) | Operational | Active | No astro jargon in user-facing text; poetic realism only |
