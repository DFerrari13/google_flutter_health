import 'dart:convert';

import 'package:http/http.dart' as http;

import '../connectors/google_health_credentials.dart';
import '../data/google_health_profile_data.dart';
import '../exceptions/google_health_exceptions.dart';
import '../urls/google_health_api_url.dart';
import '../urls/google_health_profile_api_url.dart';
import 'google_health_data_manager.dart';

/// Fetches the authenticated user's Google Health profile and settings.
///
/// Requires the [GoogleHealthScopes.profileReadonly] scope.
///
/// Makes two API calls internally — one to `users.me.profile` and one to
/// `users.me.settings` — and merges the responses into a single
/// [GoogleHealthProfileData] instance. The [url] parameter is accepted for
/// interface consistency but ignored; use [GoogleHealthProfileAPIURL.profile].
///
/// ```dart
/// final manager = GoogleHealthProfileDataManager(
///   credentials: credentials,
///   clientID: 'YOUR_CLIENT_ID',
///   clientSecret: 'YOUR_CLIENT_SECRET',
/// );
/// final result = await manager.fetch(GoogleHealthProfileAPIURL.profile);
/// final profile = result.data.first;
/// print('Hello, ${profile.displayName}!');
/// ```
class GoogleHealthProfileDataManager
    extends GoogleHealthDataManager<GoogleHealthProfileData> {
  /// Creates a profile data manager.
  ///
  /// - [credentials]: Current OAuth 2.0 credentials.
  /// - [clientID]: Client ID for token refresh.
  /// - [clientSecret]: Client secret for token refresh.
  /// - [httpClient]: Optional custom HTTP client (injected in tests).
  GoogleHealthProfileDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  /// Fetches the user's profile and settings, merged into one [GoogleHealthProfileData].
  ///
  /// The [url] parameter is accepted for interface consistency but is ignored.
  /// This method always queries [GoogleHealthProfileAPIURL.profile] and
  /// [GoogleHealthProfileAPIURL.settings] internally.
  ///
  /// Returns a record with a single-element list and the (possibly refreshed)
  /// credentials.
  ///
  /// Throws [GoogleHealthTokenExpiredException] if token refresh fails.
  /// Throws [GoogleHealthRateLimitException] on HTTP 429.
  /// Throws [GoogleHealthDataTypeException] on other HTTP errors.
  @override
  Future<
      ({
        List<GoogleHealthProfileData> data,
        GoogleHealthCredentials credentials
      })> fetch(
    GoogleHealthAPIURL url,
  ) async {
    var creds = credentials;
    creds = await refreshIfNeeded(creds);

    final headers = {'Authorization': 'Bearer ${creds.accessToken}'};

    final profileResponse = await httpClient.get(
      GoogleHealthProfileAPIURL.profile.uri,
      headers: headers,
    );
    _checkResponse(profileResponse);

    final settingsResponse = await httpClient.get(
      GoogleHealthProfileAPIURL.settings.uri,
      headers: headers,
    );
    _checkResponse(settingsResponse);

    final profileJson =
        jsonDecode(profileResponse.body) as Map<String, dynamic>;
    final settingsJson =
        jsonDecode(settingsResponse.body) as Map<String, dynamic>;

    final merged = {...profileJson, ...settingsJson};
    final data = GoogleHealthProfileData.fromJson(merged);

    return (data: [data], credentials: creds);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw const GoogleHealthTokenExpiredException(
        'Unauthorized: access token rejected by the API.',
      );
    }
    if (response.statusCode == 429) {
      throw const GoogleHealthRateLimitException(
        'Rate limit exceeded.',
      );
    }
    if (response.statusCode != 200) {
      throw GoogleHealthDataTypeException(
        'API error: ${response.statusCode}',
      );
    }
  }
}
