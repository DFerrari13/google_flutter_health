import 'dart:async';
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

  /// Maximum duration for any single HTTP request before it is aborted.
  static const Duration requestTimeout = Duration(seconds: 30);

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

    final Uri redirected;
    try {
      redirected = Uri.parse(redirectResult);
    } on FormatException catch (e) {
      throw GoogleHealthAuthException('Malformed redirect URL: $e');
    }

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
  /// Throws [GoogleHealthAuthException] on failure and
  /// [GoogleHealthNetworkException] on network failure or timeout.
  static Future<GoogleHealthCredentials> exchangeAuthCode({
    required String code,
    required String clientID,
    required String clientSecret,
    required String redirectUri,
    required List<String> scopes,
  }) async {
    final http.Response tokenResponse;
    try {
      tokenResponse = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'client_id': clientID,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
        },
      ).timeout(requestTimeout);
    } on http.ClientException catch (e) {
      throw GoogleHealthNetworkException('Token exchange failed: $e');
    } on TimeoutException {
      throw GoogleHealthNetworkException(
        'Token exchange timed out after ${requestTimeout.inSeconds}s.',
      );
    }

    if (tokenResponse.statusCode != 200) {
      throw GoogleHealthAuthException(
        'Token exchange failed (HTTP ${tokenResponse.statusCode}): '
        '${_oauthErrorDetail(tokenResponse.body)}',
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    } catch (e) {
      throw GoogleHealthAuthException('Malformed token response: $e');
    }
    final accessToken = json['access_token'] as String?;
    if (accessToken == null) {
      throw const GoogleHealthAuthException(
        'Token response did not contain an access_token.',
      );
    }
    final refreshToken = json['refresh_token'] as String?;
    if (refreshToken == null) {
      throw const GoogleHealthAuthException(
        'No refresh token returned. '
        'Ensure access_type=offline and prompt=consent are set.',
      );
    }

    final partial = GoogleHealthCredentials(
      accessToken: accessToken,
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
    final http.Response response;
    try {
      response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': credentials.refreshToken,
          'client_id': clientID,
          'client_secret': clientSecret,
        },
      ).timeout(requestTimeout);
    } on http.ClientException {
      return null;
    } on TimeoutException {
      return null;
    }
    if (response.statusCode != 200) return null;
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
    final accessToken = json['access_token'] as String?;
    if (accessToken == null) return null;
    return GoogleHealthCredentials(
      accessToken: accessToken,
      // Google may rotate the refresh token; adopt the new one when present.
      refreshToken:
          json['refresh_token'] as String? ?? credentials.refreshToken,
      accessTokenExpirationDateTime: DateTime.now().toUtc().add(
            Duration(seconds: (json['expires_in'] as num).toInt()),
          ),
      userID: credentials.userID,
      scopes: credentials.scopes,
    );
  }

  /// Retrieves the authenticated user's Google Health user ID.
  ///
  /// Calls the `users.identity` endpoint
  /// (`GET /v4/users/me/identity`). Call this once after [authorize] and
  /// store the returned ID in your credentials if needed for user-specific
  /// operations.
  ///
  /// Returns the `healthUserId` string from the response, or `null` if the
  /// request fails.
  ///
  /// - [credentials]: Valid credentials with a non-expired access token.
  static Future<String?> getUserId({
    required GoogleHealthCredentials credentials,
  }) async {
    final http.Response response;
    try {
      response = await http.get(
        Uri.https('health.googleapis.com', '/v4/users/me/identity'),
        headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
      ).timeout(requestTimeout);
    } on http.ClientException {
      return null;
    } on TimeoutException {
      return null;
    }
    if (response.statusCode != 200) return null;
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['healthUserId'] as String?;
    } catch (_) {
      return null;
    }
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
    try {
      // Revoking the refresh token revokes the whole grant (access token
      // included) and works even when the access token has already expired.
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/revoke'),
        body: {'token': credentials.refreshToken},
      ).timeout(requestTimeout);
      return response.statusCode == 200;
    } on http.ClientException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  static String _generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Extracts `error_description` / `error` from an OAuth error body, falling
  /// back to the raw body when it is not JSON (e.g. an HTML proxy page).
  static String _oauthErrorDetail(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['error_description'] as String? ??
          json['error'] as String? ??
          body;
    } catch (_) {
      return body.length > 200 ? '${body.substring(0, 200)}…' : body;
    }
  }
}
