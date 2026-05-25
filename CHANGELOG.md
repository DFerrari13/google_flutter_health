## 0.4.0

### Added

- `GoogleHealthBreathingRateDataManager` + `GoogleHealthBreathingRateAPIURL`
  + `GoogleHealthBreathingRateData` — daily respiratory rate aggregates
  (avg / min / max breaths per minute). Uses the
  `googlehealth.health_metrics_and_measurements.readonly` scope.
- `GoogleHealthSkinTemperatureDataManager` +
  `GoogleHealthSkinTemperatureAPIURL` + `GoogleHealthSkinTemperatureData` —
  nightly skin temperature variation in °C from the user's baseline. Uses
  the `googlehealth.health_metrics_and_measurements.readonly` scope. Not an
  absolute body-temperature reading.

The JSON envelope parsers accept the alternate `daily-respiratory-rate`
(`dailyRespiratoryRate`) and `daily-skin-temperature` (`dailySkinTemperature`)
shapes too, so swapping the `dataType` constant if your project hits a 404
does not require touching the data classes.

## 0.3.0

### Breaking changes

- **API correctness rewrite.** Every URL builder, data manager, and data
  model has been rewritten to match the live Google Health REST API v4.
  All field names, HTTP methods, request shapes, and response shapes have
  changed.
- `dailyRollUp` endpoints are now POST requests with a `range` body using
  `CivilDateTime` objects (previously incorrect lowercase `dailyRollup`
  GET requests).
- `rollUp` endpoints are POST with a `range` body and `windowSize`.
- `list` endpoints use the `filter` query parameter with a CEL expression
  on the data-type-specific time field (e.g.
  `steps.interval.start_time >= "..." AND steps.interval.start_time < "..."`).
- Data models now parse nested response objects:
  - Steps → `steps.count` / `steps.countSum`
  - Heart rate → `heartRate.beatsPerMinute` / `heartRate.beatsPerMinute{Avg,Min,Max}`
  - Sleep → flattened from `sleep.stages[]`
  - Profile → exposes only the fields the API actually returns (age,
    membershipStartDate, stride lengths, unit preferences)
- `GoogleHealthConnector.getUserId` now calls `/v4/users/me/identity` and
  reads the `healthUserId` field (previously called `:getIdentity` and
  parsed `userId`).
- Profile model field names changed (no more `displayName`, `givenName`,
  `birthdate`, `heightCm`, `sex`).
- Removed unused `googleapis_auth` dependency.

### Added

- `GoogleHealthRequestMethod` enum on `GoogleHealthAPIURL` for GET/POST
  dispatch.
- Settings scopes (`settings`, `settingsReadonly`) and read-write
  `nutrition` scope to `GoogleHealthScopes`.
- Rate-limit retry-after header parsed into
  `GoogleHealthRateLimitException.retryAfter`.

## 0.2.0

### Added

- `GoogleHealthDistanceDataManager` + `GoogleHealthDistanceAPIURL` + `GoogleHealthDistanceData` — daily and intraday distance in meters.
- `GoogleHealthCaloriesDataManager` + `GoogleHealthCaloriesAPIURL` + `GoogleHealthCaloriesData` — daily and intraday total energy expenditure in kilocalories.
- `GoogleHealthActiveZoneMinutesDataManager` + `GoogleHealthActiveZoneMinutesAPIURL` + `GoogleHealthActiveZoneMinutesData` — daily and intraday active zone minutes broken down by fat-burn, cardio, peak, and total.
- `GoogleHealthRestingHeartRateDataManager` + `GoogleHealthRestingHeartRateAPIURL` + `GoogleHealthRestingHeartRateData` — daily resting heart rate.
- `GoogleHealthOxygenSaturationDataManager` + `GoogleHealthOxygenSaturationAPIURL` + `GoogleHealthOxygenSaturationData` — daily SpO2 (avg / min / max).
- `GoogleHealthHrvDataManager` + `GoogleHealthHrvAPIURL` + `GoogleHealthHrvData` — daily heart-rate variability.
- `GoogleHealthWeightDataManager` + `GoogleHealthWeightAPIURL` + `GoogleHealthWeightData` — weight samples and daily aggregates.
- `GoogleHealthExerciseDataManager` + `GoogleHealthExerciseAPIURL` + `GoogleHealthExerciseData` — exercise sessions.

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
