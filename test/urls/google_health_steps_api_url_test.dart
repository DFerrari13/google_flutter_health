import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthStepsAPIURL', () {
    test('day() builds POST dailyRollUp with civil range covering one day', () {
      final url = GoogleHealthStepsAPIURL.day(date: DateTime(2026, 1, 15));
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/steps/dataPoints:dailyRollUp',
      );
      expect(url.method, GoogleHealthRequestMethod.post);
      expect(url.body, isNotNull);
      final range = (url.body!['range'] as Map<String, dynamic>);
      expect((range['start'] as Map)['date'],
          {'year': 2026, 'month': 1, 'day': 15});
      expect(
          (range['end'] as Map)['date'], {'year': 2026, 'month': 1, 'day': 16});
    });

    test('dateRange() builds POST dailyRollUp with exclusive civil end', () {
      final url = GoogleHealthStepsAPIURL.dateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/steps/dataPoints:dailyRollUp',
      );
      expect(url.method, GoogleHealthRequestMethod.post);
      final range = (url.body!['range'] as Map<String, dynamic>);
      expect((range['start'] as Map)['date'],
          {'year': 2026, 'month': 1, 'day': 1});
      expect(
          (range['end'] as Map)['date'], {'year': 2026, 'month': 2, 'day': 1});
    });

    test('intraday() builds GET list URL with filter expression', () {
      final start = DateTime.utc(2026, 1, 15, 10);
      final end = DateTime.utc(2026, 1, 15, 12);
      final url = GoogleHealthStepsAPIURL.intraday(
        startTime: start,
        endTime: end,
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(url.body, isNull);
      expect(url.uri.host, 'health.googleapis.com');
      expect(url.uri.path, '/v4/users/me/dataTypes/steps/dataPoints');
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('steps.interval.start_time'));
      expect(filter, contains(start.toIso8601String()));
      expect(filter, contains(end.toIso8601String()));
    });
  });
}
