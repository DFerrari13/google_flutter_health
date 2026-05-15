import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthSleepAPIURL', () {
    test('day() builds dataPoints URL spanning the whole UTC day', () {
      final url = GoogleHealthSleepAPIURL.day(date: DateTime(2026, 1, 15));
      expect(url.uri.host, 'health.googleapis.com');
      expect(url.uri.path, '/v4/users/me/dataTypes/sleep/dataPoints');
      expect(
        url.uri.queryParameters['startTime'],
        DateTime.utc(2026, 1, 15).toIso8601String(),
      );
      expect(
        url.uri.queryParameters['endTime'],
        DateTime.utc(2026, 1, 16).toIso8601String(),
      );
    });

    test('dateRange() spans from startDate 00:00 UTC to endDate+1 00:00 UTC',
        () {
      final url = GoogleHealthSleepAPIURL.dateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      expect(
        url.uri.queryParameters['startTime'],
        DateTime.utc(2026, 1, 1).toIso8601String(),
      );
      expect(
        url.uri.queryParameters['endTime'],
        DateTime.utc(2026, 2, 1).toIso8601String(),
      );
    });

    test('intraday() uses provided ISO timestamps verbatim', () {
      final start = DateTime.utc(2026, 1, 15, 22);
      final end = DateTime.utc(2026, 1, 16, 6);
      final url = GoogleHealthSleepAPIURL.intraday(
        startTime: start,
        endTime: end,
      );
      expect(url.uri.queryParameters['startTime'], start.toIso8601String());
      expect(url.uri.queryParameters['endTime'], end.toIso8601String());
    });
  });
}
