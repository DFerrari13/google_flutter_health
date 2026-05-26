import '_request_helpers.dart';
import 'google_health_api_url.dart';

class GoogleHealthSkinTemperatureAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthSkinTemperatureAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  static const String dataType = 'daily-sleep-temperature-derivations';

  factory GoogleHealthSkinTemperatureAPIURL.day({required DateTime date}) {
    return GoogleHealthSkinTemperatureAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  factory GoogleHealthSkinTemperatureAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filter = buildCivilDateFilter(
      fieldPath: 'daily_sleep_temperature_derivations.date',
      startDate: startDate,
      endDate: exclusiveDayAfter(endDate),
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthSkinTemperatureAPIURL._(uri: uri);
  }
}
