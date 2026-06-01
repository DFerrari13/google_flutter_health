## 0.7.0

### Added

- **Electrocardiogram** (`GoogleHealthElectrocardiogramData{Manager,APIURL}`) —
  ECG readings with lead I waveform samples, rhythm classification
  (`GoogleHealthEcgResultClassification`: `normalSinusRhythm`, `atrialFibrillation`,
  `inconclusive*`, `unreadable`, `notAnalyzed`), average bpm, sampling frequency,
  millivolts scaling factor, and SaMD device metadata.
  Convenience getters: `waveformMillivolts` (raw samples → mV), `sampleDuration`.
  Requires `GoogleHealthScopes.ecgReadonly`.
  **API note:** the ECG endpoint only supports a `>=` lower-bound filter on
  `start_time` — an upper bound returns HTTP 400. Both `day()` and `dateRange()`
  filter from the given start date onward.
- **Irregular Rhythm Notification** (`GoogleHealthIrregularRhythmNotificationData{Manager,APIURL}`) —
  AFib alert sessions with nested `alertWindows` (each containing `heartBeats` and
  positivity flag) and SaMD device metadata.
  Requires `GoogleHealthScopes.irnReadonly`.
  Same one-sided filter constraint as ECG.
- **Paired Devices** (`GoogleHealthPairedDeviceData{Manager,APIURL}`) — list or
  fetch individual Bluetooth devices paired to the authenticated user, including
  device type, battery status/level, last sync time, firmware version, MAC address,
  and supported feature identifiers.
  Uses `GoogleHealthPairedDeviceAPIURL.list` (all devices) or
  `GoogleHealthPairedDeviceAPIURL.get(name)` (single device).
  Requires `GoogleHealthScopes.settingsReadonly`.
- `GoogleHealthMedicalDeviceInfo` — shared SaMD metadata model embedded in both
  ECG and IRN data points (`algorithmVersion`, `serviceVersion`, `firmwareVersion`,
  `featureVersion`, `deviceModel`).
- `GoogleHealthScopes.ecg` / `ecgReadonly` and `GoogleHealthScopes.irn` / `irnReadonly`
  scope constants.
- Example app updated: ECG card with waveform chart, IRN card, and Paired Devices
  card.

## 0.6.1

- Replaced hardcoded OAuth credentials in example app with placeholders.
- Removed build artifacts (`.dart_tool/`, `build/`) from repository.

## 0.6.0

### Breaking changes

- **Steps** rewritten around the `steps:rollUp` POST endpoint. The previous
  `count` field is gone — use `countSum` instead. Each rollup point covers one
  calendar day (`windowSize: "86400s"`). The intraday factory has been removed
  because the library now exposes only the daily aggregate.
- **Removed data types:** `GoogleHealthHeartRate*`, `GoogleHealthDistance*`,
  `GoogleHealthCalories*`, `GoogleHealthWeight*`, `GoogleHealthExercise*`,
  `GoogleHealthActiveZoneMinutes*`. Real-world Google Health responses only
  consistently populate the daily-aggregated metrics, so the scope of the
  library has been focused on those.

### Added

- **Active Minutes** (`GoogleHealthActiveMinutesData{Manager,APIURL}`) — daily
  rollup of non-sedentary time split by intensity level
  (`LIGHT` / `MODERATE` / `VIGOROUS`). `totalActiveMinutes` convenience getter
  sums the three.
- **Sedentary Period** (`GoogleHealthSedentaryPeriodData{Manager,APIURL}`) —
  daily rollup of total sedentary time as a Dart `Duration`. Parses both
  whole-second (`"3600s"`) and fractional (`"3.5s"`) duration strings.
- **Resting Heart Rate** now exposes `calculationMethod` (`WITH_SLEEP` /
  `ONLY_WITH_AWAKE_DATA` / `CALCULATION_METHOD_UNSPECIFIED`).
- **HRV** now exposes `nonRemBpm`, `entropy`, and `deepSleepRmssdMs` alongside
  the `rmssd` average.
- **Sleep** model rewritten around `sleep.summary.stagesSummary` — per-stage
  minutes and counts (`deepMinutes` / `deepCount`, `remMinutes` / `remCount`,
  `lightMinutes` / `lightCount`, `awakeMinutes` / `awakeCount`) plus the
  top-level `minutesAsleep` / `minutesAwake` / `minutesInSleepPeriod` totals.
  Naps are filtered out in the manager.
- **`dateRange()` factory** documented for every time-series URL builder.
  Pass a start/end calendar-day pair to receive one rollup point (or one
  daily list entry) per day in the range. Useful when you want a chart over a
  week or month from a single call.

### Changed

- README rewritten: the **Supported Data Types** table now lists every type
  with its endpoint, HTTP verb, and granularity. A **Data Types Reference**
  section documents every field of every model, plus a copy-paste example for
  each.
- Example app rewritten as a debug harness with one card per data type. Each
  card has a `SegmentedButton` to toggle between single-day and date-range
  queries, separate date pickers, and a dialog that prints the raw URL and
  every returned data point.
- Active Minutes activity-level enum values corrected to match the live API
  (`LIGHT` / `MODERATE` / `VIGOROUS`, previously incorrectly assumed to be
  `LIGHTLY_ACTIVE` / `MODERATELY_ACTIVE` / `VERY_ACTIVE`).

## 0.5.1

### Changed

- Removed internal publishing guidelines from README.

## 0.5.0

### Fixed

- Fixed URL builder tests for daily endpoints (HRV, oxygen saturation, resting
  heart rate) that expected filter expressions but implementations don't support
  them per Google Health API spec.
- Fixed tests for sleep, exercise, and active zone minutes to expect correct
  `civil_start_time` and `civil_end_time` field paths instead of `start_time`.
- All 83 unit tests now passing with zero warnings.

### Added

- Comprehensive pub.dev publishing guidelines in README with security checklist
  and sensitive data protection best practices.
- `test` package added to dev dependencies for running test suite.

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
