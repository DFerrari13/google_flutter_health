import 'google_health_api_url.dart';

/// URL builder for the Google Health active-zone-minutes data type.
///
/// Use the factory constructors to build the appropriate URL, then pass the
/// instance to [GoogleHealthActiveZoneMinutesDataManager.fetch].
///
/// ```dart
/// // Today's active zone minutes
/// final url = GoogleHealthActiveZoneMinutesAPIURL.day(date: DateTime.now());
/// ```
class GoogleHealthActiveZoneMinutesAPIURL extends GoogleHealthAPIURL {
  GoogleHealthActiveZoneMinutesAPIURL._({required super.uri});

  /// Builds a URL for a single day's AZM using the `dailyRollup` endpoint.
  ///
  /// - [date]: The calendar day to query. Time components are ignored.
  factory GoogleHealthActiveZoneMinutesAPIURL.day({required DateTime date}) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/active-zone-minutes/dataPoints:dailyRollup',
      {'startTime': _formatDate(date), 'endTime': _formatDate(date)},
    );
    return GoogleHealthActiveZoneMinutesAPIURL._(uri: uri);
  }

  /// Builds a URL for a date range using the `dailyRollup` endpoint.
  ///
  /// Returns one data point per day in the range.
  ///
  /// - [startDate]: First day of the range (inclusive). Time components are ignored.
  /// - [endDate]: Last day of the range (inclusive). Time components are ignored.
  factory GoogleHealthActiveZoneMinutesAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/active-zone-minutes/dataPoints:dailyRollup',
      {'startTime': _formatDate(startDate), 'endTime': _formatDate(endDate)},
    );
    return GoogleHealthActiveZoneMinutesAPIURL._(uri: uri);
  }

  /// Builds a URL for intraday AZM data using the `dataPoints` list endpoint.
  ///
  /// Returns individual AZM events within the given time window.
  ///
  /// - [startTime]: Start of the time window (UTC is recommended).
  /// - [endTime]: End of the time window (UTC is recommended).
  factory GoogleHealthActiveZoneMinutesAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/active-zone-minutes/dataPoints',
      {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
      },
    );
    return GoogleHealthActiveZoneMinutesAPIURL._(uri: uri);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
