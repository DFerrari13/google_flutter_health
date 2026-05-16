import 'google_health_api_url.dart';

/// URL builder for the Google Health exercise data type.
///
/// Exercise events are logged sporadically — only range queries are exposed.
class GoogleHealthExerciseAPIURL extends GoogleHealthAPIURL {
  GoogleHealthExerciseAPIURL._({required super.uri});

  /// Builds a URL for exercise sessions in a date range using `dataPoints`.
  ///
  /// - [startDate]: First day of the range (inclusive). Time components are ignored.
  /// - [endDate]: Last day of the range (inclusive). Time components are ignored.
  factory GoogleHealthExerciseAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final end = DateTime.utc(
      endDate.year,
      endDate.month,
      endDate.day,
    ).add(const Duration(days: 1));
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/exercise/dataPoints',
      {
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
      },
    );
    return GoogleHealthExerciseAPIURL._(uri: uri);
  }

  /// Builds a URL for intraday exercise events using `dataPoints`.
  ///
  /// - [startTime]: Start of the time window (UTC is recommended).
  /// - [endTime]: End of the time window (UTC is recommended).
  factory GoogleHealthExerciseAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/exercise/dataPoints',
      {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
      },
    );
    return GoogleHealthExerciseAPIURL._(uri: uri);
  }
}
