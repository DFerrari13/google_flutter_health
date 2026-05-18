import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthExerciseData', () {
    test('fromJson parses a session with metrics', () {
      final data = GoogleHealthExerciseData.fromJson(<String, dynamic>{
        'name': 'users/me/dataTypes/exercise/dataPoints/abc',
        'exercise': {
          'exerciseType': 'RUNNING',
          'displayName': 'Morning run',
          'interval': {
            'startTime': '2026-01-15T07:00:00Z',
            'endTime': '2026-01-15T07:45:00Z',
          },
          'metricsSummary': {
            'energyKilocalories': 380.5,
            'distanceMeters': 6500.0,
            'steps': '8200',
          },
        },
      });
      expect(data.exerciseType, 'RUNNING');
      expect(data.displayName, 'Morning run');
      expect(
        data.startTime,
        DateTime.parse('2026-01-15T07:00:00Z').toLocal(),
      );
      expect(data.duration, const Duration(minutes: 45));
      expect(data.calories, 380.5);
      expect(data.distanceMeters, 6500.0);
      expect(data.steps, 8200);
    });

    test('fromJson handles missing fields gracefully', () {
      final data = GoogleHealthExerciseData.fromJson(<String, dynamic>{});
      expect(data.exerciseType, isNull);
      expect(data.duration, isNull);
    });
  });
}
