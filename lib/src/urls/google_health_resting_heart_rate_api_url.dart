import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health `daily-resting-heart-rate` data type.
///
/// Resting heart rate is a Daily record — already pre-aggregated by the API
/// — so it only supports the `list` endpoint. The URL builder accepts a date
/// range and filters on the per-day timestamp.
class GoogleHealthRestingHeartRateAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthRestingHeartRateAPIURL._({
    required super.uri,
  }) : super(method: GoogleHealthRequestMethod.get);

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'daily-resting-heart-rate';

  /// Builds a list request covering a single day.
  factory GoogleHealthRestingHeartRateAPIURL.day({required DateTime date}) {
    return GoogleHealthRestingHeartRateAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  /// Builds a list request covering an inclusive date range.
  factory GoogleHealthRestingHeartRateAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    final filter = buildTimeFilter(
      fieldPath: 'daily_resting_heart_rate.civil_date_time.start_time',
      startTime: start,
      endTime: end,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthRestingHeartRateAPIURL._(uri: uri);
  }

  /// Backwards-compatible alias for [dateRange] (replaces the old
  /// `dailyRollup` factory — daily-resting-heart-rate does not support a
  /// daily rollup endpoint, it is already daily).
  @Deprecated('Use dateRange instead.')
  factory GoogleHealthRestingHeartRateAPIURL.dailyRollup({
    required DateTime startDate,
    required DateTime endDate,
  }) =>
      GoogleHealthRestingHeartRateAPIURL.dateRange(
        startDate: startDate,
        endDate: endDate,
      );
}
