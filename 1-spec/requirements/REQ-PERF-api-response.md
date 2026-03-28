# REQ-PERF-api-response: API Response Time

**Type**: Performance
**Status**: Approved
**Priority**: Should-have
**Source story**: [US-enter-birth-data](../user-stories/US-enter-birth-data.md)

## Description

The complete Fusion profile calculation (4 parallel BAFE calls + Gemini interpretation) should complete within 5 seconds under normal network conditions.

## Acceptance Criteria

- [ ] Individual BAFE endpoint responds within 3s (timeout set to 20s as hard limit)
- [ ] Parallel execution ensures total time ≈ max(individual times), not sum
- [ ] Loading indicator shown immediately on submit
- [ ] Gemini interpretation failure does not block profile display (template fallback)
