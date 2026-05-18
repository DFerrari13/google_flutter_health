import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthCaloriesAPIURL', () {
    test('day() builds POST dailyRollUp request for total-calories', () {
      final url = GoogleHealthCaloriesAPIURL.day(date: DateTime(2026, 1, 15));
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/total-calories/dataPoints:dailyRollUp',
      );
      expect(url.method, GoogleHealthRequestMethod.post);
    });

    test('rollUp() builds POST rollUp with windowSize seconds', () {
      final url = GoogleHealthCaloriesAPIURL.rollUp(
        startTime: DateTime.utc(2026, 1, 15),
        endTime: DateTime.utc(2026, 1, 16),
        windowSize: const Duration(hours: 1),
      );
      expect(
        url.uri.toString(),
        'https://health.googleapis.com/v4/users/me/dataTypes/total-calories/dataPoints:rollUp',
      );
      expect(url.body?['windowSize'], '3600s');
    });
  });
}
