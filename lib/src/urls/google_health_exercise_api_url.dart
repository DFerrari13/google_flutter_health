import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health `exercise` data type.
///
/// Exercise is a Session record type; only `list` is supported.
class GoogleHealthExerciseAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthExerciseAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'exercise';

  /// Builds a list request for sessions that started during a single day.
  factory GoogleHealthExerciseAPIURL.day({required DateTime date}) {
    final start = DateTime(date.year, date.month, date.day);
    return GoogleHealthExerciseAPIURL._build(
      startTime: start,
      endTime: start.add(const Duration(days: 1)),
    );
  }

  /// Builds a list request for sessions that started in the given date range.
  factory GoogleHealthExerciseAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    return GoogleHealthExerciseAPIURL._build(startTime: start, endTime: end);
  }

  /// Builds a list request for sessions that started in the given time window.
  factory GoogleHealthExerciseAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return GoogleHealthExerciseAPIURL._build(
      startTime: startTime,
      endTime: endTime,
    );
  }

  static GoogleHealthExerciseAPIURL _build({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final filter = buildCivilDateFilter(
      fieldPath: 'exercise.interval.civil_start_time',
      startDate: startTime,
      endDate: endTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthExerciseAPIURL._(uri: uri);
  }
}
