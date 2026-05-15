import 'dart:convert';

import 'package:http/http.dart' as http;

import '../connectors/google_health_credentials.dart';
import '../data/google_health_heart_rate_data.dart';
import '../exceptions/google_health_exceptions.dart';
import '../urls/google_health_api_url.dart';
import 'google_health_data_manager.dart';

/// Fetches heart rate data from the Google Health API.
///
/// Requires the [GoogleHealthScopes.healthMetricsReadonly] scope.
///
/// ```dart
/// final manager = GoogleHealthHeartRateDataManager(
///   credentials: credentials,
///   clientID: 'YOUR_CLIENT_ID',
///   clientSecret: 'YOUR_CLIENT_SECRET',
/// );
/// final result = await manager.fetch(
///   GoogleHealthHeartRateAPIURL.day(date: DateTime.now()),
/// );
/// for (final hr in result.data) {
///   print('${hr.dateTime}: ${hr.bpm} bpm');
/// }
/// ```
class GoogleHealthHeartRateDataManager
    extends GoogleHealthDataManager<GoogleHealthHeartRateData> {
  /// Creates a heart rate data manager.
  ///
  /// - [credentials]: Current OAuth 2.0 credentials.
  /// - [clientID]: Client ID for token refresh.
  /// - [clientSecret]: Client secret for token refresh.
  /// - [httpClient]: Optional custom HTTP client (injected in tests).
  GoogleHealthHeartRateDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  /// Fetches heart rate data for the time range specified by [url].
  ///
  /// Refreshes the access token automatically if expired. Returns a record
  /// containing the list of [GoogleHealthHeartRateData] points and the
  /// (possibly refreshed) credentials.
  ///
  /// Throws [GoogleHealthTokenExpiredException] if token refresh fails.
  /// Throws [GoogleHealthRateLimitException] on HTTP 429.
  /// Throws [GoogleHealthDataTypeException] on other HTTP errors.
  @override
  Future<
      ({
        List<GoogleHealthHeartRateData> data,
        GoogleHealthCredentials credentials
      })> fetch(
    GoogleHealthAPIURL url,
  ) async {
    var creds = credentials;
    creds = await refreshIfNeeded(creds);

    final response = await httpClient.get(
      url.uri,
      headers: {'Authorization': 'Bearer ${creds.accessToken}'},
    );
    _checkResponse(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final points = (json['dataPoints'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(GoogleHealthHeartRateData.fromJson)
        .toList();

    return (data: points, credentials: creds);
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
