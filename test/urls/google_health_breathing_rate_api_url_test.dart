import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthBreathingRateAPIURL', () {
    test('day() builds GET URL with correct date filter', () {
      final url =
          GoogleHealthBreathingRateAPIURL.day(date: DateTime(2025, 6, 12));
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/daily-respiratory-rate/dataPoints',
      );
      final filter = url.uri.queryParameters['filter'];
      expect(filter, isNotNull);
      expect(
        filter,
        'daily_respiratory_rate.date >= "2025-06-12" AND '
        'daily_respiratory_rate.date < "2025-06-13"',
      );
    });

    test('dateRange() uses inclusive start, exclusive end', () {
      final url = GoogleHealthBreathingRateAPIURL.dateRange(
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2025, 6, 7),
      );
      final filter = url.uri.queryParameters['filter'];
      expect(
        filter,
        'daily_respiratory_rate.date >= "2025-06-01" AND '
        'daily_respiratory_rate.date < "2025-06-08"',
      );
    });
  });
}
