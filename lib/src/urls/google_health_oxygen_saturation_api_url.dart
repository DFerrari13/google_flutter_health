import 'google_health_api_url.dart';

/// URL builder for the Google Health daily-oxygen-saturation data type.
///
/// SpO2 is a daily-only metric — only [dailyRollup] is exposed.
/// There is no `day()` or `intraday()` variant.
///
/// ```dart
/// final url = GoogleHealthOxygenSaturationAPIURL.dailyRollup(
///   startDate: DateTime.now().subtract(const Duration(days: 7)),
///   endDate: DateTime.now(),
/// );
/// ```
class GoogleHealthOxygenSaturationAPIURL extends GoogleHealthAPIURL {
  GoogleHealthOxygenSaturationAPIURL._({required super.uri});

  /// Builds a URL for daily SpO2 using the `dailyRollup` endpoint.
  ///
  /// Returns one data point per day in the range.
  ///
  /// - [startDate]: First day of the range (inclusive). Time components are ignored.
  /// - [endDate]: Last day of the range (inclusive). Time components are ignored.
  factory GoogleHealthOxygenSaturationAPIURL.dailyRollup({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/daily-oxygen-saturation/dataPoints:dailyRollup',
      {'startTime': _formatDate(startDate), 'endTime': _formatDate(endDate)},
    );
    return GoogleHealthOxygenSaturationAPIURL._(uri: uri);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
