import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health `daily-oxygen-saturation` data type.
class GoogleHealthOxygenSaturationAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthOxygenSaturationAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  static const String dataType = 'daily-oxygen-saturation';

  factory GoogleHealthOxygenSaturationAPIURL.day({required DateTime date}) {
    return GoogleHealthOxygenSaturationAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  factory GoogleHealthOxygenSaturationAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final filter = buildCivilDateFilter(
      fieldPath: 'daily_oxygen_saturation.date',
      startDate: startDate,
      endDate: exclusiveDayAfter(endDate),
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthOxygenSaturationAPIURL._(uri: uri);
  }
}
