import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthActiveZoneMinutesAPIURL', () {
    test('day() builds POST dailyRollUp request', () {
      final url =
          GoogleHealthActiveZoneMinutesAPIURL.day(date: DateTime(2026, 1, 15));
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/active-zone-minutes/dataPoints:dailyRollUp',
      );
      expect(url.method, GoogleHealthRequestMethod.post);
    });

    test('intraday() filter targets active_zone_minutes.interval.civil_start_time',
        () {
      final url = GoogleHealthActiveZoneMinutesAPIURL.intraday(
        startTime: DateTime.utc(2026, 1, 15, 10),
        endTime: DateTime.utc(2026, 1, 15, 11),
      );
      expect(url.uri.queryParameters['filter'],
          contains('active_zone_minutes.interval.civil_start_time'));
    });
  });
}
