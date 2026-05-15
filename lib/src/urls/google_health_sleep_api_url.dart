import 'google_health_api_url.dart';

/// URL builder for the Google Health sleep data type.
///
/// Use the factory constructors to build the appropriate URL, then pass the
/// instance to [GoogleHealthSleepDataManager.fetch].
///
/// Requires the [GoogleHealthScopes.sleepReadonly] scope.
///
/// Sleep data uses the `dataPoints` list endpoint (not `dailyRollup`) because
/// a single sleep session can span midnight. The time window is aligned to UTC
/// day boundaries in [day] and [dateRange].
class GoogleHealthSleepAPIURL extends GoogleHealthAPIURL {
  GoogleHealthSleepAPIURL._({required super.uri});

  /// Builds a URL for sleep sessions that overlap the given calendar day.
  ///
  /// The query window spans from midnight to midnight UTC for [date].
  ///
  /// - [date]: The calendar day to query. Time components are ignored.
  factory GoogleHealthSleepAPIURL.day({required DateTime date}) {
    final start = DateTime.utc(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return GoogleHealthSleepAPIURL._(
      uri: Uri.https(
        'health.googleapis.com',
        '/v4/users/me/dataTypes/sleep/dataPoints',
        {
          'startTime': start.toIso8601String(),
          'endTime': end.toIso8601String(),
        },
      ),
    );
  }

  /// Builds a URL for sleep sessions that overlap a date range.
  ///
  /// The window spans from midnight UTC on [startDate] to midnight UTC on the
  /// day after [endDate].
  ///
  /// - [startDate]: First day of the range (inclusive). Time components are ignored.
  /// - [endDate]: Last day of the range (inclusive). Time components are ignored.
  factory GoogleHealthSleepAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final end = DateTime.utc(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    return GoogleHealthSleepAPIURL._(
      uri: Uri.https(
        'health.googleapis.com',
        '/v4/users/me/dataTypes/sleep/dataPoints',
        {
          'startTime': start.toIso8601String(),
          'endTime': end.toIso8601String(),
        },
      ),
    );
  }

  /// Builds a URL for sleep sessions within an arbitrary time window.
  ///
  /// - [startTime]: Start of the time window (UTC is recommended).
  /// - [endTime]: End of the time window (UTC is recommended).
  factory GoogleHealthSleepAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return GoogleHealthSleepAPIURL._(
      uri: Uri.https(
        'health.googleapis.com',
        '/v4/users/me/dataTypes/sleep/dataPoints',
        {
          'startTime': startTime.toUtc().toIso8601String(),
          'endTime': endTime.toUtc().toIso8601String(),
        },
      ),
    );
  }
}
