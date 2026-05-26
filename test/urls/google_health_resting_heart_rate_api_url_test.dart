import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthRestingHeartRateAPIURL', () {
    test('day() builds GET URL with correct date filter', () {
      final url = GoogleHealthRestingHeartRateAPIURL.day(
        date: DateTime(2026, 5, 26),
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/daily-resting-heart-rate/dataPoints',
      );
      final filter = url.uri.queryParameters['filter'];
      expect(filter, isNotNull);
      expect(
        filter,
        'daily_resting_heart_rate.date >= "2026-05-26" AND '
        'daily_resting_heart_rate.date < "2026-05-27"',
      );
    });

    test('dateRange() uses inclusive start, exclusive end', () {
      final url = GoogleHealthRestingHeartRateAPIURL.dateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      final filter = url.uri.queryParameters['filter'];
      expect(filter, isNotNull);
      expect(
        filter,
        'daily_resting_heart_rate.date >= "2026-01-01" AND '
        'daily_resting_heart_rate.date < "2026-02-01"',
      );
    });
  });
}
