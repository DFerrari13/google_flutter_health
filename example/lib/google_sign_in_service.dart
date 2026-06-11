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
  /// Returns the [GoogleSignInAccount] so callers can read identity fields.
  /// Throws [GoogleHealthAuthException] or [GoogleSignInException] on failure.
  Future<GoogleSignInAccount> login() async {
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const GoogleHealthAuthException(
        'Interactive sign-in is not supported on this platform.',
      );
    }

    // Workaround for google_sign_in v7 Android "[16] Account reauth failed":
    // a stale cached credential makes the first authenticate() fail. Clearing
    // the local sign-in state first forces a fresh interactive auth. This does
    // NOT remove the account from the device — it only drops the app's cached
    // credential.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}

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
    return account;
  }

  /// Revokes the token, signs out of `google_sign_in`, and clears storage.
  ///
  /// After this call, [session.isAuthenticated] is `false`.
  Future<void> logout() async {
    await session.logout(); // revokes token + clears session + fires listeners
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    // The listener queued a storage delete when session.logout() cleared the
    // credentials. Wait for the queue to drain so no earlier in-flight write
    // can land after the delete and resurrect stale credentials.
    await _persistQueue;
  }

  /// Call from `State.dispose()` to detach the storage listener.
  void dispose() {
    session.removeListener(_persistCredentials);
    session.dispose();
  }

  Future<void> _loadCredentials() async {
    final String? raw;
    try {
      raw = await _storage.read(key: _storageKey);
    } catch (_) {
      // Secure storage can fail to decrypt (e.g. after a backup/restore on
      // Android). Treat it as "not signed in" instead of crashing startup.
      return;
    }
    if (raw == null) return;
    try {
      final creds = GoogleHealthCredentials.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      session.updateCredentials(creds);
    } catch (_) {
      // Corrupt or legacy payload — drop it so the next launch starts clean.
      await _storage.delete(key: _storageKey);
    }
  }

  /// Pending persistence work. Writes are chained on this future so they
  /// reach storage in the same order the credentials changed — a slow older
  /// write can never overwrite a newer one (or a logout delete).
  Future<void> _persistQueue = Future<void>.value();

  void _persistCredentials() {
    // Snapshot now: by the time the queued write runs, session.credentials
    // may already have changed again.
    final creds = session.credentials;
    _persistQueue = _persistQueue.then((_) => _doPersist(creds));
  }

  Future<void> _doPersist(GoogleHealthCredentials? creds) async {
    try {
      if (creds == null) {
        await _storage.delete(key: _storageKey);
      } else {
        await _storage.write(
          key: _storageKey,
          value: jsonEncode(creds.toJson()),
        );
      }
    } catch (_) {
      // Persistence is best-effort; the in-memory session stays valid and the
      // next credential change retries the write.
    }
  }
}
