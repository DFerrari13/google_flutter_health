import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health `daily-resting-heart-rate` data type.
class GoogleHealthRestingHeartRateAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthRestingHeartRateAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  static const String dataType = 'daily-resting-heart-rate';

  factory GoogleHealthRestingHeartRateAPIURL.day({required DateTime date}) {
    return GoogleHealthRestingHeartRateAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  factory GoogleHealthRestingHeartRateAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filter = buildCivilDateFilter(
      fieldPath: 'daily_resting_heart_rate.date',
      startDate: startDate,
      endDate: exclusiveDayAfter(endDate),
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthRestingHeartRateAPIURL._(uri: uri);
  }
}
