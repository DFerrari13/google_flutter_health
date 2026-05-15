# fitbitter — Architecture Summary

## Package Structure

```
lib/
  fitbitter.dart              ← single barrel export
  src/
    fitbitConnector.dart      ← OAuth2 singleton
    managers/                 ← one manager per Fitbit resource
    urls/                     ← one URL builder per resource
    data/                     ← data model classes
    errors/                   ← typed exception hierarchy
    utils/                    ← date formatting helpers
test/
  fitbitter_test.dart         ← placeholder only (expect(1,1))
example/                      ← Flutter demo app
```

**Key deps:** `dio ^5.7.0` (HTTP), `flutter_web_auth_2 ^4.1.0` (OAuth), `intl ^0.20.1` (dates), `logger ^2.5.0`.

---

## Class Hierarchy

Three parallel abstract → concrete trees:

```
FitbitData (abstract)
  FitbitAccountData            FitbitActivityData
  FitbitActivityTimeseriesData FitbitHeartRateData
  FitbitHeartRateIntradayData  FitbitHeartRateVariabilityData
  FitbitSleepData              FitbitDeviceData
  FitbitBreathingRateData      FitbitCardioScoreData
  FitbitSpO2Data               FitbitSpO2IntradayData
  FitbitTemperatureSkinData

FitbitDataManager (abstract)  ← one concrete subclass per resource
  fetch(FitbitAPIURL) → Future<List<FitbitData>>
  getResponse(url)             ← shared HTTP + token-check logic
  static manageError(DioException) → throws typed FitbitException

FitbitAPIURL (abstract)        ← one concrete subclass per resource
  String url
  FitbitCredentials? fitbitCredentials
```

---

## Auth Flow (`fitbitConnector.dart`)

`FitbitConnector` is a **singleton**. `FitbitCredentials` is a plain value object (`userID`, `fitbitAccessToken`, `fitbitRefreshToken` + `copyWith()`).

```
authorize()
  └─ FlutterWebAuth2.authenticate()     # opens native browser
  └─ extract code from callback URL
  └─ POST /oauth2/token (code exchange)
  └─ return FitbitCredentials            # caller owns storage

refreshToken(credentials)
  └─ POST /oauth2/token (grant_type=refresh_token)
  └─ return updated FitbitCredentials

isTokenValid(credentials) → bool        # 401 → false
unauthorize(credentials)               # POST to revocation endpoint
```

Token storage is **caller-managed** (no automatic persistence since v2.0).

---

## Data Managers

Each concrete manager:
1. Takes `(clientID, clientSecret)` in constructor.
2. Implements `fetch(FitbitAPIURL url)`:
   - Calls `getResponse()` → validates/refreshes token → `dio.get()` with `Authorization: Bearer`.
   - Parses JSON into typed `List<FitbitData>`.

Error mapping in `manageError()`:

| HTTP | Exception |
|---|---|
| 400 | `FitbitBadRequestException` |
| 401 | `FitbitUnauthorizedException` |
| 403 | `FitbitForbiddenException` |
| 404 | `FitbitNotFoundException` |
| 429 | `FitbitRateLimitExceededException` |

---

## URL Builders

Each `FitbitXxxAPIURL` has **static factory methods** for different time windows:

```dart
// Activity timeseries example
FitbitActivityTimeseriesAPIURL.dayWithResource(date, Resource.steps, creds)
  → https://api.fitbit.com/1/user/{uid}/activities/steps/date/{date}/1d.json

FitbitActivityTimeseriesAPIURL.dateRangeWithResource(start, end, Resource.calories, creds)
FitbitActivityTimeseriesAPIURL.weekWithResource(...)   // 1w.json
FitbitActivityTimeseriesAPIURL.monthWithResource(...)  // 1m.json
// … 3m, 6m, 1y variants

// Intraday (heart rate / SpO2)
FitbitHeartRateIntradayAPIURL.dayAndDetailLevel(date, IntradayDetailLevel.ONE_MINUTE, creds)
// detail levels: ONE_SECOND | ONE_MINUTE | FIVE_MINUTES | FIFTEEN_MINUTES

// Sleep
FitbitSleepAPIURL.listAndBeforeDate(date, limit, creds)  // paginated
FitbitSleepAPIURL.listAndAfterDate(date, limit, creds)
```

API version is `v1` for most resources, `v1.2` for sleep.

---

## Data Models

All models share the same structure:

```dart
class FitbitXxxData extends FitbitData {
  final String? userID;
  final DateTime? dateOfMonitoring;
  // ... resource-specific fields ...

  FitbitXxxData({this.userID, this.dateOfMonitoring, ...});
  factory FitbitXxxData.fromJson(Map<String, dynamic> json) { ... }
  @override Map<String, dynamic> toJson() { ... }
  @override String toString() { ... }   // StringBuffer-based
}
```

**14 concrete models** covering: account/profile, activity log, activity timeseries, heart rate (daily + intraday), HRV (RMSSD daily + deep), sleep stages, device info, SpO2 (daily + intraday), breathing rate, cardio score (VO2 max), skin temperature.

`FitbitAccountData` is the heaviest — 47+ nullable fields (demographics, unit prefs, feature flags).

---

## Test Patterns

**Current state: minimal.** `test/fitbitter_test.dart` contains one placeholder:

```dart
test('placeholder', () { expect(1, 1); });
```

No mocking library is wired up. The architecture would support:
- Unit tests on URL builders (assert constructed URL strings)
- Manager tests with a mocked `Dio` or `HttpClient`
- Model round-trip tests (`fromJson` → `toJson` equality)

---

## Integration Flow (end-to-end example)

```
1. FitbitConnector.authorize()               → FitbitCredentials
2. FitbitActivityTimeseriesAPIURL.dayWithResource(date, Resource.steps, creds)
                                             → FitbitActivityTimeseriesAPIURL
3. FitbitActivityTimeseriesDataManager(clientID, clientSecret)
   .fetch(url)
     ├─ _checkAccessToken()                  → refresh if expired
     ├─ dio.get(url.url, headers: Bearer…)
     ├─ _extractFitbitActivityTimeseriesData(response)
     └─ List<FitbitActivityTimeseriesData>
```

---

## Design Summary

Clean 3-layer separation — *URL builders* construct endpoints, *managers* own HTTP + token logic, *models* own JSON mapping. Auth is a separate singleton. No code generation (all serialization is manual). Tests are essentially absent.
