# Mobile Go-Live Readiness Plan (iOS + Android)

## 1) Scope and Objective
This plan defines the **hard requirements** to launch Bazodiac Mobile to production on iOS and Android with a stable happy path:

**Install → Open App → Sign up / Sign in → Onboarding → Reading persisted → Dashboard usable → Upgrade flow works**.

It is split into sequential go-live gates with explicit acceptance criteria.

---

## 2) Non-Negotiable Release Requirements (Must-Have)

## R-001 Version Governance
- App must enforce `min_supported_versions` from `/api/mobile/bootstrap`.
- Outdated clients must be hard-blocked behind a force-update screen.
- Decision must be platform-specific (`ios` / `android`).

**Acceptance criteria**
- If app version < required version: no auth, onboarding, or dashboard access.
- Update CTA deep-links to App Store / Play Store URLs from config.
- Gate is testable with local version override and mocked bootstrap payload.

## R-002 Auth and Session Integrity
- Supabase auth must persist across app restarts.
- Logout must invalidate local session and protected requests.
- Signup/signin errors must be surfaced with actionable text.

**Acceptance criteria**
- Restart app after signin keeps user authenticated.
- Protected endpoints return 401 without token, succeed with token.
- No silent auth failures in logs.

## R-003 Happy Path Data Persistence
- Onboarding must validate birth data and persist profile + chart records.
- Failure states must not leave user in undefined app state.

**Acceptance criteria**
- Successful onboarding creates records in `astro_profiles`, `birth_data`, `natal_charts`.
- User lands on dashboard after persist.
- On transient API failure, user gets clear retry path.

## R-004 Mobile Checkout Return Safety
- Checkout return URLs/schemes must be validated server-side.
- Mobile deep link return must refresh user tier status.

**Acceptance criteria**
- Invalid return URL is rejected server-side.
- Valid success return updates tier in app without reinstall/restart.

## R-005 Crash + Funnel Observability
- Crash reporting must be enabled in release builds.
- Funnel telemetry must track conversion steps.

**Acceptance criteria**
- Events: app_open, auth_success, onboarding_submit, onboarding_success, checkout_open, checkout_success, paywall_view.
- Release monitoring dashboard with alerting thresholds exists.

## R-006 Store Compliance and Privacy
- iOS Privacy Nutrition + Android Data Safety entries must match actual data usage.
- Legal screens (privacy/terms) must be reachable in-app.

**Acceptance criteria**
- Compliance checklist signed off by engineering + product.
- No undeclared tracking/data collection.

---

## 3) Go-Live Gates

## Gate A — Engineering Baseline
1. ✅ Typecheck/lint pass for web + mobile.
2. ✅ Build artifacts generated.
3. ✅ Version hard gate implemented.
4. ✅ Bootstrap fallback behavior documented.

**Exit criterion**: zero blocker bugs in P0 scope.

## Gate B — E2E Functional QA
1. Signup and signin on iOS + Android.
2. Full onboarding with city lookup and manual coordinates.
3. Dashboard modules load (Fu Ring, Wissen, Voice flags).
4. Checkout launch + return handling.

**Exit criterion**: 100% pass of critical path matrix.

## Gate C — Resilience and Security
1. Offline/slow network handling.
2. API timeout and retry behavior.
3. Token handling and secure storage validation.
4. Server allowlist validation for mobile return URLs.

**Exit criterion**: no critical/high findings open.

## Gate D — Store Readiness
1. Metadata, screenshots, age rating, support URL.
2. Privacy forms complete and verified.
3. Production signing profiles and rollout strategy defined.

**Exit criterion**: build submitted and accepted in both stores.

---

## 4) Detailed Task Backlog (Ordered)

## T-001 (P0) Enforce minimum app version (force-update gate)
**Why first:** protects backend contracts and prevents unsupported client behavior.

**Requirements**
- Parse and compare semantic versions safely.
- Read platform-specific min versions from bootstrap response.
- Render blocking UI when version is below required minimum.
- Add optional env-configurable store URLs for update CTA.

**Deliverables**
- `apps/mobile/src/lib/versionGate.ts`
- `apps/mobile/src/screens/ForceUpdateScreen.tsx`
- `apps/mobile/App.tsx` integration
- `apps/mobile/src/lib/config.ts` store URL config

---

## T-002 (P0) Add robust E2E happy-path script/checklist
- Device matrix with iOS/Android versions.
- Auth + onboarding + persistence + dashboard + checkout return.
- Include expected DB side effects and API logs.

## T-003 (P0) Production observability baseline
- Error reporter integration.
- Funnel event schema and dashboards.
- Alert routing (crash-free sessions, checkout conversion anomalies).

## T-004 (P1) Compliance package hardening
- Data inventory and legal mapping.
- In-app privacy links and consent strategy.
- Store listing compliance review.

## T-005 (P1) Release process automation
- CI lanes for mobile typecheck + build smoke.
- Version bump + changelog + rollout checklist automation.

---

## 5) QA Matrix (Critical Path)

| Flow | iOS | Android | Pass criteria |
|---|---|---|---|
| Auth sign up / sign in | Required | Required | successful session + no crash |
| Onboarding + geocode + manual fallback | Required | Required | profile persisted and dashboard shown |
| Dashboard + feature flags | Required | Required | disabled features hidden/graceful |
| Checkout open + return deep link | Required | Required | tier refresh after success |
| Force-update gate | Required | Required | blocks below min version |

---

## 6) Ownership and SLA
- **Mobile lead:** T-001, T-002, T-005
- **Backend lead:** checkout return allowlist + bootstrap contracts
- **Product/Operations:** T-004 + store artifacts
- **SLA:** P0 issues triaged < 24h, fixed < 72h

---

## 7) Definition of Done (Launch)
Launch is approved only when:
1. All P0 tasks completed and validated.
2. Critical path matrix passes on both platforms.
3. Observability and compliance evidence attached to release notes.
4. Rollback plan documented and tested.
