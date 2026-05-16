import 'google_health_api_url.dart';

/// URL builder for the Google Health daily-resting-heart-rate data type.
///
/// Resting heart rate is a daily-only metric — only [dailyRollup] is exposed.
/// There is no `day()` or `intraday()` variant.
///
/// ```dart
/// // Last 7 days of resting heart rate
/// final url = GoogleHealthRestingHeartRateAPIURL.dailyRollup(
///   startDate: DateTime.now().subtract(const Duration(days: 7)),
///   endDate: DateTime.now(),
/// );
/// ```
class GoogleHealthRestingHeartRateAPIURL extends GoogleHealthAPIURL {
  GoogleHealthRestingHeartRateAPIURL._({required super.uri});

  /// Builds a URL for daily resting heart rate using the `dailyRollup` endpoint.
  ///
  /// Returns one data point per day in the range.
  ///
  /// - [startDate]: First day of the range (inclusive). Time components are ignored.
  /// - [endDate]: Last day of the range (inclusive). Time components are ignored.
  factory GoogleHealthRestingHeartRateAPIURL.dailyRollup({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/daily-resting-heart-rate/dataPoints:dailyRollup',
      {'startTime': _formatDate(startDate), 'endTime': _formatDate(endDate)},
    );
    return GoogleHealthRestingHeartRateAPIURL._(uri: uri);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
