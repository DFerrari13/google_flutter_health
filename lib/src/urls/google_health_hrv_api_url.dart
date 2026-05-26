import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health `daily-heart-rate-variability` data type.
class GoogleHealthHrvAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthHrvAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  static const String dataType = 'daily-heart-rate-variability';

  factory GoogleHealthHrvAPIURL.day({required DateTime date}) {
    return GoogleHealthHrvAPIURL.dateRange(startDate: date, endDate: date);
  }

  factory GoogleHealthHrvAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filter = buildCivilDateFilter(
      fieldPath: 'daily_heart_rate_variability.date',
      startDate: startDate,
      endDate: exclusiveDayAfter(endDate),
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthHrvAPIURL._(uri: uri);
  }
}
