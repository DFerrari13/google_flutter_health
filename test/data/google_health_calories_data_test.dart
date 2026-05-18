import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthCaloriesData', () {
    test('fromJson parses dailyRollUp aggregate', () {
      final data = GoogleHealthCaloriesData.fromJson(<String, dynamic>{
        'civilStartTime': {
          'date': {'year': 2026, 'month': 1, 'day': 15},
        },
        'civilEndTime': {
          'date': {'year': 2026, 'month': 1, 'day': 16},
        },
        'totalCalories': {'energyKilocaloriesSum': 2300.0},
      });
      expect(data.calories, 2300.0);
      expect(data.startTime, DateTime(2026, 1, 15));
    });

    test('fromJson handles missing fields gracefully', () {
      final data = GoogleHealthCaloriesData.fromJson(<String, dynamic>{});
      expect(data.calories, isNull);
    });
  });
}
