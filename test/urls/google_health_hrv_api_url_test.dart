import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthHrvAPIURL', () {
    test('dateRange() builds GET list URL with HRV date filter', () {
      final url = GoogleHealthHrvAPIURL.dateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 7),
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/daily-heart-rate-variability/dataPoints',
      );
      expect(
        url.uri.queryParameters['filter'],
        contains('daily_heart_rate_variability'),
      );
    });
  });
}
