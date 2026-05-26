import 'google_health_api_url.dart';

/// URL builder for the Google Health `sedentary-period:rollUp` endpoint.
///
/// POSTs to the `sedentary-period/dataPoints:rollUp` endpoint with a
/// `range` + `windowSize` body, returning one rollup point per UTC calendar
/// day. Each point's `SedentaryPeriodRollupValue` contains a `durationSum`
/// (total time the user spent sedentary during the window).
class GoogleHealthSedentaryPeriodAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthSedentaryPeriodAPIURL._({
    required super.uri,
    required super.body,
  }) : super(method: GoogleHealthRequestMethod.post);

  static const String _rollUpPath =
      '/v4/users/me/dataTypes/sedentary-period/dataPoints:rollUp';

  /// Daily rollup for the UTC calendar day containing [date].
  factory GoogleHealthSedentaryPeriodAPIURL.day({required DateTime date}) {
    final start = DateTime.utc(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return GoogleHealthSedentaryPeriodAPIURL._build(
      startTime: start,
      endTime: end,
    );
  }

  /// Multi-day rollup: one sedentary-period point per UTC calendar day.
  factory GoogleHealthSedentaryPeriodAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final end = DateTime.utc(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    return GoogleHealthSedentaryPeriodAPIURL._build(
      startTime: start,
      endTime: end,
    );
  }

  static GoogleHealthSedentaryPeriodAPIURL _build({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final uri = Uri.https('health.googleapis.com', _rollUpPath);
    final body = <String, dynamic>{
      'range': {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      },
      'windowSize': '86400s',
    };
    return GoogleHealthSedentaryPeriodAPIURL._(uri: uri, body: body);
  }
}
