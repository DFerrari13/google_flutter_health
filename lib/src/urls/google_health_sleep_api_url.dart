import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health sleep data type.
///
/// Sleep is a Session record type; it only supports the `list` endpoint
/// (and write operations that are not exposed by this library). All factories
/// produce `GET` requests with a `filter` on `sleep.interval.start_time`.
class GoogleHealthSleepAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthSleepAPIURL._({
    required super.uri,
  }) : super(method: GoogleHealthRequestMethod.get);

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'sleep';

  /// Builds a request for sleep sessions that started during a single day.
  factory GoogleHealthSleepAPIURL.day({required DateTime date}) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return GoogleHealthSleepAPIURL._build(startTime: start, endTime: end);
  }

  /// Builds a request for sleep sessions that started in the given date range.
  factory GoogleHealthSleepAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    return GoogleHealthSleepAPIURL._build(startTime: start, endTime: end);
  }

  /// Builds a request for sleep sessions that started in the given time window.
  factory GoogleHealthSleepAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return GoogleHealthSleepAPIURL._build(
      startTime: startTime,
      endTime: endTime,
    );
  }

  static GoogleHealthSleepAPIURL _build({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final filter = buildTimeFilter(
      fieldPath: 'sleep.interval.start_time',
      startTime: startTime,
      endTime: endTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthSleepAPIURL._(uri: uri);
  }
}
