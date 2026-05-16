import 'dart:convert';

import 'package:http/http.dart' as http;

import '../connectors/google_health_credentials.dart';
import '../data/google_health_exercise_data.dart';
import '../exceptions/google_health_exceptions.dart';
import '../urls/google_health_api_url.dart';
import 'google_health_data_manager.dart';

/// Fetches exercise session data from the Google Health API.
///
/// Requires the [GoogleHealthScopes.activityAndFitnessReadonly] scope.
///
/// ```dart
/// final manager = GoogleHealthExerciseDataManager(
///   credentials: credentials,
///   clientID: 'YOUR_CLIENT_ID',
///   clientSecret: 'YOUR_CLIENT_SECRET',
/// );
/// final result = await manager.fetch(
///   GoogleHealthExerciseAPIURL.dateRange(
///     startDate: DateTime(2024, 1, 1),
///     endDate: DateTime(2024, 1, 31),
///   ),
/// );
/// ```
class GoogleHealthExerciseDataManager
    extends GoogleHealthDataManager<GoogleHealthExerciseData> {
  /// Creates an exercise data manager.
  ///
  /// - [credentials]: Current OAuth 2.0 credentials.
  /// - [clientID]: Client ID for token refresh.
  /// - [clientSecret]: Client secret for token refresh.
  /// - [httpClient]: Optional custom HTTP client (injected in tests).
  GoogleHealthExerciseDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  /// Fetches exercise sessions for the time range specified by [url].
  ///
  /// Refreshes the access token automatically if expired. Returns a record
  /// containing the list of [GoogleHealthExerciseData] sessions and the
  /// (possibly refreshed) credentials.
  ///
  /// Throws [GoogleHealthTokenExpiredException] if token refresh fails.
  /// Throws [GoogleHealthRateLimitException] on HTTP 429.
  /// Throws [GoogleHealthDataTypeException] on other HTTP errors.
  @override
  Future<
      ({
        List<GoogleHealthExerciseData> data,
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
        .map(GoogleHealthExerciseData.fromJson)
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
