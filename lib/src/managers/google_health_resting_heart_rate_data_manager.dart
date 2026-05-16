import 'dart:convert';

import 'package:http/http.dart' as http;

import '../connectors/google_health_credentials.dart';
import '../data/google_health_resting_heart_rate_data.dart';
import '../exceptions/google_health_exceptions.dart';
import '../urls/google_health_api_url.dart';
import 'google_health_data_manager.dart';

/// Fetches daily resting heart rate data from the Google Health API.
///
/// Requires the [GoogleHealthScopes.healthMetricsReadonly] scope.
///
/// ```dart
/// final manager = GoogleHealthRestingHeartRateDataManager(
///   credentials: credentials,
///   clientID: 'YOUR_CLIENT_ID',
///   clientSecret: 'YOUR_CLIENT_SECRET',
/// );
/// final result = await manager.fetch(
///   GoogleHealthRestingHeartRateAPIURL.dailyRollup(
///     startDate: DateTime.now().subtract(const Duration(days: 7)),
///     endDate: DateTime.now(),
///   ),
/// );
/// for (final point in result.data) {
///   print('${point.dateTime}: ${point.beatsPerMinute} bpm');
/// }
/// ```
class GoogleHealthRestingHeartRateDataManager
    extends GoogleHealthDataManager<GoogleHealthRestingHeartRateData> {
  /// Creates a resting heart rate data manager.
  ///
  /// - [credentials]: Current OAuth 2.0 credentials.
  /// - [clientID]: Client ID for token refresh.
  /// - [clientSecret]: Client secret for token refresh.
  /// - [httpClient]: Optional custom HTTP client (injected in tests).
  GoogleHealthRestingHeartRateDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  /// Fetches resting heart rate data for the date range specified by [url].
  ///
  /// Refreshes the access token automatically if expired. Returns a record
  /// containing the list of [GoogleHealthRestingHeartRateData] points and
  /// the (possibly refreshed) credentials.
  ///
  /// Throws [GoogleHealthTokenExpiredException] if token refresh fails.
  /// Throws [GoogleHealthRateLimitException] on HTTP 429.
  /// Throws [GoogleHealthDataTypeException] on other HTTP errors.
  @override
  Future<
      ({
        List<GoogleHealthRestingHeartRateData> data,
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
        .map(GoogleHealthRestingHeartRateData.fromJson)
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
