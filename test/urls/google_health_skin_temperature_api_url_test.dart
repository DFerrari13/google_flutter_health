import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthSkinTemperatureAPIURL', () {
    test('day() builds GET URL with correct date filter', () {
      final url =
          GoogleHealthSkinTemperatureAPIURL.day(date: DateTime(2025, 6, 12));
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/daily-sleep-temperature-derivations/dataPoints',
      );
      final filter = url.uri.queryParameters['filter'];
      expect(filter, isNotNull);
      expect(
        filter,
        'daily_sleep_temperature_derivations.date >= "2025-06-12" AND '
        'daily_sleep_temperature_derivations.date < "2025-06-13"',
      );
    });

    test('dateRange() uses inclusive start, exclusive end', () {
      final url = GoogleHealthSkinTemperatureAPIURL.dateRange(
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2025, 6, 7),
      );
      final filter = url.uri.queryParameters['filter'];
      expect(filter, isNotNull);
      expect(
        filter,
        'daily_sleep_temperature_derivations.date >= "2025-06-01" AND '
        'daily_sleep_temperature_derivations.date < "2025-06-08"',
      );
    });
  });
}
