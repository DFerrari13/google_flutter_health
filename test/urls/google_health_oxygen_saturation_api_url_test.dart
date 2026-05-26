import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthOxygenSaturationAPIURL', () {
    test('day() builds GET URL with correct date filter', () {
      final url = GoogleHealthOxygenSaturationAPIURL.day(
        date: DateTime(2026, 1, 15),
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/daily-oxygen-saturation/dataPoints',
      );
      final filter = url.uri.queryParameters['filter'];
      expect(filter, isNotNull);
      expect(
        filter,
        'daily_oxygen_saturation.date >= "2026-01-15" AND '
        'daily_oxygen_saturation.date < "2026-01-16"',
      );
    });

    test('dateRange() builds GET URL with inclusive start, exclusive end', () {
      final url = GoogleHealthOxygenSaturationAPIURL.dateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 7),
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/daily-oxygen-saturation/dataPoints',
      );
      final filter = url.uri.queryParameters['filter'];
      expect(filter, isNotNull);
      expect(
        filter,
        'daily_oxygen_saturation.date >= "2026-01-01" AND '
        'daily_oxygen_saturation.date < "2026-01-08"',
      );
    });
  });
}
