import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Handles the full Google Sign-In → Google Health OAuth flow.
///
/// This class is intentionally self-contained so you can copy it into any app
/// that uses `google_flutter_health`. It wires together three things:
///   - `google_sign_in` for the interactive consent screen (Android / iOS)
///   - `GoogleHealthConnector.exchangeAuthCode` for the server-side token exchange
///   - `flutter_secure_storage` for credential persistence across restarts
///
/// Usage:
/// ```dart
/// final auth = GoogleSignInService(
///   webClientID: 'YOUR_WEB_CLIENT_ID',
///   webClientSecret: 'YOUR_WEB_CLIENT_SECRET',
///   scopes: [GoogleHealthScopes.activityAndFitnessReadonly],
/// );
///
/// await auth.initialize();           // call once in initState
/// await auth.login();                // call on button tap
/// auth.session.credentials;         // non-null when signed in
/// await auth.logout();              // revoke + sign out
/// auth.dispose();                   // call in State.dispose()
/// ```
///
/// The [session] is a [GoogleHealthSession] (`ChangeNotifier`) — add a
/// listener or use `ListenableBuilder` to rebuild your UI on sign-in/out.
///
/// After every `manager.fetch()` call, pass `result.credentials` back to
/// [session.updateCredentials] so the auto-refreshed access token is persisted.
class GoogleSignInService {
  GoogleSignInService({
    required String webClientID,
    required String webClientSecret,
    required List<String> scopes,
    String storageKey = 'google_health_credentials',
  })  : _webClientID = webClientID,
        _webClientSecret = webClientSecret,
        _scopes = scopes,
        _storageKey = storageKey;

  final String _webClientID;
  final String _webClientSecret;
  final List<String> _scopes;
  final String _storageKey;

  final _storage = const FlutterSecureStorage();

  /// Credential state. Add a listener to rebuild UI on sign-in / sign-out.
  final session = GoogleHealthSession();

  /// Initialises `google_sign_in` and restores persisted credentials.
  ///
  /// Call once from `State.initState()` (or your app startup). After this
  /// returns, [session.isAuthenticated] reflects whether a previous session
  /// was found on disk.
  Future<void> initialize() async {
    await GoogleSignIn.instance.initialize(serverClientId: _webClientID);
    await _loadCredentials();
    session.addListener(_persistCredentials);
  }

  /// Opens the Google consent screen and exchanges the resulting auth code.
  ///
  /// On success, [session.credentials] is populated and persisted.
  /// Throws [GoogleHealthAuthException] or [GoogleSignInException] on failure.
  Future<void> login() async {
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const GoogleHealthAuthException(
        'Interactive sign-in is not supported on this platform.',
      );
    }

    final account = await GoogleSignIn.instance.authenticate();
    final serverAuth =
        await account.authorizationClient.authorizeServer(_scopes);
    if (serverAuth == null) {
      throw const GoogleHealthAuthException(
        'User did not grant the requested scopes.',
      );
    }

    final creds = await GoogleHealthConnector.exchangeAuthCode(
      code: serverAuth.serverAuthCode,
      clientID: _webClientID,
      clientSecret: _webClientSecret,
      redirectUri: '',
      scopes: _scopes,
    );

    session.updateCredentials(creds);
  }

  /// Revokes the token, signs out of `google_sign_in`, and clears storage.
  ///
  /// After this call, [session.isAuthenticated] is `false`.
  Future<void> logout() async {
    await session.logout(); // revokes token + clears session + fires listeners
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    // Listener fires on session.logout() and deletes storage, but if the
    // listener hasn't run yet (e.g. microtask timing), delete explicitly.
    await _storage.delete(key: _storageKey);
  }

  /// Call from `State.dispose()` to detach the storage listener.
  void dispose() {
    session.removeListener(_persistCredentials);
    session.dispose();
  }

  Future<void> _loadCredentials() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw == null) return;
    final creds = GoogleHealthCredentials.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    session.updateCredentials(creds);
  }

  void _persistCredentials() {
    unawaited(_doPersist());
  }

  Future<void> _doPersist() async {
    final creds = session.credentials;
    if (creds == null) {
      await _storage.delete(key: _storageKey);
    } else {
      await _storage.write(
        key: _storageKey,
        value: jsonEncode(creds.toJson()),
      );
    }
  }
}
