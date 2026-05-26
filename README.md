# google_flutter_health

[![pub package](https://img.shields.io/pub/v/google_flutter_health.svg)](https://pub.dev/packages/google_flutter_health)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)
[![dart analyze](https://img.shields.io/badge/dart%20analyze-passing-brightgreen)](https://dart.dev/tools/dart-analyze)

A Flutter package for the [Google Health API](https://developers.google.com/health/reference/rest).
Wraps OAuth 2.0 authentication and REST data fetching in a clean, type-safe Dart interface.
Handles token refresh transparently so you never need to worry about expired credentials mid-session.
Designed as the spiritual successor to [Fitbitter](https://pub.dev/packages/fitbitter) — if you have
used Fitbitter before, the architecture will feel immediately familiar.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  google_flutter_health: ^0.6.0
  google_sign_in: ^7.0.0          # for interactive sign-in on Android / iOS
  flutter_secure_storage: ^10.0.0 # for persisting credentials
```

Then run:

```sh
flutter pub get
```

---

## Migration from Fitbitter

Coming from [Fitbitter](https://pub.dev/packages/fitbitter)? The architecture
is deliberately parallel — connectors, managers, and URL builders work the same
way. See [MIGRATION.md](MIGRATION.md) for a step-by-step guide covering auth
changes, data type mapping, field renames, and the new `fetch()` return type.

---

## Google Cloud Console Setup

Before you can use this package you need OAuth 2.0 credentials from the Google Cloud Console.

1. Go to the [Google Cloud Console](https://console.cloud.google.com) and create (or select) a project.
2. Open **APIs & Services → Library** and search for **Google Health API**. Enable it.
3. Open **APIs & Services → OAuth consent screen**:
   - Choose **External** (or Internal for workspace apps).
   - Fill in the app name, user support email, and developer contact.
   - Add the scopes your app needs (e.g. `googlehealth.activity_and_fitness.readonly`).
   - Add your test users while the app is in testing mode.

### For Android (with `google_sign_in`):

4a. Create an **Android** OAuth client:
   - Application type: **Android**
   - Package name: `com.example.myapp` (or your actual package name)
   - SHA-1: Get this by running `./gradlew signingReport` in `android/`
   - Save — no redirect URI needed (Google automatically allows the Android app's custom scheme)

4b. Create a **Web** OAuth client (for server-side token exchange):
   - Application type: **Web application**
   - Authorized JavaScript origins: (leave empty or add `http://localhost`)
   - Authorized redirect URIs: `http://localhost` (or leave empty — Web client is used server-side only)
   - Copy the **Client ID** and **Client Secret** — use these in `GoogleSignInService(webClientID:, webClientSecret:)`

### For iOS (with `google_sign_in`):

4a. Create an **iOS** OAuth client:
   - Application type: **iOS**
   - Bundle ID: `com.example.myapp` (from `ios/Runner/Info.plist`)
   - Save

4b. Create a **Web** OAuth client (same as above)

### For Custom OAuth Flow:

If not using `google_sign_in`, create a single **Web** OAuth client:
   - Application type: **Web application**
   - Authorized redirect URIs: add your custom scheme(s), e.g. `com.example.myapp:/oauth2redirect`

---

## Android Setup

When using `GoogleSignInService`, `google_sign_in` v7 handles OAuth natively. No extra manifest
configuration is needed beyond the standard Internet permission.

Make sure your `android/app/src/main/AndroidManifest.xml` has:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

That's it — `google_sign_in` registers its own intent filters automatically.

**Note:** The package name in `AndroidManifest.xml` (e.g. `com.example.myapp`) must match the
Android client you created in Google Cloud Console.

---

## iOS Setup

When using `GoogleSignInService`, `google_sign_in` v7 handles OAuth natively. Make sure your
bundle ID in `ios/Runner/Info.plist` matches the iOS client you created in Google Cloud Console.
`google_sign_in` registers its own URL schemes automatically — no manual CFBundleURLTypes
config needed.

---

## Quick Start

### Using `GoogleSignInService` (Recommended)

`GoogleSignInService` encapsulates the entire login flow — credential management, token
refresh, and secure storage.

**1. Copy `example/lib/google_sign_in_service.dart` into your project.**

**2. In your Flutter State class:**

```dart
import 'package:google_flutter_health/google_flutter_health.dart';
import 'google_sign_in_service.dart';

class _MyAppState extends State<MyApp> {
  late final GoogleSignInService _auth;

  @override
  void initState() {
    super.initState();
    _auth = GoogleSignInService(
      webClientID: 'YOUR_WEB_CLIENT_ID',
      webClientSecret: 'YOUR_WEB_CLIENT_SECRET',
      scopes: [GoogleHealthScopes.activityAndFitnessReadonly],
    );
    _auth.initialize();
  }

  Future<void> _fetchStepsToday() async {
    final creds = _auth.session.credentials;
    if (creds == null) return;

    final manager = GoogleHealthStepsDataManager(
      credentials: creds,
      clientID: 'YOUR_WEB_CLIENT_ID',
      clientSecret: 'YOUR_WEB_CLIENT_SECRET',
    );
    final result = await manager.fetch(
      GoogleHealthStepsAPIURL.day(date: DateTime.now()),
    );

    // Always persist the (possibly refreshed) credentials
    _auth.session.updateCredentials(result.credentials);

    // result.data is a list of daily rollup points — one per calendar day
    final today = result.data.firstOrNull;
    print('Steps today: ${today?.countSum ?? 0}');
  }
}
```

For a complete, production-ready example with date pickers, error handling, and every
supported data type, see [example/lib/main.dart](example/lib/main.dart).

### Advanced: Using `GoogleHealthConnector` Directly

For more control (e.g. custom OAuth flow), use `GoogleHealthConnector` directly:

```dart
final credentials = await GoogleHealthConnector.authorize(
  clientID: 'YOUR_CLIENT_ID',
  clientSecret: 'YOUR_CLIENT_SECRET',
  redirectUri: 'com.example.myapp:/oauth2redirect',
  scopes: [GoogleHealthScopes.activityAndFitnessReadonly],
  launchBrowserAndGetRedirect: (Uri authUri) async {
    // You handle launching the browser and capturing the redirect
    return 'com.example.myapp:/oauth2redirect?code=AUTH_CODE&state=STATE';
  },
);
```

---

## Token Management

Every `fetch()` call returns a record `({List<T> data, GoogleHealthCredentials credentials})`.
The returned `credentials` may contain a freshly refreshed access token — always save it
back to secure storage so the next call starts with a valid token.

```dart
final result = await manager.fetch(url);
await secureStorage.write(key: 'access_token', value: result.credentials.accessToken);
```

Token refresh happens automatically inside `fetch()` when the token is within 60 seconds
of expiry. `GoogleHealthTokenExpiredException` is only thrown when the refresh token
itself has been revoked.

---

## Scopes

Request only the scopes your app actually uses — the user sees a consent screen listing
all requested scopes.

| Constant | Scope URL | Covers |
|----------|-----------|--------|
| `GoogleHealthScopes.activityAndFitnessReadonly` | `googlehealth.activity_and_fitness.readonly` | Steps, active minutes, sedentary period |
| `GoogleHealthScopes.healthMetricsReadonly` | `googlehealth.health_metrics_and_measurements.readonly` | Resting HR, HRV, SpO2, breathing rate, skin temperature |
| `GoogleHealthScopes.sleepReadonly` | `googlehealth.sleep.readonly` | Sleep sessions |
| `GoogleHealthScopes.profileReadonly` | `googlehealth.profile.readonly` | User profile (age, stride lengths, membership date) |
| `GoogleHealthScopes.settingsReadonly` | `googlehealth.settings.readonly` | Unit preferences, time zone, locale (used together with `profileReadonly`) |

Write-access variants (`activityAndFitness`, `healthMetrics`, `sleep`, `profile`, `settings`)
exist but prefer read-only unless you need write access.

---

## Supported Data Types

Every data type follows the same three-class pattern:
**`<Name>Data`** (the typed model) +
**`<Name>DataManager`** (the fetcher) +
**`<Name>APIURL`** (the URL builder, with `day(...)` and `dateRange(...)` factories).

| # | Data Type | API endpoint | HTTP | Granularity | Manager / URL / Model |
|---|-----------|--------------|------|-------------|----------------------|
| 1 | Steps | `/v4/users/me/dataTypes/steps/dataPoints:rollUp` | POST | 1 point / day | `GoogleHealthStepsDataManager` · `GoogleHealthStepsAPIURL` · `GoogleHealthStepsData` |
| 2 | Active Minutes | `/v4/users/me/dataTypes/active-minutes/dataPoints:rollUp` | POST | 1 point / day | `GoogleHealthActiveMinutesDataManager` · `GoogleHealthActiveMinutesAPIURL` · `GoogleHealthActiveMinutesData` |
| 3 | Sedentary Period | `/v4/users/me/dataTypes/sedentary-period/dataPoints:rollUp` | POST | 1 point / day | `GoogleHealthSedentaryPeriodDataManager` · `GoogleHealthSedentaryPeriodAPIURL` · `GoogleHealthSedentaryPeriodData` |
| 4 | Sleep | `/v4/users/me/dataTypes/sleep/dataPoints` | GET | 1 session each | `GoogleHealthSleepDataManager` · `GoogleHealthSleepAPIURL` · `GoogleHealthSleepData` |
| 5 | Resting Heart Rate | `/v4/users/me/dataTypes/daily-resting-heart-rate/dataPoints` | GET | 1 point / day | `GoogleHealthRestingHeartRateDataManager` · `GoogleHealthRestingHeartRateAPIURL` · `GoogleHealthRestingHeartRateData` |
| 6 | Oxygen Saturation | `/v4/users/me/dataTypes/daily-oxygen-saturation/dataPoints` | GET | 1 point / day | `GoogleHealthOxygenSaturationDataManager` · `GoogleHealthOxygenSaturationAPIURL` · `GoogleHealthOxygenSaturationData` |
| 7 | HRV | `/v4/users/me/dataTypes/daily-heart-rate-variability/dataPoints` | GET | 1 point / day | `GoogleHealthHrvDataManager` · `GoogleHealthHrvAPIURL` · `GoogleHealthHrvData` |
| 8 | Breathing Rate | `/v4/users/me/dataTypes/daily-respiratory-rate/dataPoints` | GET | 1 point / day | `GoogleHealthBreathingRateDataManager` · `GoogleHealthBreathingRateAPIURL` · `GoogleHealthBreathingRateData` |
| 9 | Skin Temperature | `/v4/users/me/dataTypes/daily-sleep-temperature-derivations/dataPoints` | GET | 1 point / night | `GoogleHealthSkinTemperatureDataManager` · `GoogleHealthSkinTemperatureAPIURL` · `GoogleHealthSkinTemperatureData` |
| 10 | Profile & Settings | `/v4/users/me/profile` + `/v4/users/me/settings` | GET | static | `GoogleHealthProfileDataManager` · `GoogleHealthProfileAPIURL` · `GoogleHealthProfileData` |

### Querying for one day vs. a date range

All time-series builders expose two factories. Both return data through the same model;
the difference is just the time window.

```dart
// One calendar day → result.data has at most 1 element
GoogleHealthStepsAPIURL.day(date: DateTime(2026, 5, 26));

// Inclusive date range → result.data has up to (endDate − startDate + 1) elements
GoogleHealthStepsAPIURL.dateRange(
  startDate: DateTime(2026, 5, 20),
  endDate:   DateTime(2026, 5, 26),
);  // → up to 7 daily rollup points
```

Rollup endpoints (Steps, Active Minutes, Sedentary Period) send a `windowSize: "86400s"`
body so each calendar day in the range yields exactly one rollup point. List endpoints
(Sleep, Resting HR, etc.) widen the CEL filter expression on the underlying time field.

---

## Data Types Reference

### 1. Steps

**Model:** `GoogleHealthStepsData` — one daily rollup point.

| Field | Type | Description |
|-------|------|-------------|
| `startTime` | `DateTime?` | UTC midnight at the start of the rollup window |
| `endTime` | `DateTime?` | UTC midnight at the end of the rollup window |
| `countSum` | `int?` | Total step count for the day |

**URL builders:**

```dart
GoogleHealthStepsAPIURL.day(date: DateTime.now());
GoogleHealthStepsAPIURL.dateRange(startDate: start, endDate: end);
```

**Example:**

```dart
final manager = GoogleHealthStepsDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthStepsAPIURL.day(date: DateTime.now()),
);
final steps = result.data.firstOrNull?.countSum ?? 0;
print('Steps today: $steps');
```

---

### 2. Active Minutes

**Model:** `GoogleHealthActiveMinutesData` — one daily rollup point with a three-level
intensity breakdown.

The Google Health API splits non-sedentary time into three intensity levels
(`LIGHT` / `MODERATE` / `VIGOROUS`). This package exposes them as separate fields and
gives you a convenience getter for the total.

| Field | Type | Description |
|-------|------|-------------|
| `startTime` | `DateTime?` | UTC midnight at the start of the rollup window |
| `endTime` | `DateTime?` | UTC midnight at the end of the rollup window |
| `lightlyActiveMinutes` | `int?` | Minutes from `activityLevel == "LIGHT"` |
| `moderatelyActiveMinutes` | `int?` | Minutes from `activityLevel == "MODERATE"` |
| `veryActiveMinutes` | `int?` | Minutes from `activityLevel == "VIGOROUS"` |
| `totalActiveMinutes` *(getter)* | `int?` | Sum of the three levels (`null` only when all three are null) |

**URL builders:**

```dart
GoogleHealthActiveMinutesAPIURL.day(date: DateTime.now());
GoogleHealthActiveMinutesAPIURL.dateRange(startDate: start, endDate: end);
```

**Example:**

```dart
final result = await GoogleHealthActiveMinutesDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
).fetch(GoogleHealthActiveMinutesAPIURL.day(date: DateTime.now()));

final d = result.data.firstOrNull;
print('Light: ${d?.lightlyActiveMinutes}, '
      'Moderate: ${d?.moderatelyActiveMinutes}, '
      'Vigorous: ${d?.veryActiveMinutes}, '
      'total: ${d?.totalActiveMinutes}');
```

---

### 3. Sedentary Period

**Model:** `GoogleHealthSedentaryPeriodData` — one daily rollup point with the total
sedentary duration.

The API serialises the duration as a string with a trailing `s` (e.g. `"3600s"` for
one hour, or `"3.5s"` for fractional seconds). The library parses it into a Dart
`Duration`.

| Field | Type | Description |
|-------|------|-------------|
| `startTime` | `DateTime?` | UTC midnight at the start of the rollup window |
| `endTime` | `DateTime?` | UTC midnight at the end of the rollup window |
| `duration` | `Duration?` | Total sedentary time in the day |

**URL builders:**

```dart
GoogleHealthSedentaryPeriodAPIURL.day(date: DateTime.now());
GoogleHealthSedentaryPeriodAPIURL.dateRange(startDate: start, endDate: end);
```

**Example:**

```dart
final result = await GoogleHealthSedentaryPeriodDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
).fetch(GoogleHealthSedentaryPeriodAPIURL.day(date: DateTime.now()));

final sedentary = result.data.firstOrNull?.duration ?? Duration.zero;
print('Sedentary: ${sedentary.inHours}h ${sedentary.inMinutes.remainder(60)}m');
```

---

### 4. Sleep

**Model:** `GoogleHealthSleepData` — one sleep session per element. The manager
filters out naps (`type == "NAP"`) so `result.data` is the list of main sleep
sessions for the queried window.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name (`users/me/dataTypes/sleep/dataPoints/...`) |
| `startTime` | `DateTime?` | Session start time |
| `endTime` | `DateTime?` | Session end time |
| `sleepType` | `String?` | `"MAIN_SLEEP"`, `"NAP"`, or `"SLEEP_TYPE_UNSPECIFIED"` |
| `minutesAsleep` | `int?` | Minutes actually asleep (excludes awake periods) |
| `minutesAwake` | `int?` | Minutes awake within the session |
| `minutesInSleepPeriod` | `int?` | Total minutes in bed |
| `awakeMinutes` / `awakeCount` | `int?` | Minutes and number of awake stages |
| `deepMinutes` / `deepCount` | `int?` | Minutes and number of deep-sleep stages |
| `remMinutes` / `remCount` | `int?` | Minutes and number of REM stages |
| `lightMinutes` / `lightCount` | `int?` | Minutes and number of light-sleep stages |
| `duration` *(getter)* | `Duration?` | `endTime − startTime` |

**URL builders:**

```dart
GoogleHealthSleepAPIURL.day(date: DateTime.now());
GoogleHealthSleepAPIURL.dateRange(startDate: start, endDate: end);
```

**Example:**

```dart
final result = await GoogleHealthSleepDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
).fetch(GoogleHealthSleepAPIURL.day(date: DateTime.now()));

for (final s in result.data) {
  print('${s.startTime} → ${s.endTime}: '
        '${s.minutesAsleep} min asleep, '
        'deep ${s.deepMinutes}, rem ${s.remMinutes}, light ${s.lightMinutes}');
}
```

---

### 5. Resting Heart Rate

**Model:** `GoogleHealthRestingHeartRateData` — one point per day.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Local civil date the point applies to |
| `beatsPerMinute` | `double?` | Resting heart rate in bpm |
| `calculationMethod` | `String?` | `"WITH_SLEEP"`, `"ONLY_WITH_AWAKE_DATA"`, or `"CALCULATION_METHOD_UNSPECIFIED"` |

**URL builders:**

```dart
GoogleHealthRestingHeartRateAPIURL.day(date: DateTime.now());
GoogleHealthRestingHeartRateAPIURL.dateRange(startDate: start, endDate: end);
```

**Example:**

```dart
final result = await GoogleHealthRestingHeartRateDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
).fetch(GoogleHealthRestingHeartRateAPIURL.dateRange(
  startDate: DateTime.now().subtract(const Duration(days: 6)),
  endDate: DateTime.now(),
));

for (final d in result.data) {
  print('${d.startTime}: ${d.beatsPerMinute} bpm (${d.calculationMethod})');
}
```

---

### 6. Oxygen Saturation (SpO2)

**Model:** `GoogleHealthOxygenSaturationData` — one point per day.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Local civil date the point applies to |
| `percentageAvg` | `double?` | Average SpO2 for the day (`averagePercentage`, 0–100) |
| `percentageMin` | `double?` | Lower bound (`lowerBoundPercentage`, 0–100) |
| `percentageMax` | `double?` | Upper bound (`upperBoundPercentage`, 0–100) |
| `percentageStdDev` | `double?` | Standard deviation across samples (optional) |

**URL builders:**

```dart
GoogleHealthOxygenSaturationAPIURL.day(date: DateTime.now());
GoogleHealthOxygenSaturationAPIURL.dateRange(startDate: start, endDate: end);
```

**Example:**

```dart
final result = await GoogleHealthOxygenSaturationDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
).fetch(GoogleHealthOxygenSaturationAPIURL.day(date: DateTime.now()));

final d = result.data.firstOrNull;
print('SpO2: ${d?.percentageAvg}% '
      '(${d?.percentageMin}–${d?.percentageMax})');
```

---

### 7. Heart Rate Variability (HRV)

**Model:** `GoogleHealthHrvData` — one point per day.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Local civil date the point applies to |
| `rmssd` | `double?` | Average HRV during sleep, ms (`averageHeartRateVariabilityMilliseconds`) |
| `nonRemBpm` | `int?` | Average heart rate during non-REM sleep, bpm |
| `entropy` | `double?` | Entropy of the HRV signal |
| `deepSleepRmssdMs` | `double?` | RMSSD computed only during deep sleep, ms |

**URL builders:**

```dart
GoogleHealthHrvAPIURL.day(date: DateTime.now());
GoogleHealthHrvAPIURL.dateRange(startDate: start, endDate: end);
```

**Example:**

```dart
final result = await GoogleHealthHrvDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
).fetch(GoogleHealthHrvAPIURL.day(date: DateTime.now()));

final d = result.data.firstOrNull;
print('HRV (RMSSD): ${d?.rmssd} ms, non-REM bpm: ${d?.nonRemBpm}');
```

---

### 8. Breathing Rate

**Model:** `GoogleHealthBreathingRateData` — one point per night.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Local civil date the point applies to |
| `breathsPerMinute` | `double?` | Average respiratory rate during sleep |

**URL builders:**

```dart
GoogleHealthBreathingRateAPIURL.day(date: DateTime.now());
GoogleHealthBreathingRateAPIURL.dateRange(startDate: start, endDate: end);
```

**Example:**

```dart
final result = await GoogleHealthBreathingRateDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
).fetch(GoogleHealthBreathingRateAPIURL.day(date: DateTime.now()));

final br = result.data.firstOrNull?.breathsPerMinute;
print('Breathing rate: $br brpm');
```

---

### 9. Skin Temperature (Sleep Temperature Derivations)

**Model:** `GoogleHealthSkinTemperatureData` — one point per night.

This is **nightly skin temperature** during sleep, not an absolute body
temperature reading. `relativeStddev30dCelsius` is the deviation from the
user's 30-day rolling baseline — useful for spotting anomalies.

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Local civil date the point applies to |
| `nightlyCelsius` | `double?` | Nightly temperature in °C |
| `baselineCelsius` | `double?` | Personal baseline temperature in °C |
| `relativeStddev30dCelsius` | `double?` | 30-day relative nightly std-dev in °C |

**URL builders:**

```dart
GoogleHealthSkinTemperatureAPIURL.day(date: DateTime.now());
GoogleHealthSkinTemperatureAPIURL.dateRange(startDate: start, endDate: end);
```

**Example:**

```dart
final result = await GoogleHealthSkinTemperatureDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
).fetch(GoogleHealthSkinTemperatureAPIURL.day(date: DateTime.now()));

final d = result.data.firstOrNull;
print('Nightly: ${d?.nightlyCelsius}°C '
      '(baseline ${d?.baselineCelsius}°C, '
      'Δ30d ±${d?.relativeStddev30dCelsius}°C)');
```

---

### 10. Profile & Settings

**Model:** `GoogleHealthProfileData` — single static record combining
`/users/me/profile` and `/users/me/settings`. The manager fetches both endpoints
and merges them.

For richer demographic data (display name, profile photo, email) use the Google
account profile from your sign-in library — the Google Health API itself does
not expose those fields.

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| `profileName` | `String?` | profile | Resource name (`users/me/profile`) |
| `age` | `int?` | profile | User's age in completed years |
| `membershipStartDate` | `String?` | profile | ISO 8601 date the user joined Google Health |
| `userConfiguredWalkingStrideLengthMm` | `int?` | profile | User-set walking stride (mm) |
| `userConfiguredRunningStrideLengthMm` | `int?` | profile | User-set running stride (mm) |
| `autoWalkingStrideLengthMm` | `int?` | profile | Auto-derived walking stride (mm) |
| `autoRunningStrideLengthMm` | `int?` | profile | Auto-derived running stride (mm) |
| `settingsName` | `String?` | settings | Resource name (`users/me/settings`) |
| `autoStrideEnabled` | `bool?` | settings | Whether automatic stride detection is on |
| `distanceUnit` | `String?` | settings | `MILES` or `KILOMETERS` |
| `weightUnit` | `String?` | settings | `POUNDS`, `STONE`, or `KILOGRAMS` |
| `heightUnit` | `String?` | settings | `INCHES` or `CENTIMETERS` |
| `temperatureUnit` | `String?` | settings | `CELSIUS` or `FAHRENHEIT` |
| `glucoseUnit` | `String?` | settings | `MG_DL` or `MMOL_L` |
| `swimUnit` | `String?` | settings | `METERS` or `YARDS` |
| `waterUnit` | `String?` | settings | `ML`, `FL_OZ`, or `CUP` |
| `languageLocale` | `String?` | settings | User locale (e.g. `en-US`) |
| `timeZone` | `String?` | settings | IANA time zone (e.g. `America/New_York`) |
| `utcOffset` | `String?` | settings | UTC offset duration string (e.g. `-28800s`) |
| `strideLengthWalkingType` | `String?` | settings | `USER_CONFIGURED` or `AUTOMATIC` |
| `strideLengthRunningType` | `String?` | settings | `USER_CONFIGURED` or `AUTOMATIC` |

**URL builders:** `GoogleHealthProfileAPIURL.profile` and
`GoogleHealthProfileAPIURL.settings` are static instances (no parameters). Pass
either one to `fetch()` — the manager internally calls both endpoints and merges
the responses.

**Example:**

```dart
final result = await GoogleHealthProfileDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
).fetch(GoogleHealthProfileAPIURL.profile);

final p = result.data.first;
print('Age: ${p.age}, member since ${p.membershipStartDate}, '
      'prefers ${p.distanceUnit} / ${p.weightUnit} / ${p.temperatureUnit}, '
      'tz ${p.timeZone}');
```

> Reading profile age requires `profileReadonly`. Reading unit / locale / time
> zone settings requires `settingsReadonly`. Request **both** scopes for a
> complete `GoogleHealthProfileData`.

---

## Pagination & Time Range Limits

* List endpoints (Sleep, Resting HR, SpO2, HRV, Breathing Rate, Skin Temp)
  return up to 1,440 data points per page (25 for `sleep`). When the response
  contains a `nextPageToken`, this library currently returns only the first
  page — fetch subsequent pages manually by appending `&pageToken=…`.
* List queries are capped at **14 days** for `active-minutes`, and **90 days**
  for all other types. Split larger windows yourself.
* Rollup endpoints (Steps, Active Minutes, Sedentary Period) always return
  one point per day and have no page size concern in practice for ranges
  the API accepts.

---

## Error Handling

All errors thrown by this package extend `GoogleHealthException`:

```dart
try {
  final result = await manager.fetch(url);
} on GoogleHealthTokenExpiredException {
  // Refresh token revoked — ask user to re-login
} on GoogleHealthRateLimitException catch (e) {
  // Back off and retry after e.retryAfter
} on GoogleHealthNetworkException {
  // No connectivity
} on GoogleHealthException catch (e) {
  // Catch-all for any other library error
  print(e.message);
}
```

---

## Contributing

Contributions are welcome! Please open an issue before submitting a PR to discuss the change.
Make sure to:

1. Run `dart analyze --fatal-infos` — zero warnings required.
2. Run `flutter test` — all tests must pass.
3. Run `dart format --set-exit-if-changed lib test` — code must be formatted.
4. Add tests for any new data type following the existing pattern.

---

## License

BSD-3-Clause — see [LICENSE](LICENSE).
