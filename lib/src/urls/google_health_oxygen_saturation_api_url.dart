import 'google_health_api_url.dart';

/// URL builder for the Google Health `daily-oxygen-saturation` data type.
///
/// Daily SpO2 is pre-aggregated, supports only `list`.
class GoogleHealthOxygenSaturationAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthOxygenSaturationAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'daily-oxygen-saturation';

  factory GoogleHealthOxygenSaturationAPIURL.day({required DateTime date}) {
    return GoogleHealthOxygenSaturationAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  /// The daily-oxygen-saturation endpoint does not support filter expressions.
  /// Returns all available daily data points (typically ~30 days).
  factory GoogleHealthOxygenSaturationAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
    );
    return GoogleHealthOxygenSaturationAPIURL._(uri: uri);
  }

  @Deprecated('Use dateRange instead.')
  factory GoogleHealthOxygenSaturationAPIURL.dailyRollup({
    required DateTime startDate,
    required DateTime endDate,
  }) =>
      GoogleHealthOxygenSaturationAPIURL.dateRange(
        startDate: startDate,
        endDate: endDate,
      );
}
