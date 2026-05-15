import 'dart:convert';

import 'package:http/http.dart' as http;

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
  /// user cancels or an error occurs.
  ///
  /// - [clientID]: OAuth 2.0 client ID from the Google Cloud Console.
  /// - [clientSecret]: OAuth 2.0 client secret from the Google Cloud Console.
  /// - [redirectUri]: The URI registered in the Cloud Console (must match exactly).
  /// - [scopes]: List of scope strings — use constants from [GoogleHealthScopes].
  ///
  /// Throws [GoogleHealthAuthException] if the authorization server returns
  /// an error response.
  static Future<GoogleHealthCredentials?> authorize({
    required String clientID,
    required String clientSecret,
    required String redirectUri,
    required List<String> scopes,
  }) async {
    throw UnimplementedError('authorize() requires platform-specific setup');
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
}
