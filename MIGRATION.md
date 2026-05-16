# Migrating from Fitbitter to google_flutter_health

---

## Why migrate

Google acquired Fitbit in 2021 and is consolidating all health data into the
[Google Health platform](https://developers.google.com/health). The Fitbit Web
API is being deprecated: new OAuth applications can no longer be registered on
Fitbit's developer portal, and existing applications are being migrated to
Google's infrastructure on a rolling basis.

Official migration resources:

- [Google's Fitbit API migration guide](https://developers.google.com/fit/rest/v1/get-started) — Fitbit
  developers are directed to the Google Health API as the successor.
- [Google Health REST API reference](https://developers.google.com/health/reference/rest)

`google_flutter_health` provides a Flutter-native replacement for
`fitbitter`. The architecture is deliberately parallel — if you know Fitbitter
you will be productive in minutes. The same three-layer pattern (connector /
manager / URL builder) applies, and credentials are still developer-managed
with no automatic storage.

---

## Installation

Edit your `pubspec.yaml`. Remove `fitbitter` and add `google_flutter_health`:

```diff
 dependencies:
   flutter:
     sdk: flutter
-  fitbitter: ^2.0.0
+  google_flutter_health: ^0.1.0
+  google_sign_in: ^7.0.0          # for interactive sign-in on Android / iOS
+  flutter_secure_storage: ^10.0.0 # for persisting credentials
```

Then run:

```sh
flutter pub get
```

> **Note:** `google_sign_in` replaces `flutter_web_auth_2` which Fitbitter used
> for the OAuth browser flow. Google deprecated the loopback IP and custom URI
> scheme flows on Android (Oct 2022); `google_sign_in` v7 is the correct
> replacement on mobile.

---

## Authentication

### `authorize()`

**Fitbitter:**

```dart
FitbitCredentials? fitbitCredentials = await FitbitConnector.authorize(
  clientID: Strings.fitbitClientID,
  clientSecret: Strings.fitbitClientSecret,
  redirectUri: Strings.fitbitRedirectUri,
  callbackUrlScheme: Strings.fitbitCallbackScheme,
);
```

**google_flutter_health (custom OAuth flow):**

```dart
GoogleHealthCredentials? credentials = await GoogleHealthConnector.authorize(
  clientID: 'YOUR_CLIENT_ID',
  clientSecret: 'YOUR_CLIENT_SECRET',
  redirectUri: 'com.example.myapp:/oauth2redirect',
  scopes: [
    GoogleHealthScopes.activityAndFitnessReadonly,
    GoogleHealthScopes.healthMetricsReadonly,
  ],
  launchBrowserAndGetRedirect: (Uri authUri) async {
    // Open authUri in a browser and return the full redirect URL.
    // Use flutter_web_auth_2, url_launcher, or your own implementation.
    return await FlutterWebAuth2.authenticate(
      url: authUri.toString(),
      callbackUrlScheme: 'com.example.myapp',
    );
  },
);
```

**google_flutter_health (recommended on Android / iOS with `google_sign_in`):**

```dart
// See example/lib/google_sign_in_service.dart — copy it into your project.
final auth = GoogleSignInService(
  webClientID: 'YOUR_WEB_CLIENT_ID',
  webClientSecret: 'YOUR_WEB_CLIENT_SECRET',
  scopes: [GoogleHealthScopes.activityAndFitnessReadonly],
);
await auth.initialize();
await auth.login();                        // opens Google's native sign-in UI
final credentials = auth.session.credentials; // GoogleHealthCredentials
```

Key differences:

| | Fitbitter | google_flutter_health |
|---|---|---|
| Auth class | `FitbitConnector` (singleton) | `GoogleHealthConnector` (static methods) |
| Browser flow | `flutter_web_auth_2` built-in | caller-provided callback |
| Recommended mobile flow | `flutter_web_auth_2` | `google_sign_in` v7 |
| Cloud setup | Fitbit developer portal | Google Cloud Console |

---

### `refreshToken()`

**Fitbitter:**

```dart
FitbitCredentials? refreshed = await FitbitConnector.refreshToken(
  credentials: fitbitCredentials,
);
```

**google_flutter_health:**

```dart
GoogleHealthCredentials? refreshed = await GoogleHealthConnector.refreshToken(
  credentials: credentials,
  clientID: 'YOUR_CLIENT_ID',
  clientSecret: 'YOUR_CLIENT_SECRET',
);
```

> In practice you rarely need to call `refreshToken()` directly —
> every `manager.fetch()` call refreshes the token automatically when it is
> expired. See [Key differences — fetch() return type](#2-fetchreturn-type) below.

---

### `FitbitCredentials` → `GoogleHealthCredentials`

**Fitbitter fields:**

```dart
class FitbitCredentials {
  String userID;
  String fitbitAccessToken;
  String fitbitRefreshToken;
  // No built-in expiry check
}
```

**google_flutter_health fields:**

```dart
class GoogleHealthCredentials {
  String userID;
  String accessToken;          // renamed — no "fitbit" prefix
  String refreshToken;         // renamed — no "fitbit" prefix
  DateTime accessTokenExpirationDateTime; // UTC — new field
  List<String> scopes;         // new field
  bool get isExpired { ... }   // built-in, with 60-second buffer
}
```

Rename all field accesses:

| Fitbitter | google_flutter_health |
|---|---|
| `credentials.fitbitAccessToken` | `credentials.accessToken` |
| `credentials.fitbitRefreshToken` | `credentials.refreshToken` |
| `credentials.userID` | `credentials.userID` (unchanged) |
| *(no expiry field)* | `credentials.accessTokenExpirationDateTime` |
| *(no built-in check)* | `credentials.isExpired` |

**Serialization** works the same way — both libraries use manual `fromJson` /
`toJson`. Update your secure storage keys to match the new field names:

```dart
// OLD — Fitbitter
await storage.write(key: 'fitbitAccessToken', value: creds.fitbitAccessToken);
await storage.write(key: 'fitbitRefreshToken', value: creds.fitbitRefreshToken);

// NEW — google_flutter_health
final json = jsonEncode(credentials.toJson());
await storage.write(key: 'google_health_credentials', value: json);

// Restore
final raw = await storage.read(key: 'google_health_credentials');
final credentials = GoogleHealthCredentials.fromJson(jsonDecode(raw!));
```

---

### Token storage

Token storage is **still developer-managed** — no change in philosophy from
Fitbitter 2.0. What changes is that you must also re-persist after every
`fetch()` call, because `fetch()` may have refreshed the access token
transparently. See [Key differences — credentials must be re-persisted](#1-access-token-lifetime).

---

## Data types mapping

| Fitbitter class | google_flutter_health class | Notes |
|---|---|---|
| `FitbitActivityTimeseriesDataManager` (type: `'steps'`) | `GoogleHealthStepsDataManager` | Dedicated manager per type |
| `FitbitActivityTimeseriesDataManager` (type: `'distance'`) | `GoogleHealthDistanceDataManager` | Field renamed: see below |
| `FitbitActivityTimeseriesDataManager` (type: `'calories'`) | `GoogleHealthCaloriesDataManager` | Field renamed: see below |
| `FitbitActivityTimeseriesDataManager` (type: `'active-zone-minutes'`) | `GoogleHealthActiveZoneMinutesDataManager` | Broken into zone fields |
| `FitbitHeartRateDataManager` | `GoogleHealthHeartRateDataManager` | Field renamed: `value` → `bpm` |
| `FitbitHeartRateDataManager` (resting) | `GoogleHealthRestingHeartRateDataManager` | Dedicated manager, daily-only |
| `FitbitHeartRateVariabilityDataManager` | `GoogleHealthHrvDataManager` | Field renamed: `rmssd` unchanged |
| `FitbitSleepDataManager` | `GoogleHealthSleepDataManager` | Stage strings differ |
| `FitbitAccountDataManager` | `GoogleHealthProfileDataManager` | Fewer fields — see below |
| `FitbitSpO2DataManager` | `GoogleHealthOxygenSaturationDataManager` | Field renamed: see below |
| `FitbitBodyWeightDataManager` | `GoogleHealthWeightDataManager` | No `day()` builder |
| `FitbitActivityDataManager` | `GoogleHealthExerciseDataManager` | Uses `startTime`/`endTime` |

---

### Steps

**Fitbitter:**

```dart
final manager = FitbitActivityTimeseriesDataManager(
  clientID: clientID,
  clientSecret: clientSecret,
  type: 'steps',
);
final data = await manager.fetch(
  FitbitActivityTimeseriesAPIURL.dayWithResource(
    date: DateTime.now(),
    userID: fitbitCredentials.userID,
    resource: 'steps',
    fitbitCredentials: fitbitCredentials,
  ),
) as List<FitbitActivityTimeseriesData>;
final steps = data.first.value; // int?
```

**google_flutter_health:**

```dart
final manager = GoogleHealthStepsDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthStepsAPIURL.day(date: DateTime.now()),
);
final steps = result.data.first.value; // int?
```

Field changes: `userID` (same), `dateTime` (same), `value` (same, step count as `int?`).

---

### Heart Rate

**Fitbitter:**

```dart
final manager = FitbitHeartRateDataManager(
  clientID: clientID,
  clientSecret: clientSecret,
);
final data = await manager.fetch(
  FitbitHeartRateAPIURL.day(
    date: DateTime.now(),
    fitbitCredentials: fitbitCredentials,
  ),
) as List<FitbitHeartRateData>;
final bpm = data.first.value; // average BPM
```

**google_flutter_health:**

```dart
final manager = GoogleHealthHeartRateDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthHeartRateAPIURL.day(date: DateTime.now()),
);
final bpm = result.data.first.bpm; // renamed: value → bpm
```

Field changes: `value` → `bpm` (`double?`).

---

### Sleep

**Fitbitter:**

```dart
final manager = FitbitSleepDataManager(
  clientID: clientID,
  clientSecret: clientSecret,
);
final data = await manager.fetch(
  FitbitSleepAPIURL.listAndBeforeDate(
    beforeDate: DateTime.now(),
    limit: 1,
    fitbitCredentials: fitbitCredentials,
  ),
) as List<FitbitSleepData>;
```

**google_flutter_health:**

```dart
final manager = GoogleHealthSleepDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthSleepAPIURL.day(date: DateTime.now()),
);
// Each element is one sleep stage segment:
// result.data.first.sleepStage → "light" | "deep" | "rem" | "awake"
// result.data.first.startTime, endTime, duration
```

Field changes: Fitbitter uses `level` for stage names; google_flutter_health uses
`sleepStage` with values `"light"`, `"deep"`, `"rem"`, `"awake"`.

---

### Profile

**Fitbitter:**

```dart
final manager = FitbitAccountDataManager(
  clientID: clientID,
  clientSecret: clientSecret,
);
final data = await manager.fetch(
  FitbitAccountAPIURL(fitbitCredentials: fitbitCredentials),
) as List<FitbitAccountData>;
final name = data.first.displayName;
```

**google_flutter_health:**

```dart
final manager = GoogleHealthProfileDataManager(
  credentials: credentials,
  clientID: clientID,
  clientSecret: clientSecret,
);
final result = await manager.fetch(GoogleHealthProfileAPIURL.profile);
final name = result.data.first.displayName;
```

`FitbitAccountData` has 47+ fields (many Fitbit-specific). `GoogleHealthProfileData`
covers the core set: `displayName`, `givenName`, `familyName`, `birthdate`,
`heightCm`, `weightKg`, `sex`, `locale`, `timezone`.

---

### Distance

**Fitbitter:**

```dart
final manager = FitbitActivityTimeseriesDataManager(
  clientID: clientID, clientSecret: clientSecret, type: 'distance',
);
final data = await manager.fetch(
  FitbitActivityTimeseriesAPIURL.dayWithResource(
    date: DateTime.now(), userID: uid, resource: 'distance',
    fitbitCredentials: fitbitCredentials,
  ),
) as List<FitbitActivityTimeseriesData>;
final km = data.first.value; // km as double?
```

**google_flutter_health:**

```dart
final manager = GoogleHealthDistanceDataManager(
  credentials: credentials, clientID: clientID, clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthDistanceAPIURL.day(date: DateTime.now()),
);
final meters = result.data.first.distanceMeters; // meters — unit changed!
final km = (meters ?? 0) / 1000;
```

**Unit change:** Fitbitter returns kilometres; google_flutter_health returns
**metres** (`distanceMeters`). Divide by 1000 to restore kilometres.

---

### Calories

**Fitbitter:**

```dart
final manager = FitbitActivityTimeseriesDataManager(
  clientID: clientID, clientSecret: clientSecret, type: 'calories',
);
final data = await manager.fetch(...) as List<FitbitActivityTimeseriesData>;
final kcal = data.first.value; // double?
```

**google_flutter_health:**

```dart
final manager = GoogleHealthCaloriesDataManager(
  credentials: credentials, clientID: clientID, clientSecret: clientSecret,
);
final result = await manager.fetch(
  GoogleHealthCaloriesAPIURL.day(date: DateTime.now()),
);
final kcal = result.data.first.calories; // renamed: value → calories (double?)
```

Field changes: `value` → `calories`.

---

### Active Zone Minutes

**Fitbitter:**

```dart
// Returned as a single value
final kcal = data.first.value; // total AZM as double?
```

**google_flutter_health:**

```dart
final result = await manager.fetch(
  GoogleHealthActiveZoneMinutesAPIURL.day(date: DateTime.now()),
);
final azm = result.data.first;
// azm.fatBurnMinutes, azm.cardioMinutes, azm.peakMinutes, azm.totalMinutes
```

AZM is now broken out by zone. Use `totalMinutes` to replicate the old single
value.

---

### Oxygen Saturation (SpO2)

**Fitbitter:**

```dart
final data = await manager.fetch(...) as List<FitbitSpO2Data>;
final avg = data.first.value; // daily average (double?)
```

**google_flutter_health:**

```dart
final result = await manager.fetch(
  GoogleHealthOxygenSaturationAPIURL.dailyRollup(
    startDate: DateTime.now(), endDate: DateTime.now(),
  ),
);
final spo2 = result.data.first;
// spo2.spo2Percentage (avg), spo2.spo2Low, spo2.spo2High
```

Field changes: `value` → `spo2Percentage`. Low/high range fields are new.

---

### HRV

**Fitbitter:**

```dart
final data = await manager.fetch(...) as List<FitbitHeartRateVariabilityData>;
final rmssd = data.first.dailyRmssd; // double?
```

**google_flutter_health:**

```dart
final result = await manager.fetch(
  GoogleHealthHrvAPIURL.dailyRollup(
    startDate: DateTime.now(), endDate: DateTime.now(),
  ),
);
final rmssd = result.data.first.rmssd; // renamed: dailyRmssd → rmssd
```

Field changes: `dailyRmssd` → `rmssd`. New fields: `coverage`, `hfPower`,
`lfPower`.

---

### Weight

**Fitbitter:**

```dart
final data = await manager.fetch(...) as List<FitbitBodyWeightData>;
final kg = data.first.weight; // double?
```

**google_flutter_health:**

```dart
final result = await manager.fetch(
  GoogleHealthWeightAPIURL.dateRange(
    startDate: start, endDate: end,
  ),
);
final kg = result.data.first.weightKg; // renamed: weight → weightKg
```

Field changes: `weight` → `weightKg`. New fields: `bmi`, `bodyFatPercentage`.

---

### Exercise

**Fitbitter:**

```dart
final data = await manager.fetch(...) as List<FitbitActivityData>;
final duration = data.first.duration; // minutes
final type = data.first.activityName; // string
```

**google_flutter_health:**

```dart
final result = await manager.fetch(
  GoogleHealthExerciseAPIURL.dateRange(startDate: start, endDate: end),
);
final session = result.data.first;
// session.startTime, session.endTime
// session.activityType  (renamed: activityName → activityType)
// session.durationMillis (unit changed: minutes → milliseconds)
// session.calories, session.distanceMeters, session.steps
```

Field changes: `activityName` → `activityType`; duration unit changed from
minutes to **milliseconds** (`durationMillis`). Divide by `60000` to convert
to minutes.

---

## Key differences to be aware of

### 1. Access token lifetime

| | Fitbitter | google_flutter_health |
|---|---|---|
| Token lifetime | **8 hours** | **1 hour** |
| Refresh strategy | Manual or via `getResponse()` | Automatic inside every `fetch()` |
| Expiry check | `FitbitConnector.isTokenValid()` | `credentials.isExpired` (built-in) |

`fetch()` handles refresh automatically — you do not need to check or refresh
before calling it. However, **you must re-persist the returned credentials
after every `fetch()` call**, because the token may have been refreshed:

```dart
final result = await manager.fetch(url);

// Always save the returned credentials back to storage:
await storage.write(
  key: 'google_health_credentials',
  value: jsonEncode(result.credentials.toJson()),
);
```

If you skip this step, the in-memory credentials fall out of sync with your
stored credentials and you will eventually start fetch calls with an expired
token.

---

### 2. `fetch()` return type

**Fitbitter** returns `Future<List<FitbitData>>`:

```dart
// Old
List<FitbitActivityTimeseriesData> data = await manager.fetch(url)
    as List<FitbitActivityTimeseriesData>;
final steps = data.first.value;
```

**google_flutter_health** returns a Dart record
`Future<({List<T> data, GoogleHealthCredentials credentials})>`:

```dart
// New — destructure the record
final result = await manager.fetch(url);
final steps = result.data.first.value;
final updatedCredentials = result.credentials; // persist this
```

You can also destructure inline:

```dart
final (:data, :credentials) = await manager.fetch(url);
```

---

### 3. Scope strings

Fitbit and Google Health use completely different scope identifiers.

| Fitbit scope | Google Health constant | Scope URL |
|---|---|---|
| `activity` | `GoogleHealthScopes.activityAndFitnessReadonly` | `googlehealth.activity_and_fitness.readonly` |
| `heartrate` | `GoogleHealthScopes.healthMetricsReadonly` | `googlehealth.health_metrics_and_measurements.readonly` |
| `sleep` | `GoogleHealthScopes.sleepReadonly` | `googlehealth.sleep.readonly` |
| `profile` | `GoogleHealthScopes.profileReadonly` | `googlehealth.profile.readonly` |
| `weight` | `GoogleHealthScopes.healthMetricsReadonly` | `googlehealth.health_metrics_and_measurements.readonly` |
| `location` | `GoogleHealthScopes.locationReadonly` | `googlehealth.location.readonly` |
| `nutrition` | `GoogleHealthScopes.nutritionReadonly` | `googlehealth.nutrition.readonly` |
| `settings` | `GoogleHealthScopes.profileReadonly` | `googlehealth.profile.readonly` |
| `social` | *(no equivalent)* | — |

Use the constants from `GoogleHealthScopes` rather than raw strings:

```dart
// Old — Fitbitter
final scopes = ['activity', 'heartrate', 'sleep'];

// New — google_flutter_health
final scopes = [
  GoogleHealthScopes.activityAndFitnessReadonly,
  GoogleHealthScopes.healthMetricsReadonly,
  GoogleHealthScopes.sleepReadonly,
];
```

---

### 4. User ID

**Fitbitter** returned the user ID as part of `FitbitCredentials` automatically.

**google_flutter_health** separates this into two steps. After `authorize()`,
call `getUserId()` to retrieve the Google Health user ID. In practice,
`GoogleHealthConnector.exchangeAuthCode()` calls `getUserId()` automatically
and populates `credentials.userID` for you — so by the time you hold a
`GoogleHealthCredentials` object, `userID` is already populated.

You do **not** need to pass `userID` to URL builders — they always use
`users/me` (resolved from the access token on the server side).

---

### 5. No more `isTokenValid()`

**Fitbitter** had `FitbitConnector.isTokenValid(credentials)` which made a
live API call to check validity.

**google_flutter_health** uses `credentials.isExpired`, a local computation
based on `accessTokenExpirationDateTime` with a 60-second buffer. No network
call required.

```dart
// Old
if (await FitbitConnector.isTokenValid(fitbitCredentials)) { ... }

// New
if (!credentials.isExpired) { ... }
// Or just let fetch() handle it — no manual check needed.
```

---

## Step by step migration checklist

1. **Update `pubspec.yaml`** — remove `fitbitter`, add `google_flutter_health`,
   `google_sign_in: ^7.0.0`, `flutter_secure_storage: ^10.0.0`.

2. **Create Google Cloud Console project and get credentials** — follow the
   [Google Cloud Console Setup](README.md#google-cloud-console-setup) section in
   the README. You need a Web OAuth client ID + secret, and platform-specific
   OAuth clients for Android and/or iOS.

3. **Update Android setup** — see
   [Android Setup](README.md#android-setup) in the README. The package name in
   `AndroidManifest.xml` must match the Android client you created in the Cloud
   Console.

4. **Update iOS setup** — see
   [iOS Setup](README.md#ios-setup) in the README. The bundle ID must match the
   iOS client.

5. **Replace `authorize()` call** — swap `FitbitConnector.authorize()` for
   `GoogleHealthConnector.authorize()` (custom flow) or `GoogleSignInService`
   (recommended on mobile). Update the scope list using `GoogleHealthScopes`
   constants.

6. **Update credentials storage** — replace field names
   (`fitbitAccessToken` → `accessToken`, `fitbitRefreshToken` → `refreshToken`)
   and add storage for the new `accessTokenExpirationDateTime` and `scopes`
   fields. Use `credentials.toJson()` / `GoogleHealthCredentials.fromJson()`.

7. **Replace each data manager one by one** — use the
   [Data types mapping](#data-types-mapping) table above. Each `FitbitXxxDataManager`
   becomes a `GoogleHealthXxxDataManager`. Remove the `type:` constructor
   argument — each manager is now dedicated to one data type.

8. **Update `fetch()` call sites to destructure the record** — change
   `List<FitbitXxxData> data = await manager.fetch(url) as List<...>` to
   `final result = await manager.fetch(url)` and access `result.data` and
   `result.credentials`.

9. **Re-persist credentials after every `fetch()`** — save
   `result.credentials.toJson()` back to secure storage after every call,
   because the access token may have been refreshed transparently.

10. **Fix field name renames** — review the field changes listed in each data
    type section above. Key renames: `value` → `bpm` (heart rate), `value` →
    `calories`, `value` → `spo2Percentage`, `weight` → `weightKg`,
    `activityName` → `activityType`, `distanceMeters` unit metres not
    kilometres.

11. **Run quality gates** before committing:
    ```sh
    dart analyze --fatal-infos
    dart test
    dart format --set-exit-if-changed lib test
    ```

---

## Getting help

- **Issues:** [github.com/DFerrari13/google_flutter_health/issues](https://github.com/DFerrari13/google_flutter_health/issues)
- **Original Fitbitter repo:** [github.com/gcappon/fitbitter](https://github.com/gcappon/fitbitter) — credit to Giacomo Cappon for the architecture this package mirrors.
- **Google Health API reference:** [developers.google.com/health/reference/rest](https://developers.google.com/health/reference/rest)
- **Google's official Fitbit migration guide:** [developers.google.com/fit/rest/v1/get-started](https://developers.google.com/fit/rest/v1/get-started)
