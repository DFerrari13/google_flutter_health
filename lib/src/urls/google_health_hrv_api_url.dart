import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health `daily-heart-rate-variability` data type.
class GoogleHealthHrvAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthHrvAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'daily-heart-rate-variability';

  factory GoogleHealthHrvAPIURL.day({required DateTime date}) {
    return GoogleHealthHrvAPIURL.dateRange(startDate: date, endDate: date);
  }

  factory GoogleHealthHrvAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    final filter = buildTimeFilter(
      fieldPath:
          'daily_heart_rate_variability.civil_date_time.start_time',
      startTime: start,
      endTime: end,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
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
