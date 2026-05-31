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

    test('day() filter spans UTC midnight-to-midnight', () {
      final url = GoogleHealthIrregularRhythmNotificationAPIURL.day(
        date: DateTime(2025, 5, 31),
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(
        filter,
        contains('irregular_rhythm_notification.interval.start_time'),
      );
      expect(filter, contains('2025-05-31T00:00:00.000Z'));
      expect(filter, contains('2025-06-01T00:00:00.000Z'));
    });

    test(
        'dateRange() filter spans start of first day to start of day after end',
        () {
      final url = GoogleHealthIrregularRhythmNotificationAPIURL.dateRange(
        startDate: DateTime(2025, 5, 1),
        endDate: DateTime(2025, 5, 31),
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('2025-05-01T00:00:00.000Z'));
      expect(filter, contains('2025-06-01T00:00:00.000Z'));
    });

    test('intraday() passes times through unchanged', () {
      final start = DateTime.utc(2025, 5, 31, 2, 10);
      final end = DateTime.utc(2025, 5, 31, 2, 25);
      final url = GoogleHealthIrregularRhythmNotificationAPIURL.intraday(
        startTime: start,
        endTime: end,
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('2025-05-31T02:10:00.000Z'));
      expect(filter, contains('2025-05-31T02:25:00.000Z'));
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
          endTime: DateTime.utc(2025, 5, 31, 23),
        ),
      ];
      for (final url in urls) {
        expect(url.method, GoogleHealthRequestMethod.get);
      }
    });
  });
}
