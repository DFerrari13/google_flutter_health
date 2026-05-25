# google_flutter_health

[![pub package](https://img.shields.io/pub/v/google_flutter_health.svg)](https://pub.dev/packages/google_flutter_health)
[![License: BSD-3-Clause](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE)
[![dart analyze](https://img.shields.io/badge/dart%20analyze-passing-brightgreen)](https://dart.dev/tools/dart-analyze)

A Flutter package for the [Google Health API](https://developers.google.com/health/reference/rest). Wraps OAuth 2.0 authentication and REST data fetching in a clean, type-safe Dart interface. Handles token refresh transparently so you never need to worry about expired credentials mid-session. Designed as the spiritual successor to [Fitbitter](https://pub.dev/packages/fitbitter) — if you have used Fitbitter before, the architecture will feel immediately familiar.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  google_flutter_health: ^0.3.0
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

When using `GoogleSignInService`, `google_sign_in` v7 handles OAuth natively. No extra manifest configuration is needed beyond the standard Internet permission.

Make sure your `android/app/src/main/AndroidManifest.xml` has:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

That's it — `google_sign_in` registers its own intent filters automatically.

---

**Note:** The package name in `AndroidManifest.xml` (e.g. `com.example.myapp`) must match the Android client you created in Google Cloud Console.

---

## iOS Setup

When using `GoogleSignInService`, `google_sign_in` v7 handles OAuth natively. Make sure:

1. Your bundle ID in `ios/Runner/Info.plist` matches the iOS client you created in Google Cloud Console.
2. You have the standard iOS privacy permissions (usually auto-configured by Flutter):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photos</string>
```

`google_sign_in` registers its own URL schemes automatically — no manual CFBundleURLTypes config needed.

---

## Quick Start

### Using `GoogleSignInService` (Recommended)

`GoogleSignInService` encapsulates the entire login flow — credential management, token refresh, and secure storage. Copy it into your app:

**1. Copy `example/lib/google_sign_in_service.dart` into your project.**

**2. In your Flutter State class:**

```dart
import 'package:google_flutter_health/google_flutter_health.dart';
import 'google_sign_in_service.dart';

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

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
    _auth.initialize().then((_) {
      if (mounted) {
        setState(() {}); // update UI if previously signed in
        _auth.session.addListener(_onSessionChanged);
      }
    });
  }

  @override
  void dispose() {
    _auth.session.removeListener(_onSessionChanged);
    _auth.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _login() async {
    try {
      await _auth.login();
    } catch (e) {
      print('Login failed: $e');
    }
  }

  Future<void> _fetchSteps() async {
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

    // Persist the potentially-refreshed token
    _auth.session.updateCredentials(result.credentials);
    print('Steps today: ${result.data.first.count}');
  }

  Future<void> _logout() async {
    await _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_auth.session.isAuthenticated) ...[
              Text('Signed in'),
              ElevatedButton(onPressed: _fetchSteps, child: Text('Fetch steps')),
              ElevatedButton(onPressed: _logout, child: Text('Sign out')),
            ] else ...[
              ElevatedButton(onPressed: _login, child: Text('Sign in')),
            ],
          ],
        ),
      ),
    );
  }
}
```

For a complete, production-ready example, see [example/lib/main.dart](example/lib/main.dart).

### Advanced: Using `GoogleHealthConnector` Directly

For more control (e.g. custom OAuth flow), use `GoogleHealthConnector` directly:

```dart
import 'package:google_flutter_health/google_flutter_health.dart';

// Authorize via custom flow
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

// Fetch data
final manager = GoogleHealthStepsDataManager(
  credentials: credentials!,
  clientID: 'YOUR_CLIENT_ID',
  clientSecret: 'YOUR_CLIENT_SECRET',
);
final result = await manager.fetch(
  GoogleHealthStepsAPIURL.day(date: DateTime.now()),
);

// Always persist the returned credentials (may have been auto-refreshed)
print('Steps: ${result.data.first.count}');
```

---

## Token Management

Every `fetch()` call returns a record `({List<T> data, GoogleHealthCredentials credentials})`. The returned `credentials` may contain a freshly refreshed access token — always save it back to secure storage so the next call starts with a valid token.

```dart
final result = await manager.fetch(url);
await secureStorage.write(key: 'access_token', value: result.credentials.accessToken);
```

Token refresh happens automatically inside `fetch()` when the token is within 60 seconds of expiry. `GoogleHealthTokenExpiredException` is only thrown when the refresh token itself has been revoked.

---

## Scopes

Request only the scopes your app actually uses — the user sees a consent screen listing all requested scopes.

| Constant | Scope URL | Covers |
|----------|-----------|--------|
| `GoogleHealthScopes.activityAndFitnessReadonly` | `googlehealth.activity_and_fitness.readonly` | Steps, distance, calories, active zone minutes, exercise |
| `GoogleHealthScopes.healthMetricsReadonly` | `googlehealth.health_metrics_and_measurements.readonly` | Heart rate, resting HR, HRV, SpO2, weight |
| `GoogleHealthScopes.sleepReadonly` | `googlehealth.sleep.readonly` | Sleep sessions |
| `GoogleHealthScopes.profileReadonly` | `googlehealth.profile.readonly` | User profile and settings |

Write-access variants (`activityAndFitness`, `healthMetrics`, `sleep`, `profile`) are also available but prefer readonly unless you need write access.

---

## Supported Data Types

| Data Type | Manager | URL Builder | Scope |
|-----------|---------|-------------|-------|
| Steps | `GoogleHealthStepsDataManager` | `GoogleHealthStepsAPIURL` | `activityAndFitnessReadonly` |
| Heart Rate | `GoogleHealthHeartRateDataManager` | `GoogleHealthHeartRateAPIURL` | `healthMetricsReadonly` |
| Sleep | `GoogleHealthSleepDataManager` | `GoogleHealthSleepAPIURL` | `sleepReadonly` |
| Profile | `GoogleHealthProfileDataManager` | `GoogleHealthProfileAPIURL` | `profileReadonly` |
| Distance | `GoogleHealthDistanceDataManager` | `GoogleHealthDistanceAPIURL` | `activityAndFitnessReadonly` |
| Calories | `GoogleHealthCaloriesDataManager` | `GoogleHealthCaloriesAPIURL` | `activityAndFitnessReadonly` |
| Active Zone Minutes | `GoogleHealthActiveZoneMinutesDataManager` | `GoogleHealthActiveZoneMinutesAPIURL` | `activityAndFitnessReadonly` |
| Resting Heart Rate | `GoogleHealthRestingHeartRateDataManager` | `GoogleHealthRestingHeartRateAPIURL` | `healthMetricsReadonly` |
| Oxygen Saturation | `GoogleHealthOxygenSaturationDataManager` | `GoogleHealthOxygenSaturationAPIURL` | `healthMetricsReadonly` |
| HRV | `GoogleHealthHrvDataManager` | `GoogleHealthHrvAPIURL` | `healthMetricsReadonly` |
| Weight | `GoogleHealthWeightDataManager` | `GoogleHealthWeightAPIURL` | `healthMetricsReadonly` |
| Exercise | `GoogleHealthExerciseDataManager` | `GoogleHealthExerciseAPIURL` | `activityAndFitnessReadonly` |

---

## Data Types Reference

### Steps

**Model:** `GoogleHealthStepsData`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name (`users/me/dataTypes/steps/dataPoints/...`) |
| `startTime` | `DateTime?` | Start of interval in local time |
| `endTime` | `DateTime?` | End of interval in local time |
| `count` | `int?` | Step count (interval raw count or daily `countSum`) |

**URL builders:**

```dart
GoogleHealthStepsAPIURL.day(date: DateTime.now())
GoogleHealthStepsAPIURL.dateRange(startDate: DateTime(2026, 1, 1), endDate: DateTime(2026, 1, 31))
GoogleHealthStepsAPIURL.intraday(startTime: start, endTime: end)
```

`day()` and `dateRange()` use the `dailyRollup` endpoint — one point per calendar day. `intraday()` uses `dataPoints` and returns individual step events.

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
final steps = result.data.first.count; // e.g. 8432
```

---

### Heart Rate

**Model:** `GoogleHealthHeartRateData`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `sampleTime` | `DateTime?` | Sample timestamp (raw `list` responses) |
| `civilStartTime` | `DateTime?` | Civil-day bucket start (`dailyRollUp`) |
| `civilEndTime` | `DateTime?` | Civil-day bucket end (`dailyRollUp`) |
| `beatsPerMinute` | `int?` | BPM for a single sample (raw responses) |
| `beatsPerMinuteAvg` | `double?` | Average BPM (`dailyRollUp`) |
| `beatsPerMinuteMin` | `double?` | Minimum BPM (`dailyRollUp`) |
| `beatsPerMinuteMax` | `double?` | Maximum BPM (`dailyRollUp`) |

**URL builders:**

```dart
GoogleHealthHeartRateAPIURL.day(date: DateTime.now())
GoogleHealthHeartRateAPIURL.dateRange(startDate: start, endDate: end)
GoogleHealthHeartRateAPIURL.intraday(startTime: start, endTime: end)
```

**Example:**

```dart
final manager = GoogleHealthHeartRateDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthHeartRateAPIURL.intraday(
    startTime: DateTime.now().subtract(const Duration(hours: 1)),
    endTime: DateTime.now(),
  ),
);
for (final point in result.data) {
  print('${point.sampleTime}: ${point.beatsPerMinute} bpm');
}
```

---

### Sleep

**Model:** `GoogleHealthSleepData`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Parent session resource name |
| `startTime` | `DateTime?` | Segment start in local time |
| `endTime` | `DateTime?` | Segment end in local time |
| `stage` | `String?` | `"AWAKE"`, `"LIGHT"`, `"DEEP"`, `"REM"`, `"ASLEEP"`, `"RESTLESS"` |
| `sessionType` | `String?` | `"CLASSIC"` or `"STAGES"` |
| `duration` | `Duration?` | Computed from `endTime - startTime` |

A full night's sleep returns multiple segments — one per stage transition. Sum durations by `stage` to get total time in each stage.

**URL builders:**

```dart
GoogleHealthSleepAPIURL.day(date: DateTime.now())
GoogleHealthSleepAPIURL.dateRange(startDate: start, endDate: end)
GoogleHealthSleepAPIURL.intraday(startTime: start, endTime: end)
```

**Example:**

```dart
final manager = GoogleHealthSleepDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthSleepAPIURL.day(date: DateTime.now()),
);

// Total REM duration
final remMinutes = result.data
    .where((s) => s.stage == 'REM')
    .map((s) => s.duration?.inMinutes ?? 0)
    .fold(0, (a, b) => a + b);
print('REM sleep: $remMinutes minutes');
```

---

### Profile

**Model:** `GoogleHealthProfileData`

The Google Health profile API exposes a narrow set of fields. For display name, photo, etc. use the Google account profile from your sign-in library.

| Field | Type | Description |
|-------|------|-------------|
| `age` | `int?` | User's age in completed years |
| `membershipStartDate` | `String?` | ISO 8601 date the user joined Google Health |
| `userConfiguredWalkingStrideLengthMm` | `int?` | Walking stride length (mm) |
| `userConfiguredRunningStrideLengthMm` | `int?` | Running stride length (mm) |
| `autoWalkingStrideLengthMm` | `int?` | Auto-derived walking stride (mm) |
| `autoRunningStrideLengthMm` | `int?` | Auto-derived running stride (mm) |
| `distanceUnit` | `String?` | `MILES` or `KILOMETERS` |
| `weightUnit` | `String?` | `POUNDS`, `STONE`, or `KILOGRAMS` |
| `heightUnit` | `String?` | `INCHES` or `CENTIMETERS` |
| `temperatureUnit` | `String?` | `CELSIUS` or `FAHRENHEIT` |
| `glucoseUnit` | `String?` | `MG_DL` or `MMOL_L` |
| `swimUnit` | `String?` | `METERS` or `YARDS` |
| `waterUnit` | `String?` | `ML`, `FL_OZ`, or `CUP` |
| `languageLocale` | `String?` | User locale (e.g. `en-US`) |
| `timeZone` | `String?` | IANA time zone |
| `utcOffset` | `String?` | UTC offset duration string (e.g. `-28800s`) |
| `autoStrideEnabled` | `bool?` | Whether automatic stride detection is on |

**URL builders:** `GoogleHealthProfileAPIURL.profile` and `GoogleHealthProfileAPIURL.settings` are static instances (no parameters needed). The manager merges both responses into a single `GoogleHealthProfileData`.

**Example:**

```dart
final manager = GoogleHealthProfileDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
// Pass either URL — the manager fetches both profile and settings internally
final result = await manager.fetch(GoogleHealthProfileAPIURL.profile);
final profile = result.data.first;
print('Age: ${profile.age}, prefers ${profile.distanceUnit}');
```

---

### Distance

**Model:** `GoogleHealthDistanceData`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name (raw responses) |
| `startTime` | `DateTime?` | Interval start in local time |
| `endTime` | `DateTime?` | Interval end in local time |
| `distanceMeters` | `double?` | Distance in meters (interval raw or daily sum) |

**URL builders:**

```dart
GoogleHealthDistanceAPIURL.day(date: DateTime.now())
GoogleHealthDistanceAPIURL.dateRange(startDate: start, endDate: end)
GoogleHealthDistanceAPIURL.intraday(startTime: start, endTime: end)
```

**Example:**

```dart
final manager = GoogleHealthDistanceDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthDistanceAPIURL.day(date: DateTime.now()),
);
final km = (result.data.first.distanceMeters ?? 0) / 1000;
print('Distance today: ${km.toStringAsFixed(2)} km');
```

---

### Calories

**Model:** `GoogleHealthCaloriesData` (`total-calories` data type — rollup endpoints only)

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Interval start in local time |
| `endTime` | `DateTime?` | Interval end in local time |
| `calories` | `double?` | Energy expenditure in kilocalories |

**URL builders:**

```dart
GoogleHealthCaloriesAPIURL.day(date: DateTime.now())
GoogleHealthCaloriesAPIURL.dateRange(startDate: start, endDate: end)
GoogleHealthCaloriesAPIURL.rollUp(
  startTime: start,
  endTime: end,
  windowSize: const Duration(hours: 1),
)
```

**Example:**

```dart
final manager = GoogleHealthCaloriesDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthCaloriesAPIURL.dateRange(
    startDate: DateTime.now().subtract(const Duration(days: 6)),
    endDate: DateTime.now(),
  ),
);
for (final point in result.data) {
  print('${point.startTime}: ${point.calories} kcal');
}
```

---

### Active Zone Minutes

**Model:** `GoogleHealthActiveZoneMinutesData`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Interval start in local time |
| `endTime` | `DateTime?` | Interval end in local time |
| `fatBurnMinutes` | `double?` | Minutes in fat-burn zone |
| `cardioMinutes` | `double?` | Minutes in cardio zone |
| `peakMinutes` | `double?` | Minutes in peak zone |
| `totalMinutes` | `double?` | Total active zone minutes across all zones |

**URL builders:**

```dart
GoogleHealthActiveZoneMinutesAPIURL.day(date: DateTime.now())
GoogleHealthActiveZoneMinutesAPIURL.dateRange(startDate: start, endDate: end)
GoogleHealthActiveZoneMinutesAPIURL.intraday(startTime: start, endTime: end)
```

**Example:**

```dart
final manager = GoogleHealthActiveZoneMinutesDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthActiveZoneMinutesAPIURL.day(date: DateTime.now()),
);
final azm = result.data.first;
print('AZM today — fat burn: ${azm.fatBurnMinutes}, '
    'cardio: ${azm.cardioMinutes}, peak: ${azm.peakMinutes}');
```

---

### Resting Heart Rate

**Model:** `GoogleHealthRestingHeartRateData`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Civil-day start in local time |
| `endTime` | `DateTime?` | Civil-day end in local time |
| `beatsPerMinute` | `double?` | Resting heart rate in bpm |

Resting heart rate is a **daily-aggregated metric** computed by the API and exposed via the `list` endpoint.

**URL builders:**

```dart
GoogleHealthRestingHeartRateAPIURL.day(date: DateTime.now())
GoogleHealthRestingHeartRateAPIURL.dateRange(
  startDate: DateTime.now().subtract(const Duration(days: 6)),
  endDate: DateTime.now(),
)
```

**Example:**

```dart
final manager = GoogleHealthRestingHeartRateDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthRestingHeartRateAPIURL.dateRange(
    startDate: DateTime.now().subtract(const Duration(days: 29)),
    endDate: DateTime.now(),
  ),
);
for (final point in result.data) {
  print('${point.startTime}: ${point.beatsPerMinute} bpm');
}
```

---

### Oxygen Saturation (SpO2)

**Model:** `GoogleHealthOxygenSaturationData`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Civil-day start in local time |
| `endTime` | `DateTime?` | Civil-day end in local time |
| `percentageAvg` | `double?` | Average SpO2 for the day (0–100) |
| `percentageMin` | `double?` | Minimum SpO2 observed (0–100) |
| `percentageMax` | `double?` | Maximum SpO2 observed (0–100) |

SpO2 is a **daily-aggregated metric** exposed via `list`.

**URL builders:**

```dart
GoogleHealthOxygenSaturationAPIURL.day(date: DateTime.now())
GoogleHealthOxygenSaturationAPIURL.dateRange(
  startDate: DateTime.now().subtract(const Duration(days: 6)),
  endDate: DateTime.now(),
)
```

**Example:**

```dart
final manager = GoogleHealthOxygenSaturationDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthOxygenSaturationAPIURL.dateRange(
    startDate: DateTime.now().subtract(const Duration(days: 6)),
    endDate: DateTime.now(),
  ),
);
for (final point in result.data) {
  print('${point.startTime}: avg ${point.percentageAvg}% '
      '(${point.percentageMin}–${point.percentageMax}%)');
}
```

---

### Heart Rate Variability (HRV)

**Model:** `GoogleHealthHrvData`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Civil-day start in local time |
| `endTime` | `DateTime?` | Civil-day end in local time |
| `rmssd` | `double?` | Root mean square of successive differences (ms) |
| `coverage` | `double?` | Fraction of day with valid HRV data (0.0–1.0) |
| `hfPower` | `double?` | High-frequency power band (ms²) |
| `lfPower` | `double?` | Low-frequency power band (ms²) |

HRV is a **daily-aggregated metric** exposed via `list`.

**URL builders:**

```dart
GoogleHealthHrvAPIURL.day(date: DateTime.now())
GoogleHealthHrvAPIURL.dateRange(
  startDate: DateTime.now().subtract(const Duration(days: 6)),
  endDate: DateTime.now(),
)
```

**Example:**

```dart
final manager = GoogleHealthHrvDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthHrvAPIURL.dateRange(
    startDate: DateTime.now().subtract(const Duration(days: 6)),
    endDate: DateTime.now(),
  ),
);
for (final point in result.data) {
  print('${point.startTime}: RMSSD ${point.rmssd} ms');
}
```

---

### Weight

**Model:** `GoogleHealthWeightData`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `sampleTime` | `DateTime?` | Weigh-in timestamp (raw `list` responses) |
| `civilStartTime` | `DateTime?` | Civil-day bucket start (`dailyRollUp`) |
| `civilEndTime` | `DateTime?` | Civil-day bucket end (`dailyRollUp`) |
| `weightKg` | `double?` | Body weight (raw sample or daily average) |
| `weightKgMin` | `double?` | Minimum daily weight (`dailyRollUp`) |
| `weightKgMax` | `double?` | Maximum daily weight (`dailyRollUp`) |

Weight is a sample-based metric — `intraday()` returns raw weigh-ins, `day()` / `dateRange()` return daily aggregates.

**URL builders:**

```dart
GoogleHealthWeightAPIURL.day(date: DateTime.now())
GoogleHealthWeightAPIURL.dateRange(startDate: start, endDate: end)
GoogleHealthWeightAPIURL.intraday(startTime: start, endTime: end)
```

**Example:**

```dart
final manager = GoogleHealthWeightDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthWeightAPIURL.intraday(
    startTime: DateTime.now().subtract(const Duration(days: 29)),
    endTime: DateTime.now(),
  ),
);
for (final point in result.data) {
  print('${point.sampleTime}: ${point.weightKg} kg');
}
```

---

### Exercise

**Model:** `GoogleHealthExerciseData`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String?` | Resource name |
| `startTime` | `DateTime?` | Session start in local time |
| `endTime` | `DateTime?` | Session end in local time |
| `exerciseType` | `String?` | Exercise enum (e.g. `RUNNING`, `WALKING`, `BIKING`) |
| `displayName` | `String?` | Human-readable session name |
| `duration` | `Duration?` | Session duration (computed from start/end) |
| `calories` | `double?` | Energy expenditure in kilocalories |
| `distanceMeters` | `double?` | Distance covered in meters |
| `steps` | `int?` | Step count for the session |

**URL builders:**

```dart
GoogleHealthExerciseAPIURL.day(date: DateTime.now())
GoogleHealthExerciseAPIURL.dateRange(startDate: start, endDate: end)
GoogleHealthExerciseAPIURL.intraday(startTime: start, endTime: end)
```

**Example:**

```dart
final manager = GoogleHealthExerciseDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthExerciseAPIURL.dateRange(
    startDate: DateTime.now().subtract(const Duration(days: 29)),
    endDate: DateTime.now(),
  ),
);
for (final session in result.data) {
  final mins = session.duration?.inMinutes ?? 0;
  print('${session.startTime}: ${session.exerciseType} '
      '$mins min, '
      '${session.distanceMeters != null ? "${(session.distanceMeters! / 1000).toStringAsFixed(2)} km" : ""}');
}
```

---

## Pagination & Time Range Limits

* The Google Health API returns up to 1,440 data points per page (25 for
  `exercise` / `sleep`). When the response contains a `nextPageToken`,
  this library currently returns only the first page — fetch subsequent
  pages manually by appending `&pageToken=…` to the URL.
* List queries are capped at **14 days** for `heart-rate`,
  `active-minutes`, `total-calories`, and `calories-in-heart-rate-zone`,
  and **90 days** for all other types. Split larger windows yourself.

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

Contributions are welcome! Please open an issue before submitting a PR to discuss the change. Make sure to:

1. Run `dart analyze --fatal-infos` — zero warnings required.
2. Run `flutter test` — all tests must pass.
3. Run `dart format --set-exit-if-changed lib test` — code must be formatted.
4. Add tests for any new data type following the existing pattern.

---

## License

BSD-3-Clause — see [LICENSE](LICENSE).
