import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthStepsAPIURL', () {
    test('day() builds POST to :rollUp with midnight UTC range and windowSize',
        () {
      final url = GoogleHealthStepsAPIURL.day(date: DateTime(2025, 6, 12));
      expect(url.method, GoogleHealthRequestMethod.post);
      expect(url.uri.path, '/v4/users/me/dataTypes/steps/dataPoints:rollUp');
      expect(url.uri.queryParameters, isEmpty);
      expect(url.body, isNotNull);
      final range = url.body!['range'] as Map<String, dynamic>;
      expect(range['startTime'], '2025-06-12T00:00:00.000Z');
      expect(range['endTime'], '2025-06-13T00:00:00.000Z');
      expect(url.body!['windowSize'], '86400s');
    });

    test(
        'dateRange() spans from midnight of startDate to midnight after endDate',
        () {
      final url = GoogleHealthStepsAPIURL.dateRange(
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2025, 6, 7),
      );
      expect(url.method, GoogleHealthRequestMethod.post);
      expect(url.uri.path, '/v4/users/me/dataTypes/steps/dataPoints:rollUp');
      final range = url.body!['range'] as Map<String, dynamic>;
      expect(range['startTime'], '2025-06-01T00:00:00.000Z');
      expect(range['endTime'], '2025-06-08T00:00:00.000Z');
      expect(url.body!['windowSize'], '86400s');
    });
  });
}
