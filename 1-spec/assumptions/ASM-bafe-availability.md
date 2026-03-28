# ASM-bafe-availability: BAFE API Remains Available

**Category**: Technical
**Status**: Unverified
**Risk if wrong**: High — new user onboarding completely blocked; no local calculation fallback exists
**Source stakeholder**: [STK-developer](../stakeholders.md)

## Assumption

The BAFE API (hosted on Vercel/Railway) will remain available with acceptable latency (<3s) and will not be deprecated or rate-limited below the app's usage requirements during the launch phase.

## Verification Plan

- Monitor BAFE uptime weekly via simple health check (GET /api/calculate/western with test payload)
- Set up alerting if response time exceeds 5s or error rate exceeds 5%
- Maintain template-based interpretation fallback for degraded operation

## Dependent Artifacts

- [CON-bafe-dependency](../constraints/CON-bafe-dependency.md)
- [GOAL-fusion-reading](../goals/GOAL-fusion-reading.md)
- [US-enter-birth-data](../user-stories/US-enter-birth-data.md)
