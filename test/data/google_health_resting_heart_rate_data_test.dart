import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthRestingHeartRateData', () {
    test('fromJson parses real API shape', () {
      final data = GoogleHealthRestingHeartRateData.fromJson(<String, dynamic>{
        'name': 'users/me/dataTypes/daily-resting-heart-rate/dataPoints/abc',
        'dailyRestingHeartRate': {
          'date': {'year': 2026, 'month': 5, 'day': 26},
          'beatsPerMinute': '62',
          'dailyRestingHeartRateMetadata': {
            'calculationMethod': 'WITH_SLEEP',
          },
        },
      });
      expect(data.startTime, DateTime(2026, 5, 26));
      expect(data.beatsPerMinute, 62.0);
      expect(data.calculationMethod, 'WITH_SLEEP');
    });

    test('fromJson handles numeric beatsPerMinute (defensive)', () {
      final data = GoogleHealthRestingHeartRateData.fromJson(<String, dynamic>{
        'dailyRestingHeartRate': {
          'date': {'year': 2026, 'month': 1, 'day': 1},
          'beatsPerMinute': 58,
        },
      });
      expect(data.beatsPerMinute, 58.0);
      expect(data.calculationMethod, isNull);
    });

    test('fromJson handles empty object gracefully', () {
      final data =
          GoogleHealthRestingHeartRateData.fromJson(<String, dynamic>{});
      expect(data.beatsPerMinute, isNull);
      expect(data.startTime, isNull);
    });
  });
}
