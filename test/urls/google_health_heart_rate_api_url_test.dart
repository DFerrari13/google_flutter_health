import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthHeartRateAPIURL', () {
    test('day() builds POST dailyRollUp with civil range', () {
      final url = GoogleHealthHeartRateAPIURL.day(date: DateTime(2026, 1, 15));
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/heart-rate/dataPoints:dailyRollUp',
      );
      expect(url.method, GoogleHealthRequestMethod.post);
    });

    test('intraday() filter targets heart_rate.sample_time.physical_time', () {
      final start = DateTime.utc(2026, 1, 15, 10);
      final end = DateTime.utc(2026, 1, 15, 12);
      final url = GoogleHealthHeartRateAPIURL.intraday(
        startTime: start,
        endTime: end,
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(url.uri.path, '/v4/users/me/dataTypes/heart-rate/dataPoints');
      final filter = url.uri.queryParameters['filter']!;
      expect(filter, contains('heart_rate.sample_time.physical_time'));
      expect(filter, contains(start.toIso8601String()));
      expect(filter, contains(end.toIso8601String()));
    });
  });
}
