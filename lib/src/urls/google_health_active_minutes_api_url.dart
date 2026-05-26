import 'google_health_api_url.dart';

/// URL builder for the Google Health `active-minutes:rollUp` endpoint.
///
/// POSTs to the `active-minutes/dataPoints:rollUp` endpoint with a
/// `range` + `windowSize` body, returning one rollup point per UTC calendar
/// day. Each point's `ActiveMinutesRollupValue` contains a breakdown by
/// activity level (LIGHTLY_ACTIVE, MODERATELY_ACTIVE, VERY_ACTIVE).
class GoogleHealthActiveMinutesAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthActiveMinutesAPIURL._({
    required super.uri,
    required super.body,
  }) : super(method: GoogleHealthRequestMethod.post);

  static const String _rollUpPath =
      '/v4/users/me/dataTypes/active-minutes/dataPoints:rollUp';

  /// Daily rollup for the UTC calendar day containing [date].
  factory GoogleHealthActiveMinutesAPIURL.day({required DateTime date}) {
    final start = DateTime.utc(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return GoogleHealthActiveMinutesAPIURL._build(
      startTime: start,
      endTime: end,
    );
  }

  /// Multi-day rollup: one active-minutes point per UTC calendar day.
  factory GoogleHealthActiveMinutesAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final end = DateTime.utc(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    return GoogleHealthActiveMinutesAPIURL._build(
      startTime: start,
      endTime: end,
    );
  }

  static GoogleHealthActiveMinutesAPIURL _build({
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
    return GoogleHealthActiveMinutesAPIURL._(uri: uri, body: body);
  }
}
