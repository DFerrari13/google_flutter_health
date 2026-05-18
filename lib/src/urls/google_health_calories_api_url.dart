import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health `total-calories` data type.
class GoogleHealthCaloriesAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthCaloriesAPIURL._({
    required super.uri,
    required super.method,
    super.body,
  });

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'total-calories';

  /// JSON field key under each data point that holds calorie values.
  static const String _fieldKey = 'totalCalories';

  /// Builds a request for a single calendar day using `dailyRollUp`.
  factory GoogleHealthCaloriesAPIURL.day({required DateTime date}) {
    return GoogleHealthCaloriesAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  /// Builds a request for an inclusive date range using `dailyRollUp`.
  factory GoogleHealthCaloriesAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints:dailyRollUp',
    );
    return GoogleHealthCaloriesAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.post,
      body: buildCivilRange(
        startDate: startDate,
        endDate: exclusiveDayAfter(endDate),
      ),
    );
  }

  /// `total-calories` only supports rollup endpoints, but rollUp (POST) can
  /// be used for arbitrary windows.
  factory GoogleHealthCaloriesAPIURL.rollUp({
    required DateTime startTime,
    required DateTime endTime,
    Duration windowSize = const Duration(hours: 1),
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints:rollUp',
    );
    final body = buildPhysicalRange(startTime: startTime, endTime: endTime)
      ..['windowSize'] = '${windowSize.inSeconds}s';
    return GoogleHealthCaloriesAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.post,
      body: body,
    );
  }

  /// Reserved for the field-key inspection (used by data parser).
  static String get fieldKey => _fieldKey;
}
