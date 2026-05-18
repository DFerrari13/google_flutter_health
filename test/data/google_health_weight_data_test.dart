import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthWeightData', () {
    test('fromJson parses a raw weight sample', () {
      final data = GoogleHealthWeightData.fromJson(<String, dynamic>{
        'weight': {
          'weightKilograms': 72.5,
          'sampleTime': {'physicalTime': '2026-01-15T08:00:00Z'},
        },
      });
      expect(data.weightKg, 72.5);
      expect(
        data.sampleTime,
        DateTime.parse('2026-01-15T08:00:00Z').toLocal(),
      );
    });

    test('fromJson parses dailyRollUp aggregates', () {
      final data = GoogleHealthWeightData.fromJson(<String, dynamic>{
        'civilStartTime': {
          'date': {'year': 2026, 'month': 1, 'day': 15},
        },
        'civilEndTime': {
          'date': {'year': 2026, 'month': 1, 'day': 16},
        },
        'weight': {
          'weightKilogramsAvg': 72.5,
          'weightKilogramsMin': 72.0,
          'weightKilogramsMax': 73.0,
        },
      });
      expect(data.weightKg, 72.5);
      expect(data.weightKgMin, 72.0);
      expect(data.weightKgMax, 73.0);
    });

    test('fromJson handles missing fields gracefully', () {
      final data = GoogleHealthWeightData.fromJson(<String, dynamic>{});
      expect(data.weightKg, isNull);
    });
  });
}
