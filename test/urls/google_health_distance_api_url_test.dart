import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthDistanceAPIURL', () {
    test('day() builds POST dailyRollUp request', () {
      final url = GoogleHealthDistanceAPIURL.day(date: DateTime(2026, 1, 15));
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/distance/dataPoints:dailyRollUp',
      );
      expect(url.method, GoogleHealthRequestMethod.post);
      expect(url.body?['range'], isNotNull);
    });

    test('intraday() builds GET list request with filter', () {
      final url = GoogleHealthDistanceAPIURL.intraday(
        startTime: DateTime.utc(2026, 1, 15, 10),
        endTime: DateTime.utc(2026, 1, 15, 11),
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(url.uri.queryParameters['filter'],
          contains('distance.interval.start_time'));
    });
  });
}
