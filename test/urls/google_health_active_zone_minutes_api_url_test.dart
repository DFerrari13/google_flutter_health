import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthActiveZoneMinutesAPIURL', () {
    test('day() builds dailyRollup URL with same start/end date', () {
      final url = GoogleHealthActiveZoneMinutesAPIURL.day(
        date: DateTime(2026, 1, 15),
      );
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/active-zone-minutes/dataPoints:dailyRollup'
        '?startTime=2026-01-15&endTime=2026-01-15',
      );
    });

    test('dateRange() builds dailyRollup URL with provided range', () {
      final url = GoogleHealthActiveZoneMinutesAPIURL.dateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/active-zone-minutes/dataPoints:dailyRollup'
        '?startTime=2026-01-01&endTime=2026-01-31',
      );
    });

    test('intraday() builds dataPoints URL with full ISO timestamps', () {
      final start = DateTime.utc(2026, 1, 15, 10);
      final end = DateTime.utc(2026, 1, 15, 12);
      final url = GoogleHealthActiveZoneMinutesAPIURL.intraday(
        startTime: start,
        endTime: end,
      );
      expect(url.uri.host, 'health.googleapis.com');
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/active-zone-minutes/dataPoints',
      );
      expect(
        url.uri.queryParameters['startTime'],
        start.toIso8601String(),
      );
      expect(
        url.uri.queryParameters['endTime'],
        end.toIso8601String(),
      );
    });
  });
}
