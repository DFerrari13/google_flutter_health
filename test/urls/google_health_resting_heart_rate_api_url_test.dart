import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthRestingHeartRateAPIURL', () {
    test('day() builds GET list URL without filter', () {
      final url = GoogleHealthRestingHeartRateAPIURL.day(date: DateTime(2026, 1, 1));
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/daily-resting-heart-rate/dataPoints',
      );
      expect(url.uri.queryParameters['filter'], isNull);
    });

    test('dateRange() builds GET list URL without filter', () {
      final url = GoogleHealthRestingHeartRateAPIURL.dateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/daily-resting-heart-rate/dataPoints',
      );
      expect(url.uri.queryParameters['filter'], isNull);
    });
  });
}
