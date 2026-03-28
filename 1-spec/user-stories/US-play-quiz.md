# US-play-quiz: Play a Personality Quiz

**As a** end user, **I want** to play a personality quiz from start to finish and see my result, **so that** I discover something about myself in a fun, gamified way.

**Status**: Approved
**Priority**: Should-have
**Source stakeholder**: [STK-end-user](../stakeholders.md)
**Related goal**: [GOAL-self-discovery-quizzes](../goals/GOAL-self-discovery-quizzes.md)

## Acceptance Criteria

- Given I am on the Quizzes tab, when I tap a quiz tile, then the quiz opens full-screen
- Given I am in a quiz, then I see one question at a time with a progress bar
- Given I tap an answer, then it highlights and auto-advances after 600ms
- Given I complete the last question, then I see my result profile with title, description, stats, and dimension bars
- Given I tap "Back to Quizzes", then the quiz tile shows a checkmark

## Derived Requirements

- [REQ-F-quiz-scoring](../requirements/REQ-F-quiz-scoring.md)
