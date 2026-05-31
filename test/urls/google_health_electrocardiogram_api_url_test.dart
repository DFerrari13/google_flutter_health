import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthElectrocardiogramAPIURL', () {
    test('day() points to correct endpoint', () {
      final url = GoogleHealthElectrocardiogramAPIURL.day(
        date: DateTime(2025, 5, 31),
      );
      expect(url.uri.host, 'health.googleapis.com');
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/electrocardiogram/dataPoints',
      );
      expect(url.method, GoogleHealthRequestMethod.get);
    });

    test('day() filter spans UTC midnight-to-midnight', () {
      final url = GoogleHealthElectrocardiogramAPIURL.day(
        date: DateTime(2025, 5, 31),
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('electrocardiogram.interval.start_time'));
      expect(filter, contains('2025-05-31T00:00:00.000Z'));
      expect(filter, contains('2025-06-01T00:00:00.000Z'));
    });

    test('dateRange() filter spans start to day-after-end', () {
      final url = GoogleHealthElectrocardiogramAPIURL.dateRange(
        startDate: DateTime(2025, 5, 1),
        endDate: DateTime(2025, 5, 31),
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('2025-05-01T00:00:00.000Z'));
      expect(filter, contains('2025-06-01T00:00:00.000Z'));
    });

    test('intraday() passes times through unchanged', () {
      final url = GoogleHealthElectrocardiogramAPIURL.intraday(
        startTime: DateTime.utc(2025, 5, 31, 10, 0),
        endTime: DateTime.utc(2025, 5, 31, 10, 5),
      );
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('2025-05-31T10:00:00.000Z'));
      expect(filter, contains('2025-05-31T10:05:00.000Z'));
    });

    test('all factories use GET method', () {
      final urls = [
        GoogleHealthElectrocardiogramAPIURL.day(date: DateTime(2025, 5, 31)),
        GoogleHealthElectrocardiogramAPIURL.dateRange(
          startDate: DateTime(2025, 5, 1),
          endDate: DateTime(2025, 5, 31),
        ),
        GoogleHealthElectrocardiogramAPIURL.intraday(
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
