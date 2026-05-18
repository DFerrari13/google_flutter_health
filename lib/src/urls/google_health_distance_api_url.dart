import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health `distance` data type.
class GoogleHealthDistanceAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthDistanceAPIURL._({
    required super.uri,
    required super.method,
    super.body,
  });

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'distance';

  /// Builds a request for a single calendar day using `dailyRollUp`.
  factory GoogleHealthDistanceAPIURL.day({required DateTime date}) {
    return GoogleHealthDistanceAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  /// Builds a request for an inclusive date range using `dailyRollUp`.
  factory GoogleHealthDistanceAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints:dailyRollUp',
    );
    return GoogleHealthDistanceAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.post,
      body: buildCivilRange(
        startDate: startDate,
        endDate: exclusiveDayAfter(endDate),
      ),
    );
  }

  /// Builds a request for raw intraday distance intervals using `list`.
  factory GoogleHealthDistanceAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final filter = buildTimeFilter(
      fieldPath: 'distance.interval.start_time',
      startTime: startTime,
      endTime: endTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthDistanceAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.get,
    );
  }
}
