import 'google_health_api_url.dart';

/// URL builder for the Google Health total-calories data type.
///
/// Use the factory constructors to build the appropriate URL, then pass the
/// instance to [GoogleHealthCaloriesDataManager.fetch].
///
/// ```dart
/// // Today's total energy expenditure
/// final url = GoogleHealthCaloriesAPIURL.day(date: DateTime.now());
///
/// // Calories over a date range
/// final url = GoogleHealthCaloriesAPIURL.dateRange(
///   startDate: DateTime(2024, 1, 1),
///   endDate: DateTime(2024, 1, 31),
/// );
/// ```
class GoogleHealthCaloriesAPIURL extends GoogleHealthAPIURL {
  GoogleHealthCaloriesAPIURL._({required super.uri});

  /// Builds a URL for a single day's calories using the `dailyRollup` endpoint.
  ///
  /// - [date]: The calendar day to query. Time components are ignored.
  factory GoogleHealthCaloriesAPIURL.day({required DateTime date}) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/total-calories/dataPoints:dailyRollup',
      {'startTime': _formatDate(date), 'endTime': _formatDate(date)},
    );
    return GoogleHealthCaloriesAPIURL._(uri: uri);
  }

  /// Builds a URL for a date range using the `dailyRollup` endpoint.
  ///
  /// Returns one data point per day in the range.
  ///
  /// - [startDate]: First day of the range (inclusive). Time components are ignored.
  /// - [endDate]: Last day of the range (inclusive). Time components are ignored.
  factory GoogleHealthCaloriesAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/total-calories/dataPoints:dailyRollup',
      {'startTime': _formatDate(startDate), 'endTime': _formatDate(endDate)},
    );
    return GoogleHealthCaloriesAPIURL._(uri: uri);
  }

  /// Builds a URL for intraday calories data using the `dataPoints` list endpoint.
  ///
  /// Returns individual calories events within the given time window.
  ///
  /// - [startTime]: Start of the time window (UTC is recommended).
  /// - [endTime]: End of the time window (UTC is recommended).
  factory GoogleHealthCaloriesAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/total-calories/dataPoints',
      {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
      },
    );
    return GoogleHealthCaloriesAPIURL._(uri: uri);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
