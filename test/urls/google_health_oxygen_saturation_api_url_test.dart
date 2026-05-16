import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthOxygenSaturationAPIURL', () {
    test('dailyRollup() builds dailyRollup URL with provided range', () {
      final url = GoogleHealthOxygenSaturationAPIURL.dailyRollup(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/daily-oxygen-saturation/dataPoints:dailyRollup'
        '?startTime=2026-01-01&endTime=2026-01-31',
      );
    });

    test('dailyRollup() accepts a single-day range', () {
      final url = GoogleHealthOxygenSaturationAPIURL.dailyRollup(
        startDate: DateTime(2026, 1, 15),
        endDate: DateTime(2026, 1, 15),
      );
      expect(url.uri.queryParameters['startTime'], '2026-01-15');
      expect(url.uri.queryParameters['endTime'], '2026-01-15');
    });
  });
}
