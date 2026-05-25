import 'google_health_api_url.dart';

/// URL builder for the Google Health `daily-skin-temperature-variation` data
/// type.
///
/// Daily skin-temperature variation is pre-aggregated, supports only `list`.
class GoogleHealthSkinTemperatureAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthSkinTemperatureAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  /// The data-type identifier used by the Google Health API.
  ///
  /// If this returns `404` from the API in your project, swap to
  /// `'daily-skin-temperature'` — the response envelope is handled by both
  /// names in the data class.
  static const String dataType = 'daily-sleep-temperature-derivations';

  factory GoogleHealthSkinTemperatureAPIURL.day({required DateTime date}) {
    return GoogleHealthSkinTemperatureAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  /// The daily-skin-temperature-variation endpoint does not support filter
  /// expressions. Returns all available daily data points (typically ~30 days).
  factory GoogleHealthSkinTemperatureAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
    );
    return GoogleHealthSkinTemperatureAPIURL._(uri: uri);
  }
}
