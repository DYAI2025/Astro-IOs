# REQ-F-profile-persistence: Local Profile Persistence

**Type**: Functional
**Status**: Draft
**Priority**: Must-have
**Source story**: [US-offline-access](../user-stories/US-offline-access.md)

## Description

CosmicProfile and BirthData are persisted locally in UserDefaults as JSON. App loads cached profile on startup and skips to dashboard.

## Acceptance Criteria

- [ ] PersistenceService.saveProfile() encodes CosmicProfile to JSON in UserDefaults
- [ ] PersistenceService.loadProfile() restores complete profile on cold start
- [ ] App starts in dashboard phase if cached profile exists
- [ ] signOut() clears all persisted data
