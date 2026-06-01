import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthIrregularRhythmNotificationAPIURL', () {
    test('day() points to correct endpoint', () {
      final url = GoogleHealthIrregularRhythmNotificationAPIURL.day(
        date: DateTime(2025, 5, 31),
      );
      expect(url.uri.host, 'health.googleapis.com');
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/irregular-rhythm-notification/dataPoints',
      );
      expect(url.method, GoogleHealthRequestMethod.get);
    });

    test('day() filters on start_time lower bound only (no upper bound)', () {
      final url = GoogleHealthIrregularRhythmNotificationAPIURL.day(
        date: DateTime(2025, 5, 31),
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(
        filter,
        contains('irregular_rhythm_notification.interval.start_time'),
      );
      expect(filter, contains('>='));
      expect(filter, contains('2025-05-31T00:00:00.000Z'));
      // IRN rejects an upper bound — the filter must not contain `<` or the
      // day-after timestamp.
      expect(filter, isNot(contains('<')));
      expect(filter, isNot(contains('2025-06-01')));
    });

    test('dateRange() filters from startDate lower bound, ignores endDate', () {
      final url = GoogleHealthIrregularRhythmNotificationAPIURL.dateRange(
        startDate: DateTime(2025, 5, 1),
        endDate: DateTime(2025, 5, 31),
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('>='));
      expect(filter, contains('2025-05-01T00:00:00.000Z'));
      expect(filter, isNot(contains('<')));
      expect(filter, isNot(contains('2025-06-01')));
    });

    test('intraday() filters on the given start_time lower bound', () {
      final start = DateTime.utc(2025, 5, 31, 2, 10);
      final url = GoogleHealthIrregularRhythmNotificationAPIURL.intraday(
        startTime: start,
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('>='));
      expect(filter, contains('2025-05-31T02:10:00.000Z'));
      expect(filter, isNot(contains('<')));
    });

    test('all factories use GET method', () {
      final urls = [
        GoogleHealthIrregularRhythmNotificationAPIURL.day(
          date: DateTime(2025, 5, 31),
        ),
        GoogleHealthIrregularRhythmNotificationAPIURL.dateRange(
          startDate: DateTime(2025, 5, 1),
          endDate: DateTime(2025, 5, 31),
        ),
        GoogleHealthIrregularRhythmNotificationAPIURL.intraday(
          startTime: DateTime.utc(2025, 5, 31, 0),
        ),
      ];
      for (final url in urls) {
        expect(url.method, GoogleHealthRequestMethod.get);
      }
    });
  });
}
