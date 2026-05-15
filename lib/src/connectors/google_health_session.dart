import 'package:flutter/foundation.dart';

import 'google_health_connector.dart';
import 'google_health_credentials.dart';

/// Holds the active Google Health credential state and notifies listeners on
/// every change.
///
/// Extend or compose this class in your own auth service. Supply a listener
/// (e.g. via [addListener]) to persist credentials whenever they change —
/// see the `google_flutter_health_example` app for a complete reference
/// implementation using `flutter_secure_storage` and `google_sign_in`.
///
/// ```dart
/// final session = GoogleHealthSession();
///
/// // After sign-in:
/// session.updateCredentials(freshCredentials);
///
/// // After each manager.fetch(), persist the potentially-refreshed token:
/// session.updateCredentials(result.credentials);
///
/// // On logout:
/// await session.logout();
/// ```
class GoogleHealthSession extends ChangeNotifier {
  GoogleHealthSession({GoogleHealthCredentials? credentials})
      : _credentials = credentials;

  GoogleHealthCredentials? _credentials;

  /// Current credentials, or `null` when the user is not signed in.
  GoogleHealthCredentials? get credentials => _credentials;

  /// `true` when credentials are present (user is signed in).
  bool get isAuthenticated => _credentials != null;

  /// Replaces the stored credentials and fires [notifyListeners].
  ///
  /// Call this after sign-in, after each `manager.fetch()` (to persist the
  /// potentially-refreshed access token), or with `null` to clear the session
  /// without revoking the token.
  void updateCredentials(GoogleHealthCredentials? credentials) {
    _credentials = credentials;
    notifyListeners();
  }

  /// Revokes the current access token, clears the session, and fires
  /// [notifyListeners].
  ///
  /// Safe to call when [credentials] is `null` (no-op). The revocation
  /// request is best-effort — if the network call fails the local session is
  /// still cleared.
  Future<void> logout() async {
    if (_credentials != null) {
      await GoogleHealthConnector.unauthorize(credentials: _credentials!);
      _credentials = null;
      notifyListeners();
    }
  }
}
