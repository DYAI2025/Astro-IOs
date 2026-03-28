# REQ-F-cosmic-weather: Live Cosmic Weather Integration

**Type**: Functional
**Status**: Draft
**Priority**: Must-have
**Source story**: [US-see-daily-mode](../user-stories/US-see-daily-mode.md)

## Description

Day Pulse/Trace incorporates live geomagnetic Kp-Index from NOAA SWPC and computed moon phase. Kp ≥ 5 with intensity > 0.7 triggers an extra sentence in Trace mode.

## Acceptance Criteria

- [ ] Kp-Index fetched from NOAA SWPC JSON endpoint (15-min cache)
- [ ] Moon phase computed from synodic month (no API dependency)
- [ ] Magnetic storm extra sentence only when Kp ≥ 5 AND intensity > 0.7 AND mode is Trace
- [ ] Fallback: Kp defaults to 0 if NOAA unreachable
