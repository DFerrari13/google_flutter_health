import '_request_helpers.dart';
import 'google_health_api_url.dart';

/// URL builder for the Google Health `sleep` data type.
///
/// All factories produce GET requests filtered on `sleep.interval.end_time`
/// (UTC physical time). Non-nap filtering is applied by the manager.
class GoogleHealthSleepAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthSleepAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  static const String dataType = 'sleep';

  /// Sessions whose end_time falls on [date] (UTC midnight–midnight).
  factory GoogleHealthSleepAPIURL.day({required DateTime date}) {
    final start = DateTime.utc(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return GoogleHealthSleepAPIURL._build(startTime: start, endTime: end);
  }

  /// Sessions whose end_time falls in the given UTC date range (inclusive).
  factory GoogleHealthSleepAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final end = DateTime.utc(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    return GoogleHealthSleepAPIURL._build(startTime: start, endTime: end);
  }

  factory GoogleHealthSleepAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return GoogleHealthSleepAPIURL._build(
        startTime: startTime, endTime: endTime);
  }

  static GoogleHealthSleepAPIURL _build({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final filter = buildTimeFilter(
      fieldPath: 'sleep.interval.end_time',
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
