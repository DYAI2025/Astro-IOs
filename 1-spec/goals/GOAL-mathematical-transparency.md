# GOAL-mathematical-transparency: Mathematical Transparency

**Description**: Every astrological calculation and daily insight must be traceable to explicit formulas and data sources. Nothing is hallucinated or randomly generated. The Harmony Index, element vectors, Day Pulse/Trace selection, and profile scores all derive from documented mathematics. This is the philosophical core — "it works even though we disenchant it through mathematics."

**Status**: Draft

**Priority**: Must-have

**Source stakeholder**: [STK-product-owner](../stakeholders.md), [STK-end-user](../stakeholders.md)

## Success Criteria

- [ ] Harmony Index H uses cosine similarity between normalized Wu-Xing vectors (documented formula)
- [ ] Day mode threshold (H ≥ 0.50 = Trace) is a single, documented constant
- [ ] Intensity = |H - 0.45| / 0.55 — documented, not approximated
- [ ] Wu-Xing vectors derived from explicit zodiac-element and pillar-element mappings
- [ ] BAFE API calculations use standard astronomical ephemeris (Swiss Ephemeris)
- [ ] Quiz scoring uses dimension aggregation with normalization 0-100 (documented)
- [ ] No LLM-generated numbers used as if they were calculations

## Related Artifacts

- User stories: _none yet_
- Requirements: _none yet_
- Constraints: [CON-bafe-dependency](../constraints/CON-bafe-dependency.md)
