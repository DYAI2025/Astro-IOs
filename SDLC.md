## Language Policy

**All AI outputs must be in English**, regardless of the language used in user prompts. This applies to code, comments, documentation, configuration files, commit messages, and response text.

---

## Project Overview

**Bazodiac** is the only astrology app that mathematically fuses Western Astrology, Chinese BaZi (Four Pillars of Destiny), and Wu-Xing (Five Elements) into a single, transparent Fusion Astrology system.

### What problem it solves

Traditional astrology apps offer isolated readings — a horoscope here, a zodiac profile there. Bazodiac starts with a multi-dimensional astrological model and refines it through real-time cosmic weather events (geomagnetic storms, lunar phases, planetary transits), where each user reacts differently based on their unique natal constellation. Instead of explaining this complexity through numbers and tables, the app communicates it intuitively through a personal, dynamic visual signature that evolves over time.

### Who it is for

Bazodiac targets users who do not follow esoteric belief systems but are looking for **mental models to interpret their own thinking and behavioral patterns**. It functions like a systemic constellation with archetypes and planets — or simply a placebo for the soul. It works even though we disenchant it through mathematics, and that is precisely where the magic lies.

### Core differentiators

1. **Fusion Astrology** — the only system that computes a unified signal from Western zodiac, BaZi pillars, and Wu-Xing element vectors using cosine similarity and weighted composition
2. **Mathematical transparency** — every calculation is traceable; the Harmony Index H, Day Pulse/Trace modes, and element balances are derived from explicit formulas, not hallucinated
3. **Dynamic personalization** — the user's profile evolves through quiz contributions, real-time cosmic weather (NOAA Kp-Index), and conversation data from AI companions
4. **Intuitive communication** — no astro jargon in user-facing text; poetic realism instead of planetary mechanics

### Tech Stack

- **Platform:** iOS 26.2+ (SwiftUI, Swift 5.9+)
- **Backend:** BAFE API (astrology engine), Gemini (AI interpretation), ElevenLabs (voice AI)
- **Data:** UserDefaults (local), Supabase (cloud — planned)
- **Architecture:** @Observable, MVVM, Environment-based theming

### Implemented Features

- Cinematic Splash → BirthForm (with geocoding) → Dashboard
- Day Pulse / Day Trace (data-driven via Harmony Index H, cosine similarity)
- Cosmic Triad tiles: Sun Sign · Year Animal · Dominant Element (tappable → detail sheets)
- Western Birth Chart (Canvas zodiac wheel with planets)
- BaZi Four Pillars with Day Master highlight
- Wu-Xing Pentagon with element balance bars
- 6 personality quizzes with scoring engine (62 questions, 29 profiles)
- Levi & Eve AI Companions (ElevenLabs WebSocket, agent cards with distinct personalities)
- Light/Dark "Astro Luxury" theme with Cormorant Garamond typography
- Live cosmic weather integration (NOAA SWPC Kp-Index, computed moon phases)

### Current State

The project is in **active development (Code phase)**. Specification complete (all artifacts Approved). Design complete (architecture, data model, API design). 2 components identified: ios-app, server-proxy. Implementation plan created (2026-03-28): 5 phases, 26 tasks covering all 7 approved goals. Next step: execute Phase 1 (E2E Validation) via `/SDLC-execute-next-task`. Core UI, service layer, and data models are implemented. Remaining work: end-to-end BAFE API live testing, Supabase authentication, 10 additional quizzes, AVFoundation voice recording for companions, and App Store preparation.

---

## Phase-Specific Instructions

Each phase directory contains a `CLAUDE.<phase>.md` file. When working in a phase:

1. Read the phase-specific instructions — they extend (not override) this file
2. Consult the decisions index in that phase file before starting work (for the Code phase, decisions indexes are in each component's `CLAUDE.component.md`, not in `CLAUDE.code.md`)
3. Work within the appropriate phase structure

| Phase | Directory | Focus |
|-------|-----------|-------|
| **Specification** | `1-spec/` | Define what to build and why |
| **Design** | `2-design/` | Define how to build it |
| **Code** | `3-code/` | Build it |
| **Deploy** | `4-deploy/` | Ship and operate it |

### Cross-Skill Artifact Procedures

Any modification to phase artifacts — whether performed inside a skill, during a free-prompt conversation, or as a side effect of any other task — must follow the authoritative procedures for that phase:

- **Specification artifacts** (`1-spec/`): follow the procedures in [`.claude/skills/SDLC-elicit/SKILL.md`](.claude/skills/SDLC-elicit/SKILL.md) — including traceability rules, status downgrade on modification, index synchronization, bidirectional link maintenance, and Current State tracking.
- **Design artifacts** (`2-design/`): follow the procedures in [`.claude/skills/SDLC-design/SKILL.md`](.claude/skills/SDLC-design/SKILL.md) — including downstream effect checks, decision recording triggers, requirement coverage verification, and Current State tracking.
- **Code phase task artifacts** (`3-code/tasks.md`): follow the procedures in [`.claude/skills/SDLC-implementation-plan/SKILL.md`](.claude/skills/SDLC-implementation-plan/SKILL.md) — including phased task grouping, traceability links, incremental deployability, and Current State tracking.

### Phase Gates

Before creating artifacts in the next phase, check these minimum preconditions. Gates are advisory — warn the user if not met, but proceed if they confirm.

| Transition | Preconditions |
|------------|---------------|
| Spec → Design | Stakeholders defined; at least one goal Approved; at least one requirement Approved; gap analysis recorded in Current State and fresh (not stale, no Critical gaps) |
| Design → Code | All design documents drafted (`architecture.md`, `data-model.md`, `api-design.md`); completeness assessment recorded in Current State and fresh (not stale, no Critical findings); components identified (per-component directories in `3-code/`) |

There is no gate between Code and Deploy. Deploy activities (deployments, runbooks, infrastructure setup) can happen at any time during the Code phase.

---

## Artifacts

All project knowledge is captured as structured markdown files alongside the source code. This gives AI agents the full context that human developers would normally carry in their heads or scattered across external tools, and creates a traceability chain from business goals to deployed code.

### Types and locations

| Prefix | Artifact | Location |
|--------|----------|----------|
| `GOAL` | Goals | `1-spec/goals/` |
| `US` | User Stories | `1-spec/user-stories/` |
| `REQ-CLASS` | Requirements | `1-spec/requirements/` |
| `ASM` | Assumptions | `1-spec/assumptions/` |
| `CON` | Constraints | `1-spec/constraints/` |
| `STK` | Stakeholders | `1-spec/stakeholders.md` (rows) |
| `TASK` | Tasks | `3-code/tasks.md` (rows) |
| `DEC` | Decisions | `decisions/` |

### Naming

All artifact IDs use the pattern `PREFIX-kebab-name` — a type prefix followed by a descriptive kebab-case name. The descriptive name **is** the unique identifier (e.g., `DEC-use-postgres`, `REQ-F-search-by-name`). There are no numeric sequences, to avoid ID collisions when working on parallel branches.

### Phase indexes

Every `CLAUDE.<phase>.md` file contains index tables listing the artifacts in that phase. Each index must include a **File column** with a relative link to the artifact file, so that AI agents can discover the file name and human reviewers can navigate easily.

---

## Graduated Safeguards

AI agents operate autonomously within development tasks. For project-level decisions, the scaffold defines three tiers:

| Tier | When | Agent behavior |
|------|------|----------------|
| **Always ask** | Conflict resolution, design gaps, decision deprecation/supersession, phase gate advancement | Stop, present options, wait for human approval |
| **Ask first time, then follow precedent** | Naming conventions, error handling patterns, test structure | Ask once, record the decision, apply consistently afterward |
| **Decide and record** | Routine implementation choices within established patterns | Decide autonomously, record in the appropriate artifact |

When spotting a related issue, potential improvement, or ambiguous situation during a task, **surface it to the user** instead of silently deciding to act or not act.

---

## Decisions

Decisions live in `decisions/`. Each decision has two files:

- **`DEC-kebab-name.md`** — the active record (context, decision, enforcement). Read during normal task execution.
- **`DEC-kebab-name.history.md`** — the trail (alternatives, reasoning, changelog). Read only when evaluating or changing a decision.

Each `CLAUDE.<phase>.md` contains a decisions index with trigger conditions. A decision may appear in multiple phase indexes.

### How to use decisions during tasks

1. Consult the decisions index in the current phase's `CLAUDE.<phase>.md`, or in a component-specific `CLAUDE.<component>.md` when working within a specific component.
2. Follow the File column link to read the relevant `DEC-*.md` file.
3. Apply its enforcement rules.

Do **not** modify `*.history.md` except to append to the changelog.

### Recording, deprecating, or superseding decisions

When a significant decision, pattern, or constraint emerges, record it as a new decision. For the recording procedure, as well as deprecation and supersession, see [`decisions/PROCEDURES.md`](decisions/PROCEDURES.md).

---

## After Making Changes

Evaluate whether to:

1. **Update this file** if project-wide patterns or architecture change significantly.
2. **Update phase-specific files** (`CLAUDE.<phase>.md`) if phase-specific patterns or conventions are established.
3. **Create new instruction files** if a workflow becomes complex enough to need dedicated guidance.

Proactively suggest these updates when relevant.
