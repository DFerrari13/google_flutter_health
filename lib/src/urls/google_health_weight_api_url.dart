import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health `weight` data type.
///
/// Weight is a Sample record type. The API supports `list` (raw samples),
/// `rollUp`, and `dailyRollUp`.
class GoogleHealthWeightAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthWeightAPIURL._({
    required super.uri,
    required super.method,
    super.body,
  });

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'weight';

  /// Builds a `dailyRollUp` request covering a single day.
  factory GoogleHealthWeightAPIURL.day({required DateTime date}) {
    return GoogleHealthWeightAPIURL.dateRange(startDate: date, endDate: date);
  }

  /// Builds a `dailyRollUp` request covering an inclusive date range.
  factory GoogleHealthWeightAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints:dailyRollUp',
    );
    return GoogleHealthWeightAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.post,
      body: buildCivilRange(
        startDate: startDate,
        endDate: exclusiveDayAfter(endDate),
      ),
    );
  }

  /// Builds a `list` request returning raw weight samples in the window.
  factory GoogleHealthWeightAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final filter = buildTimeFilter(
      fieldPath: 'weight.sample_time.physical_time',
      startTime: startTime,
      endTime: endTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthWeightAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.get,
    );
  }
}
