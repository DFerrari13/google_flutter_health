import 'google_health_api_url.dart';

/// URL builder for the Google Health steps data type.
///
/// Use the factory constructors to build the appropriate URL, then pass the
/// instance to [GoogleHealthStepsDataManager.fetch].
///
/// ```dart
/// // Today's step count
/// final url = GoogleHealthStepsAPIURL.day(date: DateTime.now());
///
/// // Step count over a date range
/// final url = GoogleHealthStepsAPIURL.dateRange(
///   startDate: DateTime(2024, 1, 1),
///   endDate: DateTime(2024, 1, 31),
/// );
/// ```
class GoogleHealthStepsAPIURL extends GoogleHealthAPIURL {
  GoogleHealthStepsAPIURL._({required super.uri});

  /// Builds a URL for a single day's step count using the `dailyRollup` endpoint.
  ///
  /// - [date]: The calendar day to query. Time components are ignored.
  factory GoogleHealthStepsAPIURL.day({required DateTime date}) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/steps/dataPoints:dailyRollup',
      {'startTime': _formatDate(date), 'endTime': _formatDate(date)},
    );
    return GoogleHealthStepsAPIURL._(uri: uri);
  }

  /// Builds a URL for a date range using the `dailyRollup` endpoint.
  ///
  /// Returns one data point per day in the range.
  ///
  /// - [startDate]: First day of the range (inclusive). Time components are ignored.
  /// - [endDate]: Last day of the range (inclusive). Time components are ignored.
  factory GoogleHealthStepsAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/steps/dataPoints:dailyRollup',
      {'startTime': _formatDate(startDate), 'endTime': _formatDate(endDate)},
    );
    return GoogleHealthStepsAPIURL._(uri: uri);
  }

  /// Builds a URL for intraday step data using the `dataPoints` list endpoint.
  ///
  /// Returns individual step events within the given time window.
  ///
  /// - [startTime]: Start of the time window (UTC is recommended).
  /// - [endTime]: End of the time window (UTC is recommended).
  factory GoogleHealthStepsAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/steps/dataPoints',
      {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
      },
    );
    return GoogleHealthStepsAPIURL._(uri: uri);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
