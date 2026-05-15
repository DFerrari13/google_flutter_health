## 0.1.0

### Added

- `GoogleHealthConnector` — OAuth 2.0 authorization, token refresh, user identity, and revocation.
- `GoogleHealthCredentials` — serialisable credentials model with `isExpired` (60-second buffer), `toJson`, and `fromJson`.
- `GoogleHealthScopes` — scope URL constants for activity & fitness, health metrics, sleep, profile, location, and nutrition.
- `GoogleHealthDataManager` — abstract base class for all data managers with automatic token refresh in `fetch()`.
- `GoogleHealthStepsDataManager` + `GoogleHealthStepsAPIURL` + `GoogleHealthStepsData` — daily and intraday step count.
- `GoogleHealthHeartRateDataManager` + `GoogleHealthHeartRateAPIURL` + `GoogleHealthHeartRateData` — daily and intraday heart rate.
- `GoogleHealthSleepDataManager` + `GoogleHealthSleepAPIURL` + `GoogleHealthSleepData` — sleep sessions with stage and duration.
- `GoogleHealthProfileDataManager` + `GoogleHealthProfileAPIURL` + `GoogleHealthProfileData` — user profile and settings.
- `GoogleHealthException` hierarchy: `GoogleHealthAuthException`, `GoogleHealthTokenExpiredException`, `GoogleHealthRateLimitException`, `GoogleHealthDataTypeException`, `GoogleHealthNetworkException`, `GoogleHealthDataException`.
- Full dartdoc API documentation.
- Example app demonstrating login and step count fetch.
