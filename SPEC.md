# google_flutter_health — Package Specification

> **Status:** Ready for Phase 3.
> All decisions resolved. No TODOs remain.
> Claude Code reads this file alongside `FITBITTER_ANALYSIS.md` at the start of every session.

---

## 1. Package Identity

| Field | Value |
|-------|-------|
| **Package name** | `google_flutter_health` |
| **Pub.dev description** | A Flutter package to make your life easier when dealing with the Google Health API. The spiritual successor to Fitbitter. |
| **License** | BSD-3-Clause (mirrors Fitbitter) |
| **Dart SDK constraint** | `>=3.0.0 <4.0.0` |
| **Flutter constraint** | `>=3.10.0` |
| **Initial version** | `0.1.0` |
| **Topics (pub.dev)** | `health`, `fitbit`, `google-health`, `flutter`, `wearable` |
| **Platforms** | Android, iOS (mobile only — no Web) |

---

## 2. Architecture Reference

Naming convention mirrors Fitbitter exactly. See `FITBITTER_ANALYSIS.md` for method signatures, constructor patterns, and test conventions.

| Fitbitter class | google_flutter_health equivalent |
|----------------|----------------------------------|
| `FitbitConnector` | `GoogleHealthConnector` |
| `FitbitCredentials` | `GoogleHealthCredentials` |
| `FitbitDataManager` (abstract) | `GoogleHealthDataManager` (abstract) |
| `FitbitActivityTimeseriesDataManager` | `GoogleHealthStepsDataManager` *(example)* |
| `FitbitActivityTimeseriesAPIURL` | `GoogleHealthStepsAPIURL` *(example)* |
| `FitbitActivityTimeseriesData` | `GoogleHealthStepsData` *(example)* |

### File layout

```
lib/
  google_flutter_health.dart          # barrel export — exports everything public
  src/
    connectors/
      google_health_connector.dart    # auth, token refresh, user identity
      google_health_credentials.dart  # token model + serialization
      google_health_scopes.dart       # scope string constants
    managers/
      google_health_data_manager.dart              # abstract base
      google_health_steps_data_manager.dart
      google_health_heart_rate_data_manager.dart
      google_health_sleep_data_manager.dart
      google_health_profile_data_manager.dart
      google_health_distance_data_manager.dart
      google_health_calories_data_manager.dart
      google_health_active_zone_minutes_data_manager.dart
      google_health_resting_heart_rate_data_manager.dart
      google_health_oxygen_saturation_data_manager.dart
      google_health_hrv_data_manager.dart
      google_health_weight_data_manager.dart
      google_health_exercise_data_manager.dart
    urls/
      google_health_api_url.dart                   # abstract base
      google_health_steps_api_url.dart
      google_health_heart_rate_api_url.dart
      google_health_sleep_api_url.dart
      google_health_profile_api_url.dart
      google_health_distance_api_url.dart
      google_health_calories_api_url.dart
      google_health_active_zone_minutes_api_url.dart
      google_health_resting_heart_rate_api_url.dart
      google_health_oxygen_saturation_api_url.dart
      google_health_hrv_api_url.dart
      google_health_weight_api_url.dart
      google_health_exercise_api_url.dart
    data/
      google_health_steps_data.dart
      google_health_heart_rate_data.dart
      google_health_sleep_data.dart
      google_health_profile_data.dart
      google_health_distance_data.dart
      google_health_calories_data.dart
      google_health_active_zone_minutes_data.dart
      google_health_resting_heart_rate_data.dart
      google_health_oxygen_saturation_data.dart
      google_health_hrv_data.dart
      google_health_weight_data.dart
      google_health_exercise_data.dart
    exceptions/
      google_health_exceptions.dart
example/
  lib/
    main.dart                         # minimal demo: auth + fetch steps
test/
  connectors/
    google_health_connector_test.dart
    google_health_credentials_test.dart
  managers/
    google_health_steps_data_manager_test.dart
    # ... one file per manager
  urls/
    google_health_steps_api_url_test.dart
    # ... one file per URL builder
  data/
    google_health_steps_data_test.dart
    # ... one file per data model
```

---

## 3. Authentication

### 3.1 Library choice: `googleapis_auth`

Use the [`googleapis_auth`](https://pub.dev/packages/googleapis_auth) package.
- Reason: lower-level, more control over token lifecycle; aligns with the Fitbitter pattern of explicit credential management where the developer owns the tokens.
- Does **not** auto-manage tokens in the background (consistent with Fitbitter 2.0 "no auto-storage" philosophy).
- Works on Android and iOS without platform-specific setup beyond Google Cloud Console credentials.

### 3.2 OAuth2 Parameters

| Parameter | Value |
|-----------|-------|
| Auth URL | `https://accounts.google.com/o/oauth2/v2/auth` |
| Token URL | `https://oauth2.googleapis.com/token` |
| Required query param | `access_type=offline` (to receive a refresh token) |
| Access token lifetime | **1 hour** — much shorter than Fitbit's 8h |
| Refresh token lifetime | Expires after 6 months of non-use |
| Token size | Up to 2048 bytes |

### 3.3 Automatic Token Refresh

**Refresh is automatic and transparent, handled inside `fetch()`.**

Every `DataManager.fetch()` call checks whether the access token is expired (or will expire within a 60-second buffer) before making the API request. If so, it calls `GoogleHealthConnector.refreshToken()` internally and returns updated `GoogleHealthCredentials` alongside the data.

`fetch()` signature therefore returns a Dart record, not just data:

```dart
// Abstract base
Future<({List<T> data, GoogleHealthCredentials credentials})> fetch(
  GoogleHealthAPIURL url,
);
```

This lets the developer persist the refreshed credentials without needing to handle refresh separately. Mirrors how Fitbitter handled this in v1 but with the explicit credential-return pattern of v2.

### 3.4 `GoogleHealthConnector` Public API

```dart
class GoogleHealthConnector {

  /// Opens a browser/webview for the user to authorise the app.
  /// Returns credentials on success, null if the user cancels.
  static Future<GoogleHealthCredentials?> authorize({
    required String clientID,
    required String clientSecret,
    required String redirectUri,
    required List<String> scopes,
  });

  /// Exchanges a refresh token for a new access token.
  /// Called automatically inside fetch() — but also available to developers.
  static Future<GoogleHealthCredentials?> refreshToken({
    required GoogleHealthCredentials credentials,
    required String clientID,
    required String clientSecret,
  });

  /// Calls users.getIdentity to retrieve the user's Google Health user ID.
  /// Must be called after authorize() to get the ID for subsequent requests.
  static Future<String?> getUserId({
    required GoogleHealthCredentials credentials,
  });

  /// Revokes both the access and refresh tokens.
  static Future<bool> unauthorize({
    required GoogleHealthCredentials credentials,
  });
}
```

### 3.5 `GoogleHealthCredentials` Model

Credentials are **not stored by the library** — the developer is responsible (Fitbitter 2.0 pattern). The model must be fully serializable so developers can persist it themselves (e.g. with `flutter_secure_storage`).

```dart
class GoogleHealthCredentials {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpirationDateTime;  // UTC
  final String userID;                           // from users.getIdentity
  final List<String> scopes;

  // Serialization — manual fromJson/toJson (see Section 5)
  Map<String, dynamic> toJson();
  factory GoogleHealthCredentials.fromJson(Map<String, dynamic> json);

  // Convenience
  bool get isExpired =>
    DateTime.now().toUtc().isAfter(
      accessTokenExpirationDateTime.subtract(const Duration(seconds: 60))
    );
}
```

---

## 4. API Base

| Property | Value |
|----------|-------|
| Base URL | `https://health.googleapis.com/v4/` |
| User identifier | `me` (always — resolved from access token) |
| Response format | JSON |
| Auth header | `Authorization: Bearer {accessToken}` |
| Error format | Standard Google API error object `{error: {code, message, status}}` |

---

## 5. Serialization Strategy: Manual `fromJson` / `toJson`

**Decision: manual serialization** (no `json_serializable`, no `freezed`).

Reasons:
- Mirrors Fitbitter's approach — consistent architecture, minimal dependency tree.
- No `build_runner` step means less friction for contributors.
- Google Health API responses are well-structured — manual serialization is not burdensome.

**Null safety rules:**
- Use `required` non-nullable fields everywhere the API guarantees a value.
- Use nullable (`T?`) only where the Google Health API docs mark a field as optional.
- Throw `GoogleHealthDataException` with a descriptive message when a required field is missing in `fromJson`. Never silently return null.

**Pattern for every data class:**

```dart
class GoogleHealthStepsData {
  final String? userId;
  final DateTime? dateTime;
  final double? value;

  const GoogleHealthStepsData({
    this.userId,
    this.dateTime,
    this.value,
  });

  factory GoogleHealthStepsData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthStepsData(
      userId:   json['userId']   as String?,
      dateTime: json['startTime'] != null
                  ? DateTime.parse(json['startTime'] as String).toLocal()
                  : null,
      value:    (json['value'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId':    userId,
    'startTime': dateTime?.toUtc().toIso8601String(),
    'value':     value,
  };

  @override
  String toString() =>
    'GoogleHealthStepsData(userId: $userId, dateTime: $dateTime, value: $value)';
}
```

`GoogleHealthCredentials` follows the same pattern for developer-side persistence.

---

## 6. Data Types

Implement in priority order. Do not start P1 until all P0 types have tests passing.

| Priority | Data Type | `dataType` string | API Method(s) | Scope constant |
|----------|-----------|-------------------|---------------|----------------|
| **P0** | Steps | `steps` | `list`, `dailyRollup` | `activityAndFitnessReadonly` |
| **P0** | Heart Rate | `heart-rate` | `list`, `dailyRollup` | `healthMetricsReadonly` |
| **P0** | Sleep | `sleep` | `list` | `sleepReadonly` |
| **P0** | Profile | *(special)* | `users.getProfile` | `profileReadonly` |
| **P1** | Distance | `distance` | `list`, `dailyRollup` | `activityAndFitnessReadonly` |
| **P1** | Calories | `total-calories` | `list`, `dailyRollup` | `activityAndFitnessReadonly` |
| **P1** | Active Zone Minutes | `active-zone-minutes` | `list`, `dailyRollup` | `activityAndFitnessReadonly` |
| **P1** | Resting Heart Rate | `daily-resting-heart-rate` | `dailyRollup` | `healthMetricsReadonly` |
| **P2** | Oxygen Saturation | `daily-oxygen-saturation` | `dailyRollup` | `healthMetricsReadonly` |
| **P2** | HRV | `daily-heart-rate-variability` | `dailyRollup` | `healthMetricsReadonly` |
| **P2** | Weight | `weight` | `list` | `healthMetricsReadonly` |
| **P2** | Exercise | `exercise` | `list` | `activityAndFitnessReadonly` |

---

## 7. Endpoint Patterns

### 7.1 Standard data points

```
# Paginated intraday list
GET https://health.googleapis.com/v4/users/me/dataTypes/{dataType}/dataPoints
    ?startTime=YYYY-MM-DDThh:mm:ssZ
    &endTime=YYYY-MM-DDThh:mm:ssZ

# Single day rollup
GET https://health.googleapis.com/v4/users/me/dataTypes/{dataType}/dataPoints:dailyRollup
    ?startTime=YYYY-MM-DD
    &endTime=YYYY-MM-DD

# Multi-day rollup
GET https://health.googleapis.com/v4/users/me/dataTypes/{dataType}/dataPoints:rollUp
    ?startTime=YYYY-MM-DDThh:mm:ssZ
    &endTime=YYYY-MM-DDThh:mm:ssZ
    &windowSize=86400s
```

### 7.2 Profile endpoints

```
GET https://health.googleapis.com/v4/users/me/profile
GET https://health.googleapis.com/v4/users/me/settings
GET https://health.googleapis.com/v4/users/me:getIdentity
```

### 7.3 `GoogleHealthAPIURL` builder pattern

```dart
// Abstract base
abstract class GoogleHealthAPIURL {
  final Uri uri;
  const GoogleHealthAPIURL({required this.uri});
}

// Concrete example
class GoogleHealthStepsAPIURL extends GoogleHealthAPIURL {
  GoogleHealthStepsAPIURL._({required super.uri});

  /// Single day — uses dailyRollup
  factory GoogleHealthStepsAPIURL.day({required DateTime date}) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/steps/dataPoints:dailyRollup',
      {'startTime': _formatDate(date), 'endTime': _formatDate(date)},
    );
    return GoogleHealthStepsAPIURL._(uri: uri);
  }

  /// Date range — uses dailyRollup over interval
  factory GoogleHealthStepsAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/steps/dataPoints:dailyRollup',
      {'startTime': _formatDate(startDate), 'endTime': _formatDate(endDate)},
    );
    return GoogleHealthStepsAPIURL._(uri: uri);
  }

  /// Intraday — uses list with full timestamps
  factory GoogleHealthStepsAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/steps/dataPoints',
      {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime':   endTime.toUtc().toIso8601String(),
      },
    );
    return GoogleHealthStepsAPIURL._(uri: uri);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
```

---

## 8. Scope Constants

File: `lib/src/connectors/google_health_scopes.dart`

```dart
/// Scope URL constants for the Google Health API.
/// Pass a subset of these to [GoogleHealthConnector.authorize].
class GoogleHealthScopes {
  GoogleHealthScopes._();

  static const String activityAndFitness =
      'https://www.googleapis.com/auth/googlehealth.activity_and_fitness';
  static const String activityAndFitnessReadonly =
      'https://www.googleapis.com/auth/googlehealth.activity_and_fitness.readonly';

  static const String healthMetrics =
      'https://www.googleapis.com/auth/googlehealth.health_metrics_and_measurements';
  static const String healthMetricsReadonly =
      'https://www.googleapis.com/auth/googlehealth.health_metrics_and_measurements.readonly';

  static const String sleep =
      'https://www.googleapis.com/auth/googlehealth.sleep';
  static const String sleepReadonly =
      'https://www.googleapis.com/auth/googlehealth.sleep.readonly';

  static const String profile =
      'https://www.googleapis.com/auth/googlehealth.profile';
  static const String profileReadonly =
      'https://www.googleapis.com/auth/googlehealth.profile.readonly';

  static const String locationReadonly =
      'https://www.googleapis.com/auth/googlehealth.location.readonly';

  static const String nutritionReadonly =
      'https://www.googleapis.com/auth/googlehealth.nutrition.readonly';
}
```

---

## 9. Error Handling

File: `lib/src/exceptions/google_health_exceptions.dart`

```dart
/// Base class for all google_flutter_health exceptions.
sealed class GoogleHealthException implements Exception {
  final String message;
  const GoogleHealthException(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when OAuth2 authorization fails or is cancelled by the user.
final class GoogleHealthAuthException extends GoogleHealthException {
  const GoogleHealthAuthException(super.message);
}

/// Thrown when the access token has expired and refresh failed.
final class GoogleHealthTokenExpiredException extends GoogleHealthException {
  const GoogleHealthTokenExpiredException(super.message);
}

/// Thrown on HTTP 429 — back off and retry.
final class GoogleHealthRateLimitException extends GoogleHealthException {
  final Duration? retryAfter;
  const GoogleHealthRateLimitException(super.message, {this.retryAfter});
}

/// Thrown when the API returns an error for a specific data type request.
final class GoogleHealthDataTypeException extends GoogleHealthException {
  const GoogleHealthDataTypeException(super.message);
}

/// Thrown on network failure (no connectivity, timeout, etc.).
final class GoogleHealthNetworkException extends GoogleHealthException {
  const GoogleHealthNetworkException(super.message);
}

/// Thrown when JSON parsing fails or a required field is missing.
final class GoogleHealthDataException extends GoogleHealthException {
  const GoogleHealthDataException(super.message);
}
```

**Token expiry handling inside `fetch()` (pseudocode for the abstract base):**

```dart
Future<({List<T> data, GoogleHealthCredentials credentials})> fetch(
  GoogleHealthAPIURL url,
) async {
  var creds = credentials;

  if (creds.isExpired) {
    final refreshed = await GoogleHealthConnector.refreshToken(
      credentials: creds,
      clientID: clientID,
      clientSecret: clientSecret,
    );
    if (refreshed == null) {
      throw const GoogleHealthTokenExpiredException(
        'Access token expired and refresh failed.',
      );
    }
    creds = refreshed;
  }

  final response = await _makeRequest(url, creds);
  final data = _parseResponse(response);
  return (data: data, credentials: creds);
}
```

---

## 10. Dependencies (`pubspec.yaml`)

```yaml
name: google_flutter_health
description: >-
  A Flutter package to make your life easier when dealing with
  the Google Health API. The spiritual successor to Fitbitter.
version: 0.1.0
homepage: https://github.com/DFerrari13/google_flutter_health
repository: https://github.com/DFerrari13/google_flutter_health
issue_tracker: https://github.com/DFerrari13/google_flutter_health/issues

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  googleapis_auth: ^1.6.0
  http: ^1.2.0
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0       # needed by mockito @GenerateMocks only
  flutter_lints: ^4.0.0
  pana: ^0.22.0              # run locally before publish to check pub.dev score
```

---



---

*Spec v1.0 — all decisions resolved, ready for Phase 3.*
