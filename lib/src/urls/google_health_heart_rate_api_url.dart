import 'google_health_api_url.dart';

/// URL builder for the Google Health heart rate data type.
///
/// Use the factory constructors to build the appropriate URL, then pass the
/// instance to [GoogleHealthHeartRateDataManager.fetch].
///
/// Requires the [GoogleHealthScopes.healthMetricsReadonly] scope.
class GoogleHealthHeartRateAPIURL extends GoogleHealthAPIURL {
  GoogleHealthHeartRateAPIURL._({required super.uri});

  /// Builds a URL for a single day's heart rate summary using `dailyRollup`.
  ///
  /// - [date]: The calendar day to query. Time components are ignored.
  factory GoogleHealthHeartRateAPIURL.day({required DateTime date}) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/heart-rate/dataPoints:dailyRollup',
      {'startTime': _formatDate(date), 'endTime': _formatDate(date)},
    );
    return GoogleHealthHeartRateAPIURL._(uri: uri);
  }

  /// Builds a URL for heart rate summaries over a date range using `dailyRollup`.
  ///
  /// Returns one data point per day in the range.
  ///
  /// - [startDate]: First day of the range (inclusive). Time components are ignored.
  /// - [endDate]: Last day of the range (inclusive). Time components are ignored.
  factory GoogleHealthHeartRateAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/heart-rate/dataPoints:dailyRollup',
      {'startTime': _formatDate(startDate), 'endTime': _formatDate(endDate)},
    );
    return GoogleHealthHeartRateAPIURL._(uri: uri);
  }

  /// Builds a URL for intraday heart rate readings using the `dataPoints` list endpoint.
  ///
  /// - [startTime]: Start of the time window (UTC is recommended).
  /// - [endTime]: End of the time window (UTC is recommended).
  factory GoogleHealthHeartRateAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/heart-rate/dataPoints',
      {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
      },
    );
    return GoogleHealthHeartRateAPIURL._(uri: uri);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
