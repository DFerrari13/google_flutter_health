import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthOxygenSaturationData', () {
    test('fromJson parses civil-day SpO2', () {
      final data = GoogleHealthOxygenSaturationData.fromJson(<String, dynamic>{
        'dailyOxygenSaturation': {
          'percentageAvg': 96.5,
          'percentageMin': 93.0,
          'percentageMax': 99.0,
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
      expect(data.percentageAvg, 96.5);
      expect(data.percentageMin, 93.0);
      expect(data.percentageMax, 99.0);
      expect(data.startTime, DateTime(2026, 1, 15));
    });

    test('fromJson handles missing fields gracefully', () {
      final data =
          GoogleHealthOxygenSaturationData.fromJson(<String, dynamic>{});
      expect(data.percentageAvg, isNull);
    });
  });
}
