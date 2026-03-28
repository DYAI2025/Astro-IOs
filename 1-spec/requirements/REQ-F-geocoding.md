# REQ-F-geocoding: Birth Place Geocoding with Autocomplete

**Type**: Functional
**Status**: Approved
**Priority**: Must-have
**Source story**: [US-enter-birth-data](../user-stories/US-enter-birth-data.md)

## Description

The birth place field provides autocomplete suggestions via MKLocalSearch and resolves the selected place to latitude, longitude, and IANA timezone via CLGeocoder.

## Acceptance Criteria

- [ ] Typing ≥2 characters shows up to 5 autocomplete suggestions
- [ ] Selecting a suggestion fills latitude, longitude, and timezone in BirthData
- [ ] Checkmark indicator appears after successful geocoding
- [ ] Timezone resolution uses CLGeocoder reverse geocoding
