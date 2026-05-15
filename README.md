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
  google_sign_in: ^7.0.0          # for interactive sign-in on Android / iOS
  flutter_secure_storage: ^10.0.0 # for persisting credentials
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
    print('Steps: ${result.data.first.value}');
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
print('Steps: ${result.data.first.value}');
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
