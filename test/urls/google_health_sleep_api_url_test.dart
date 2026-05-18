import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthSleepAPIURL', () {
    test('day() builds GET list URL filtered on sleep.interval.start_time', () {
      final url = GoogleHealthSleepAPIURL.day(date: DateTime(2026, 1, 15));
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(url.uri.path, '/v4/users/me/dataTypes/sleep/dataPoints');
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('sleep.interval.start_time'));
    });

    test('dateRange() covers startDate through endDate inclusive', () {
      final url = GoogleHealthSleepAPIURL.dateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(
        filter,
        contains(DateTime(2026, 1, 1).toUtc().toIso8601String()),
      );
      expect(
        filter,
        contains(DateTime(2026, 2, 1).toUtc().toIso8601String()),
      );
    });
  });
}
