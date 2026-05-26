import '_request_helpers.dart';
import 'google_health_api_url.dart';

class GoogleHealthBreathingRateAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthBreathingRateAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  static const String dataType = 'daily-respiratory-rate';

  factory GoogleHealthBreathingRateAPIURL.day({required DateTime date}) {
    return GoogleHealthBreathingRateAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  factory GoogleHealthBreathingRateAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filter = buildCivilDateFilter(
      fieldPath: 'daily_respiratory_rate.date',
      startDate: startDate,
      endDate: exclusiveDayAfter(endDate),
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthBreathingRateAPIURL._(uri: uri);
  }
}
