import 'dart:convert';

import 'package:http/http.dart' as http;

import '../connectors/google_health_credentials.dart';
import '../exceptions/google_health_exceptions.dart';
import '../urls/google_health_api_url.dart';

/// Abstract base class for all Google Health data managers.
///
/// Each concrete subclass (e.g. [GoogleHealthStepsDataManager]) implements
/// [fetch] for a specific data type. Managers handle token refresh
/// transparently — if [credentials] is expired, the token is refreshed
/// before the API request and the updated credentials are returned in the
/// result record.
///
/// ```dart
/// final manager = GoogleHealthStepsDataManager(
///   credentials: credentials,
///   clientID: 'YOUR_CLIENT_ID',
///   clientSecret: 'YOUR_CLIENT_SECRET',
/// );
/// final result = await manager.fetch(
///   GoogleHealthStepsAPIURL.day(date: DateTime.now()),
/// );
/// // Save result.credentials — they may have been refreshed.
/// ```
abstract class GoogleHealthDataManager<T> {
  /// The current credentials used to authorise API requests.
  ///
  /// May be refreshed inside [fetch]. Always persist the credentials returned
  /// by [fetch] rather than re-using this field directly.
  final GoogleHealthCredentials credentials;

  /// OAuth 2.0 client ID used for token refresh.
  final String clientID;

  /// OAuth 2.0 client secret used for token refresh.
  final String clientSecret;

  /// The HTTP client used for all network requests.
  ///
  /// Inject a custom client in tests to avoid real network calls.
  final http.Client httpClient;

  /// Creates a data manager.
  ///
  /// - [credentials]: Current OAuth 2.0 credentials.
  /// - [clientID]: Client ID for token refresh.
  /// - [clientSecret]: Client secret for token refresh.
  /// - [httpClient]: Optional custom HTTP client (default: `http.Client()`).
  GoogleHealthDataManager({
    required this.credentials,
    required this.clientID,
    required this.clientSecret,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Fetches data from the Google Health API.
  ///
  /// Automatically refreshes the access token when [credentials] is expired
  /// (within a 60-second buffer). Returns both the fetched data and the
  /// (possibly refreshed) credentials in a Dart record.
  ///
  /// Always persist the returned `credentials` — they may differ from the
  /// ones you passed to the constructor if a refresh occurred.
  ///
  /// - [url]: A URL builder instance for the desired data type and time range.
  ///
  /// Throws [GoogleHealthTokenExpiredException] if the token is expired and
  /// refresh fails (e.g. the refresh token has been revoked).
  /// Throws [GoogleHealthRateLimitException] on HTTP 429.
  /// Throws [GoogleHealthDataTypeException] on other HTTP errors.
  Future<({List<T> data, GoogleHealthCredentials credentials})> fetch(
    GoogleHealthAPIURL url,
  );

  /// Refreshes the access token if it is expired or about to expire.
  ///
  /// Called automatically by [fetch]. Returns updated credentials if a
  /// refresh was performed, otherwise returns [creds] unchanged.
  ///
  /// Throws [GoogleHealthTokenExpiredException] if the refresh request fails.
  Future<GoogleHealthCredentials> refreshIfNeeded(
    GoogleHealthCredentials creds,
  ) async {
    if (!creds.isExpired) return creds;
    final response = await httpClient.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': creds.refreshToken,
        'client_id': clientID,
        'client_secret': clientSecret,
      },
    );
    if (response.statusCode != 200) {
      throw const GoogleHealthTokenExpiredException(
        'Access token expired and refresh failed.',
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GoogleHealthCredentials(
      accessToken: json['access_token'] as String,
      refreshToken: creds.refreshToken,
      accessTokenExpirationDateTime: DateTime.now().toUtc().add(
            Duration(seconds: (json['expires_in'] as num).toInt()),
          ),
      userID: creds.userID,
      scopes: creds.scopes,
    );
  }
}
