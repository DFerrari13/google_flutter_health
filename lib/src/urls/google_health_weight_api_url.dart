import 'google_health_api_url.dart';

/// URL builder for the Google Health weight data type.
///
/// Weight is logged sporadically — only range queries are exposed.
/// There is no single-day `day()` variant.
class GoogleHealthWeightAPIURL extends GoogleHealthAPIURL {
  GoogleHealthWeightAPIURL._({required super.uri});

  /// Builds a URL for weight measurements in a date range using `dataPoints`.
  ///
  /// Returns every logged weight event within the range.
  ///
  /// - [startDate]: First day of the range (inclusive). Time components are ignored.
  /// - [endDate]: Last day of the range (inclusive). Time components are ignored.
  factory GoogleHealthWeightAPIURL.dateRange({
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
      '/v4/users/me/dataTypes/weight/dataPoints',
      {
        'startTime': start.toIso8601String(),
        'endTime': end.toIso8601String(),
      },
    );
    return GoogleHealthWeightAPIURL._(uri: uri);
  }

  /// Builds a URL for intraday weight events using `dataPoints`.
  ///
  /// - [startTime]: Start of the time window (UTC is recommended).
  /// - [endTime]: End of the time window (UTC is recommended).
  factory GoogleHealthWeightAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/weight/dataPoints',
      {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
      },
    );
    return GoogleHealthWeightAPIURL._(uri: uri);
  }
}
