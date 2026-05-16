import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../exceptions/google_health_exceptions.dart';
import 'google_health_credentials.dart';

/// Entry point for Google Health OAuth 2.0 authorization flows.
///
/// All methods are static — there is no need to instantiate this class.
/// Credentials returned by [authorize] and [refreshToken] are never stored
/// by the library; persist them yourself (e.g. with `flutter_secure_storage`).
class GoogleHealthConnector {
  GoogleHealthConnector._();

  /// Opens a browser or web-view for the user to authorise the app.
  ///
  /// Returns a [GoogleHealthCredentials] instance on success, or `null` if the
  /// user cancels or the redirect contains no authorization code.
  ///
  /// - [clientID]: OAuth 2.0 client ID from the Google Cloud Console.
  /// - [clientSecret]: OAuth 2.0 client secret.
  /// - [redirectUri]: Must match a URI registered in the Cloud Console exactly.
  /// - [scopes]: Use constants from [GoogleHealthScopes].
  /// - [launchBrowserAndGetRedirect]: Platform-specific callback — receives the
  ///   authorization URL and must return the full redirect URL (including the
  ///   `code=…` query parameter) after the user completes the consent screen,
  ///   or `null` if the user cancels.
  ///
  /// Throws [GoogleHealthAuthException] on authorization-server errors.
  static Future<GoogleHealthCredentials?> authorize({
    required String clientID,
    required String clientSecret,
    required String redirectUri,
    required List<String> scopes,
    required Future<String?> Function(Uri authUri) launchBrowserAndGetRedirect,
  }) async {
    final state = _generateState();

    final authUri = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientID,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scopes.join(' '),
      'access_type': 'offline',
      'state': state,
      'prompt': 'consent',
    });

    final redirectResult = await launchBrowserAndGetRedirect(authUri);
    if (redirectResult == null) return null;

    final redirected = Uri.parse(redirectResult);

    if (redirected.queryParameters['state'] != state) {
      throw const GoogleHealthAuthException(
        'State parameter mismatch — possible CSRF attack.',
      );
    }

    final error = redirected.queryParameters['error'];
    if (error != null) throw GoogleHealthAuthException(error);

    final code = redirected.queryParameters['code'];
    if (code == null) return null;

    return exchangeAuthCode(
      code: code,
      clientID: clientID,
      clientSecret: clientSecret,
      redirectUri: redirectUri,
      scopes: scopes,
    );
  }

  /// Exchanges an OAuth 2.0 authorization code for full credentials.
  ///
  /// Use this when you already have an authorization code from another source
  /// — for example a `serverAuthCode` from `google_sign_in` on Android, or a
  /// code captured via a custom OAuth flow. The method posts to Google's token
  /// endpoint, then calls `users.me:getIdentity` to populate `userID`.
  ///
  /// - [code]: The authorization code.
  /// - [clientID]: OAuth 2.0 client ID that issued the code (typically the
  ///   **Web** client when using `google_sign_in`'s `serverClientId`).
  /// - [clientSecret]: Matching client secret.
  /// - [redirectUri]: Must match the redirect URI used to obtain the code, or
  ///   an empty string for codes issued via Google Sign-In's `serverAuthCode`.
  /// - [scopes]: Scopes that were granted — stored in the returned credentials.
  ///
  /// Throws [GoogleHealthAuthException] on failure.
  static Future<GoogleHealthCredentials> exchangeAuthCode({
    required String code,
    required String clientID,
    required String clientSecret,
    required String redirectUri,
    required List<String> scopes,
  }) async {
    final tokenResponse = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'client_id': clientID,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
      },
    );

    if (tokenResponse.statusCode != 200) {
      final json = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
      throw GoogleHealthAuthException(
        json['error_description'] as String? ?? 'Token exchange failed.',
      );
    }

    final json = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    final refreshToken = json['refresh_token'] as String?;
    if (refreshToken == null) {
      throw const GoogleHealthAuthException(
        'No refresh token returned. '
        'Ensure access_type=offline and prompt=consent are set.',
      );
    }

    final partial = GoogleHealthCredentials(
      accessToken: json['access_token'] as String,
      refreshToken: refreshToken,
      accessTokenExpirationDateTime: DateTime.now().toUtc().add(
            Duration(seconds: (json['expires_in'] as num).toInt()),
          ),
      userID: '',
      scopes: scopes,
    );

    final userId = await getUserId(credentials: partial);
    if (userId == null) {
      throw const GoogleHealthAuthException(
        'Failed to retrieve Google Health user ID after authorization.',
      );
    }

    return GoogleHealthCredentials(
      accessToken: partial.accessToken,
      refreshToken: partial.refreshToken,
      accessTokenExpirationDateTime: partial.accessTokenExpirationDateTime,
      userID: userId,
      scopes: scopes,
    );
  }

  /// Exchanges a refresh token for a new access token.
  ///
  /// Called automatically inside every `fetch()` call when the current access
  /// token is expired (or within 60 seconds of expiry). You can also call this
  /// directly if you need to refresh ahead of time.
  ///
  /// Returns updated [GoogleHealthCredentials] on success, or `null` if the
  /// refresh token has been revoked or the request fails.
  ///
  /// - [credentials]: Current credentials containing the refresh token.
  /// - [clientID]: OAuth 2.0 client ID.
  /// - [clientSecret]: OAuth 2.0 client secret.
  static Future<GoogleHealthCredentials?> refreshToken({
    required GoogleHealthCredentials credentials,
    required String clientID,
    required String clientSecret,
  }) async {
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': credentials.refreshToken,
        'client_id': clientID,
        'client_secret': clientSecret,
      },
    );
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GoogleHealthCredentials(
      accessToken: json['access_token'] as String,
      refreshToken: credentials.refreshToken,
      accessTokenExpirationDateTime: DateTime.now().toUtc().add(
            Duration(seconds: (json['expires_in'] as num).toInt()),
          ),
      userID: credentials.userID,
      scopes: credentials.scopes,
    );
  }

  /// Retrieves the authenticated user's Google Health user ID.
  ///
  /// Calls the `users.me:getIdentity` endpoint. Call this once after
  /// [authorize] and store the returned ID in your credentials if needed
  /// for user-specific operations.
  ///
  /// Returns the user ID string, or `null` if the request fails.
  ///
  /// - [credentials]: Valid credentials with a non-expired access token.
  static Future<String?> getUserId({
    required GoogleHealthCredentials credentials,
  }) async {
    final response = await http.get(
      Uri.https('health.googleapis.com', '/v4/users/me:getIdentity'),
      headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
    );
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['userId'] as String?;
  }

  /// Revokes the access token and refresh token for the given credentials.
  ///
  /// After calling this, the credentials are invalid and the user must
  /// go through [authorize] again.
  ///
  /// Returns `true` if revocation succeeded, `false` otherwise.
  ///
  /// - [credentials]: Credentials to revoke.
  static Future<bool> unauthorize({
    required GoogleHealthCredentials credentials,
  }) async {
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/revoke'),
      body: {'token': credentials.accessToken},
    );
    return response.statusCode == 200;
  }

  static String _generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
}
