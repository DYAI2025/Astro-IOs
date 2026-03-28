# REQ-F-day-mode-selection: Day Mode Selection via Harmony Index

**Type**: Functional
**Status**: Draft
**Priority**: Must-have
**Source story**: [US-see-daily-mode](../user-stories/US-see-daily-mode.md)

## Description

The daily mode (Pulse or Trace) is determined by the Harmony Index H, computed as cosine similarity between Western and BaZi Wu-Xing vectors. H ≥ 0.50 = Trace, H < 0.50 = Pulse. Intensity = |H - 0.45| / 0.55.

## Acceptance Criteria

- [ ] DayHarmonicEngine.fromProfile() computes H from CosmicProfile
- [ ] Threshold constant is 0.50 (single documented value)
- [ ] Same profile always produces same H (deterministic)
- [ ] DayModeCard shows exactly one mode, never both
