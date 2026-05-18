import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health heart rate data type.
///
/// Heart rate is a sample (point-in-time) data type. `dailyRollUp` returns
/// daily aggregates (`beatsPerMinuteAvg`, `beatsPerMinuteMin`,
/// `beatsPerMinuteMax`). `list` (intraday) returns raw samples.
class GoogleHealthHeartRateAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthHeartRateAPIURL._({
    required super.uri,
    required super.method,
    super.body,
  });

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'heart-rate';

  /// Builds a request for a single calendar day using `dailyRollUp`.
  factory GoogleHealthHeartRateAPIURL.day({required DateTime date}) {
    return GoogleHealthHeartRateAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  /// Builds a request for an inclusive date range using `dailyRollUp`.
  factory GoogleHealthHeartRateAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints:dailyRollUp',
    );
    final body = buildCivilRange(
      startDate: startDate,
      endDate: exclusiveDayAfter(endDate),
    );
    return GoogleHealthHeartRateAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.post,
      body: body,
    );
  }

  /// Builds a request for raw intraday heart rate samples using `list`.
  factory GoogleHealthHeartRateAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final filter = buildTimeFilter(
      fieldPath: 'heart_rate.sample_time.physical_time',
      startTime: startTime,
      endTime: endTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthHeartRateAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.get,
    );
  }
}
