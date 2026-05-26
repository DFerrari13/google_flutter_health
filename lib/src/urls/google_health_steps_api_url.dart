import 'google_health_api_url.dart';

/// URL builder for the Google Health `steps:rollUp` endpoint.
///
/// Uses a POST request with a `range` + `windowSize` body instead of a
/// filter query parameter. Each call returns one [StepsRollupValue] per
/// calendar day, containing the total step count (`countSum`) for that day.
class GoogleHealthStepsAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthStepsAPIURL._({
    required super.uri,
    required super.body,
  }) : super(method: GoogleHealthRequestMethod.post);

  static const String _rollUpPath =
      '/v4/users/me/dataTypes/steps/dataPoints:rollUp';

  /// Daily rollup: total steps for the UTC calendar day containing [date].
  ///
  /// Returns a single rollup point whose `countSum` equals the sum of all
  /// intraday intervals within that day.
  factory GoogleHealthStepsAPIURL.day({required DateTime date}) {
    final start = DateTime.utc(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return GoogleHealthStepsAPIURL._build(startTime: start, endTime: end);
  }

  /// Multi-day rollup: one step-count point per UTC calendar day in the range.
  ///
  /// [startDate] is inclusive; [endDate] is inclusive. Both are interpreted as
  /// UTC calendar dates regardless of the local timezone.
  factory GoogleHealthStepsAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final end = DateTime.utc(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    return GoogleHealthStepsAPIURL._build(startTime: start, endTime: end);
  }

  static GoogleHealthStepsAPIURL _build({
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
    return GoogleHealthStepsAPIURL._(uri: uri, body: body);
  }
}
