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
  google_flutter_health: ^0.1.0
  flutter_secure_storage: ^10.0.0  # recommended for storing credentials
```

Then run:

```sh
flutter pub get
```

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
4. Open **APIs & Services → Credentials → Create Credentials → OAuth client ID**:
   - Application type: **Android** (or iOS).
   - For Android: enter your package name and the SHA-1 fingerprint of your signing certificate.
   - For iOS: enter your bundle identifier.
   - Copy the generated **Client ID** and **Client Secret**.
5. Add your redirect URI (e.g. `com.example.myapp:/oauth2redirect`) to the **Authorised redirect URIs** list.

---

## Android Setup

Add the following to `android/app/src/main/AndroidManifest.xml` inside `<application>`:

```xml
<activity
    android:name="net.openid.appauth.RedirectUriReceiverActivity"
    android:exported="true">
  <intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <!-- Replace with your redirect URI scheme -->
    <data android:scheme="com.example.myapp"/>
  </intent-filter>
</activity>
```

Add internet permission if not already present:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## iOS Setup

Add the following to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your redirect URI scheme -->
      <string>com.example.myapp</string>
    </array>
  </dict>
</array>
```

---

## Quick Start

```dart
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

const _storage = FlutterSecureStorage();
const _clientID = 'YOUR_CLIENT_ID';
const _clientSecret = 'YOUR_CLIENT_SECRET';
const _redirectUri = 'com.example.myapp:/oauth2redirect';

// 1. Authorize
Future<GoogleHealthCredentials?> login() async {
  final credentials = await GoogleHealthConnector.authorize(
    clientID: _clientID,
    clientSecret: _clientSecret,
    redirectUri: _redirectUri,
    scopes: [
      GoogleHealthScopes.activityAndFitnessReadonly,
      GoogleHealthScopes.sleepReadonly,
      GoogleHealthScopes.healthMetricsReadonly,
    ],
  );
  if (credentials != null) {
    // Persist credentials securely
    await _storage.write(
      key: 'credentials',
      value: jsonEncode(credentials.toJson()),
    );
  }
  return credentials;
}

// 2. Restore credentials from storage
Future<GoogleHealthCredentials?> loadCredentials() async {
  final raw = await _storage.read(key: 'credentials');
  if (raw == null) return null;
  return GoogleHealthCredentials.fromJson(
    jsonDecode(raw) as Map<String, dynamic>,
  );
}

// 3. Fetch today's steps
Future<int?> fetchTodaySteps(GoogleHealthCredentials credentials) async {
  final manager = GoogleHealthStepsDataManager(
    credentials: credentials,
    clientID: _clientID,
    clientSecret: _clientSecret,
  );
  final result = await manager.fetch(
    GoogleHealthStepsAPIURL.day(date: DateTime.now()),
  );

  // Always persist the returned credentials — they may have been refreshed
  await _storage.write(
    key: 'credentials',
    value: jsonEncode(result.credentials.toJson()),
  );

  return result.data.isNotEmpty ? result.data.first.value : null;
}
```

---

## Supported Data Types

| Priority | Data Type | Manager | Scope |
|----------|-----------|---------|-------|
| P0 | Steps | `GoogleHealthStepsDataManager` | `activityAndFitnessReadonly` |
| P0 | Heart Rate | `GoogleHealthHeartRateDataManager` | `healthMetricsReadonly` |
| P0 | Sleep | `GoogleHealthSleepDataManager` | `sleepReadonly` |
| P0 | Profile | `GoogleHealthProfileDataManager` | `profileReadonly` |
| P1 | Distance | *(coming soon)* | `activityAndFitnessReadonly` |
| P1 | Calories | *(coming soon)* | `activityAndFitnessReadonly` |
| P1 | Active Zone Minutes | *(coming soon)* | `activityAndFitnessReadonly` |
| P1 | Resting Heart Rate | *(coming soon)* | `healthMetricsReadonly` |
| P2 | Oxygen Saturation | *(coming soon)* | `healthMetricsReadonly` |
| P2 | HRV | *(coming soon)* | `healthMetricsReadonly` |
| P2 | Weight | *(coming soon)* | `healthMetricsReadonly` |
| P2 | Exercise | *(coming soon)* | `activityAndFitnessReadonly` |

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
2. Run `dart test` — all tests must pass.
3. Run `dart format --set-exit-if-changed lib test` — code must be formatted.
4. Add tests for any new data type following the existing pattern.

---

## License

BSD-3-Clause — see [LICENSE](LICENSE).
