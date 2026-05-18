import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthOxygenSaturationAPIURL', () {
    test('dateRange() builds GET list URL with date filter', () {
      final url = GoogleHealthOxygenSaturationAPIURL.dateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 7),
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/daily-oxygen-saturation/dataPoints',
      );
      expect(
        url.uri.queryParameters['filter'],
        contains('daily_oxygen_saturation'),
      );
    });
  });
}
