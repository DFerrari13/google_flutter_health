import 'google_health_api_url.dart';

/// URL builder for the Google Health `daily-heart-rate-variability` data type.
class GoogleHealthHrvAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthHrvAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'daily-heart-rate-variability';

  factory GoogleHealthHrvAPIURL.day({required DateTime date}) {
    return GoogleHealthHrvAPIURL.dateRange(startDate: date, endDate: date);
  }

  /// The daily-hrv endpoint does not support filter expressions.
  /// Returns all available daily data points (typically ~30 days).
  factory GoogleHealthHrvAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
    );
    return GoogleHealthHrvAPIURL._(uri: uri);
  }

  @Deprecated('Use dateRange instead.')
  factory GoogleHealthHrvAPIURL.dailyRollup({
    required DateTime startDate,
    required DateTime endDate,
  }) =>
      GoogleHealthHrvAPIURL.dateRange(startDate: startDate, endDate: endDate);
}
