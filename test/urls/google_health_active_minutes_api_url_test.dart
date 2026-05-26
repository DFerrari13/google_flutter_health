import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthActiveMinutesAPIURL', () {
    test('day() builds POST to :rollUp with midnight UTC range and windowSize',
        () {
      final url = GoogleHealthActiveMinutesAPIURL.day(
        date: DateTime(2026, 5, 26),
      );
      expect(url.method, GoogleHealthRequestMethod.post);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/active-minutes/dataPoints:rollUp',
      );
      expect(url.uri.queryParameters, isEmpty);
      expect(url.body, isNotNull);
      final range = url.body!['range'] as Map<String, dynamic>;
      expect(range['startTime'], '2026-05-26T00:00:00.000Z');
      expect(range['endTime'], '2026-05-27T00:00:00.000Z');
      expect(url.body!['windowSize'], '86400s');
    });

    test('dateRange() spans from midnight startDate to midnight after endDate',
        () {
      final url = GoogleHealthActiveMinutesAPIURL.dateRange(
        startDate: DateTime(2026, 5, 26),
        endDate: DateTime(2026, 5, 27),
      );
      expect(url.method, GoogleHealthRequestMethod.post);
      final range = url.body!['range'] as Map<String, dynamic>;
      expect(range['startTime'], '2026-05-26T00:00:00.000Z');
      expect(range['endTime'], '2026-05-28T00:00:00.000Z');
    });
  });
}
