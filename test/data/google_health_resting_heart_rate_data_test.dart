import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthRestingHeartRateData', () {
    test('fromJson parses civil-day resting heart rate', () {
      final data = GoogleHealthRestingHeartRateData.fromJson(<String, dynamic>{
        'dailyRestingHeartRate': {
          'beatsPerMinute': 58,
          'civilDateTime': {
            'startTime': {
              'date': {'year': 2026, 'month': 1, 'day': 15},
            },
            'endTime': {
              'date': {'year': 2026, 'month': 1, 'day': 16},
            },
          },
        },
      });
      expect(data.beatsPerMinute, 58);
      expect(data.startTime, DateTime(2026, 1, 15));
    });

    test('fromJson handles missing fields gracefully', () {
      final data =
          GoogleHealthRestingHeartRateData.fromJson(<String, dynamic>{});
      expect(data.beatsPerMinute, isNull);
    });
  });
}
