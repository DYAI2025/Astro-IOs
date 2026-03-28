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
| [GOAL-fusion-reading](goals/GOAL-fusion-reading.md) | Must-have | Draft | Unified Fusion Astrology reading from Western + BaZi + Wu-Xing |
| [GOAL-daily-personal-insight](goals/GOAL-daily-personal-insight.md) | Must-have | Draft | Data-driven Day Pulse / Day Trace daily insight with cosmic weather |
| [GOAL-ai-companions](goals/GOAL-ai-companions.md) | Must-have | Draft | Two AI companions (Levi & Eve) with natal chart context |
| [GOAL-self-discovery-quizzes](goals/GOAL-self-discovery-quizzes.md) | Should-have | Draft | Personality quizzes feeding into dynamic Fusion profile |
| [GOAL-app-store-launch](goals/GOAL-app-store-launch.md) | Must-have | Draft | Polished App Store-ready iOS app |
| [GOAL-mathematical-transparency](goals/GOAL-mathematical-transparency.md) | Must-have | Draft | Every calculation traceable to documented formulas |

---

## User Stories Index

| File | Role | Priority | Status | Summary |
|------|------|----------|--------|---------|
| [US-enter-birth-data](user-stories/US-enter-birth-data.md) | End User | Must-have | Draft | Enter birth data and receive Fusion profile |
| [US-view-sun-sign-detail](user-stories/US-view-sun-sign-detail.md) | End User | Must-have | Draft | Tap sun sign → detail with moon + ascendant |
| [US-view-year-animal-detail](user-stories/US-view-year-animal-detail.md) | End User | Must-have | Draft | Tap year animal → BaZi pillars detail |
| [US-view-element-detail](user-stories/US-view-element-detail.md) | End User | Must-have | Draft | Tap element → Wu-Xing balance detail |
| [US-see-daily-mode](user-stories/US-see-daily-mode.md) | End User | Must-have | Draft | See Day Pulse or Day Trace on app open |
| [US-choose-companion](user-stories/US-choose-companion.md) | End User | Must-have | Draft | Choose between Levi and Eve |
| [US-converse-with-companion](user-stories/US-converse-with-companion.md) | End User | Must-have | Draft | Chat with companion about chart and life |
| [US-play-quiz](user-stories/US-play-quiz.md) | End User | Should-have | Draft | Play quiz and see result profile |
| [US-onboarding-flow](user-stories/US-onboarding-flow.md) | End User | Must-have | Draft | First-run splash → birth form → dashboard |
| [US-switch-theme](user-stories/US-switch-theme.md) | End User | Should-have | Draft | Toggle dark/light theme |

---

## Requirements Index

| File | Type | Priority | Status | Summary |
|------|------|----------|--------|---------|
<!-- Add rows as requirements are created. File column: [REQ-CLASS-kebab-name](requirements/REQ-CLASS-kebab-name.md) -->

---

## Assumptions Index

| File | Category | Status | Risk | Summary |
|------|----------|--------|------|---------|
<!-- Add rows as assumptions are created. File column: [ASM-kebab-name](assumptions/ASM-kebab-name.md) -->

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
