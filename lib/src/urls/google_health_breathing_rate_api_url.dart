import 'google_health_api_url.dart';

/// URL builder for the Google Health `daily-breathing-rate` data type.
///
/// Daily breathing rate is pre-aggregated, supports only `list`.
class GoogleHealthBreathingRateAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthBreathingRateAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  /// The data-type identifier used by the Google Health API.
  ///
  /// If this returns `404` from the API in your project, swap to
  /// `'daily-respiratory-rate'` — the response envelope is handled by both
  /// names in the data class.
  static const String dataType = 'daily-respiratory-rate';

  factory GoogleHealthBreathingRateAPIURL.day({required DateTime date}) {
    return GoogleHealthBreathingRateAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  /// The daily-breathing-rate endpoint does not support filter expressions.
  /// Returns all available daily data points (typically ~30 days).
  factory GoogleHealthBreathingRateAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
    );
    return GoogleHealthBreathingRateAPIURL._(uri: uri);
  }
}
