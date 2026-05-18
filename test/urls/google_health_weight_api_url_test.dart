import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthWeightAPIURL', () {
    test('day() builds POST dailyRollUp request', () {
      final url = GoogleHealthWeightAPIURL.day(date: DateTime(2026, 1, 15));
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/weight/dataPoints:dailyRollUp',
      );
      expect(url.method, GoogleHealthRequestMethod.post);
    });

    test('intraday() builds GET list URL with filter', () {
      final url = GoogleHealthWeightAPIURL.intraday(
        startTime: DateTime.utc(2026, 1, 15),
        endTime: DateTime.utc(2026, 1, 16),
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.queryParameters['filter'],
        contains('weight.sample_time.physical_time'),
      );
    });
  });
}
