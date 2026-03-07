import type { ContributionEvent, Marker, Tag } from '@/src/lib/lme/types';

// ═══════════════════════════════════════════════════════════════
// LOVE LANGUAGES
// ═══════════════════════════════════════════════════════════════

const LOVE_LANG_MARKERS: Record<string, string> = {
  touch:   'marker.love.physical_touch',
  words:   'marker.love.expression',
  time:    'marker.love.togetherness',
  gifts:   'marker.love.sensory_connection',
  service: 'marker.love.protective',
};

export function loveLangToEvent(
  scores: Record<string, number>,
  profileId: string,
): ContributionEvent {
  const maxScore = Math.max(...Object.values(scores), 1);
  const markers: Marker[] = [];

  for (const [dim, markerId] of Object.entries(LOVE_LANG_MARKERS)) {
    if (scores[dim] != null && scores[dim] > 0) {
      markers.push({
        id: markerId,
        weight: Math.min(scores[dim] / maxScore, 1),
        evidence: { confidence: 0.7, itemsAnswered: 12 },
      });
    }
  }

  // Sekundäre Marker: Intensität / Leidenschaft
  if (scores.touch > maxScore * 0.7) {
    markers.push({
      id: 'marker.love.passionate',
      weight: scores.touch / maxScore * 0.8,
      evidence: { confidence: 0.6 },
    });
  }

  return buildEvent('quiz.love_languages.v1', markers, [
    { id: `tag.archetype.${profileId}`, label: profileId, kind: 'archetype', weight: 0.8 },
  ]);
}

// ═══════════════════════════════════════════════════════════════
// KRAFTTIER
// ═══════════════════════════════════════════════════════════════

const KRAFTTIER_MARKERS: Record<string, Marker[]> = {
  wolf: [
    { id: 'marker.social.pack_loyalty',       weight: 0.82, evidence: { confidence: 0.75 } },
    { id: 'marker.instinct.primal_sense',     weight: 0.75, evidence: { confidence: 0.75 } },
    { id: 'marker.leadership.servant_leader', weight: 0.68, evidence: { confidence: 0.75 } },
  ],
  eagle: [
    { id: 'marker.cognition.analytical',      weight: 0.85, evidence: { confidence: 0.75 } },
    { id: 'marker.freedom.independence',      weight: 0.80, evidence: { confidence: 0.75 } },
    { id: 'marker.leadership.charisma',       weight: 0.60, evidence: { confidence: 0.75 } },
  ],
  bear: [
    { id: 'marker.instinct.primal_sense',     weight: 0.80, evidence: { confidence: 0.75 } },
    { id: 'marker.love.protective',           weight: 0.85, evidence: { confidence: 0.75 } },
    { id: 'marker.emotion.body_awareness',    weight: 0.70, evidence: { confidence: 0.75 } },
  ],
  fox: [
    { id: 'marker.cognition.analytical',      weight: 0.80, evidence: { confidence: 0.75 } },
    { id: 'marker.social.diplomacy',          weight: 0.75, evidence: { confidence: 0.75 } },
    { id: 'marker.instinct.gut_feeling',      weight: 0.70, evidence: { confidence: 0.75 } },
  ],
};

export function krafttierToEvent(animalId: string): ContributionEvent {
  const key = animalId.toLowerCase();
  const markers = KRAFTTIER_MARKERS[key] ?? [];
  const tag: Tag = { id: `tag.archetype.${key}`, label: animalId, kind: 'archetype', weight: 0.9 };
  return buildEvent('quiz.krafttier.v1', markers, [tag]);
}

// ═══════════════════════════════════════════════════════════════
// PERSONALITY (Big Five basiert)
// ═══════════════════════════════════════════════════════════════

const PERSONALITY_MARKERS: Record<string, string> = {
  openness:          'marker.social.openness',
  conscientiousness: 'marker.values.achievement',
  extraversion:      'marker.social.extroversion',
  agreeableness:     'marker.eq.empathy',
  neuroticism:       'marker.eq.stress_sensitivity',
};

export function personalityToEvent(
  scores: Record<string, number>,
): ContributionEvent {
  const markers: Marker[] = [];

  for (const [dim, markerId] of Object.entries(PERSONALITY_MARKERS)) {
    const score = scores[dim];
    if (score != null) {
      markers.push({
        id: markerId,
        weight: Math.min(score / 100, 1),
        evidence: { confidence: 0.8, itemsAnswered: 20 },
      });
    }
  }

  return buildEvent('quiz.personality.v1', markers, []);
}

// ═══════════════════════════════════════════════════════════════
// EQ (Emotionale Intelligenz)
// ═══════════════════════════════════════════════════════════════

const EQ_MARKERS: Record<string, string> = {
  self_awareness:  'marker.eq.self_awareness',
  self_regulation: 'marker.eq.self_regulation',
  motivation:      'marker.eq.motivation',
  empathy:         'marker.eq.empathy',
  social_skill:    'marker.eq.social_skill',
};

export function eqToEvent(scores: Record<string, number>): ContributionEvent {
  const maxScore = Math.max(...Object.values(scores), 1);
  const markers: Marker[] = [];

  for (const [dim, markerId] of Object.entries(EQ_MARKERS)) {
    if (scores[dim] != null) {
      markers.push({
        id: markerId,
        weight: Math.min(scores[dim] / maxScore, 1),
        evidence: { confidence: 0.75, itemsAnswered: 15 },
      });
    }
  }

  return buildEvent('quiz.eq.v1', markers, []);
}

// ═══════════════════════════════════════════════════════════════
// AURA COLORS
// ═══════════════════════════════════════════════════════════════

export function auraToEvent(
  primaryAura: string,
  scores: Record<string, number>,
): ContributionEvent {
  const AURA_MARKERS: Record<string, string> = {
    warmth:    'marker.aura.warmth',
    mystery:   'marker.aura.mystery',
    authority: 'marker.aura.authority',
  };
  const maxScore = Math.max(...Object.values(scores), 1);
  const markers: Marker[] = Object.entries(AURA_MARKERS)
    .filter(([dim]) => scores[dim] != null)
    .map(([dim, id]) => ({
      id,
      weight: Math.min((scores[dim] ?? 0) / maxScore, 1),
      evidence: { confidence: 0.6, itemsAnswered: 10 },
    }));

  return buildEvent('quiz.aura.v1', markers, [
    { id: `tag.style.${primaryAura}`, label: primaryAura, kind: 'style', weight: 0.7 },
  ]);
}

// ═══════════════════════════════════════════════════════════════
// SOCIAL ROLE
// ═══════════════════════════════════════════════════════════════

export function socialRoleToEvent(
  roleId: string,
  scores: Record<string, number>,
): ContributionEvent {
  const SOCIAL_MARKERS: Record<string, string> = {
    dominance:   'marker.social.dominance',
    openness:    'marker.social.openness',
    extroversion:'marker.social.extroversion',
  };
  const maxScore = Math.max(...Object.values(scores), 1);
  const markers: Marker[] = Object.entries(SOCIAL_MARKERS)
    .filter(([dim]) => scores[dim] != null)
    .map(([dim, id]) => ({
      id,
      weight: Math.min((scores[dim] ?? 0) / maxScore, 1),
      evidence: { confidence: 0.7, itemsAnswered: 12 },
    }));

  return buildEvent('quiz.social_role.v1', markers, [
    { id: `tag.archetype.${roleId}`, label: roleId, kind: 'archetype', weight: 0.75 },
  ]);
}

// ═══════════════════════════════════════════════════════════════
// GENERIC BUILDER
// ═══════════════════════════════════════════════════════════════

function buildEvent(
  moduleId: string,
  markers: Marker[],
  tags: Tag[],
): ContributionEvent {
  return {
    specVersion: 'sp.contribution.v1',
    eventId: crypto.randomUUID(),
    occurredAt: new Date().toISOString(),
    source: {
      vertical: 'quiz',
      moduleId,
      locale: 'de-DE',
    },
    payload: {
      markers,
      tags: tags.length > 0 ? tags : undefined,
    },
  };
}
