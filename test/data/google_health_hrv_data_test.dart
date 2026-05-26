import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthHrvData', () {
    test('fromJson parses real API field names', () {
      final data = GoogleHealthHrvData.fromJson(<String, dynamic>{
        'name': 'users/me/dataTypes/daily-heart-rate-variability/dataPoints/x',
        'dailyHeartRateVariability': {
          'date': {'year': 2025, 'month': 6, 'day': 12},
          'averageHeartRateVariabilityMilliseconds': 38.5,
          'nonRemHeartRateBeatsPerMinute': '62',
          'entropy': 1.23,
          'deepSleepRootMeanSquareOfSuccessiveDifferencesMilliseconds': 42.0,
        },
      });
      expect(data.startTime, DateTime(2025, 6, 12));
      expect(data.rmssd, 38.5);
      expect(data.nonRemBpm, 62);
      expect(data.entropy, 1.23);
      expect(data.deepSleepRmssdMs, 42.0);
    });

    test('fromJson handles optional fields missing', () {
      final data = GoogleHealthHrvData.fromJson(<String, dynamic>{
        'dailyHeartRateVariability': {
          'date': {'year': 2025, 'month': 6, 'day': 12},
          'averageHeartRateVariabilityMilliseconds': 40.0,
        },
      });
      expect(data.rmssd, 40.0);
      expect(data.nonRemBpm, isNull);
      expect(data.entropy, isNull);
      expect(data.deepSleepRmssdMs, isNull);
    });

    test('fromJson handles empty object gracefully', () {
      final data = GoogleHealthHrvData.fromJson(<String, dynamic>{});
      expect(data.rmssd, isNull);
      expect(data.startTime, isNull);
    });
  });
}
