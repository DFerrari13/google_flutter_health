import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthOxygenSaturationData', () {
    test('fromJson parses real API field names', () {
      final data = GoogleHealthOxygenSaturationData.fromJson({
        'name': 'users/me/dataTypes/daily-oxygen-saturation/dataPoints/abc',
        'dailyOxygenSaturation': {
          'date': {'year': 2026, 'month': 1, 'day': 15},
          'averagePercentage': 96.5,
          'lowerBoundPercentage': 93.0,
          'upperBoundPercentage': 99.0,
          'standardDeviationPercentage': 1.2,
        },
      });
      expect(data.name, contains('daily-oxygen-saturation'));
      expect(data.startTime, DateTime(2026, 1, 15));
      expect(data.percentageAvg, 96.5);
      expect(data.percentageMin, 93.0);
      expect(data.percentageMax, 99.0);
      expect(data.percentageStdDev, 1.2);
    });

    test('fromJson handles missing optional standardDeviationPercentage', () {
      final data = GoogleHealthOxygenSaturationData.fromJson({
        'dailyOxygenSaturation': {
          'date': {'year': 2026, 'month': 3, 'day': 10},
          'averagePercentage': 97.0,
          'lowerBoundPercentage': 95.0,
          'upperBoundPercentage': 99.0,
        },
      });
      expect(data.percentageAvg, 97.0);
      expect(data.percentageStdDev, isNull);
    });

    test('fromJson handles empty object gracefully', () {
      final data = GoogleHealthOxygenSaturationData.fromJson({});
      expect(data.percentageAvg, isNull);
      expect(data.startTime, isNull);
    });
  });
}
