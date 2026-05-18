import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthHrvData', () {
    test('fromJson parses civil-day HRV', () {
      final data = GoogleHealthHrvData.fromJson(<String, dynamic>{
        'dailyHeartRateVariability': {
          'rmssd': 42.5,
          'coverage': 0.95,
          'hfPower': 1200.0,
          'lfPower': 800.0,
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
      expect(data.rmssd, 42.5);
      expect(data.coverage, 0.95);
      expect(data.hfPower, 1200.0);
      expect(data.lfPower, 800.0);
      expect(data.startTime, DateTime(2026, 1, 15));
    });

    test('fromJson handles missing fields gracefully', () {
      final data = GoogleHealthHrvData.fromJson(<String, dynamic>{});
      expect(data.rmssd, isNull);
    });
  });
}
