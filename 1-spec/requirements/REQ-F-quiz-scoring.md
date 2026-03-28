# REQ-F-quiz-scoring: Quiz Scoring Engine

**Type**: Functional
**Status**: Approved
**Priority**: Should-have
**Source story**: [US-play-quiz](../user-stories/US-play-quiz.md)

## Description

Quiz answers are aggregated by dimension, normalized to 0-100, and matched to the best-fit profile. Logic is identical to the web app (quizzme-api-config.json).

## Acceptance Criteria

- [ ] QuizEngine.calculateScores() sums dimension weights per answer
- [ ] Normalization: raw / (questionCount * 5) * 100
- [ ] QuizEngine.matchProfile() returns profile matching dominant dimension
- [ ] Completed quiz IDs persisted in UserDefaults
