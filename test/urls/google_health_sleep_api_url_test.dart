import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthSleepAPIURL', () {
    test('day() builds GET URL filtered on sleep.interval.end_time (UTC)', () {
      final url = GoogleHealthSleepAPIURL.day(date: DateTime(2026, 5, 26));
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(url.uri.path, '/v4/users/me/dataTypes/sleep/dataPoints');
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('sleep.interval.end_time'));
      expect(filter, contains('2026-05-26T00:00:00.000Z'));
      expect(filter, contains('2026-05-27T00:00:00.000Z'));
    });

    test(
        'dateRange() spans UTC midnight of startDate to midnight after endDate',
        () {
      final url = GoogleHealthSleepAPIURL.dateRange(
        startDate: DateTime(2026, 5, 25),
        endDate: DateTime(2026, 5, 26),
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('sleep.interval.end_time'));
      expect(filter, contains('2026-05-25T00:00:00.000Z'));
      expect(filter, contains('2026-05-27T00:00:00.000Z'));
    });
  });
}
