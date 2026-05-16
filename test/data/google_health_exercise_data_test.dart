import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthExerciseData', () {
    final fullJson = <String, dynamic>{
      'userId': 'user_123',
      'startTime': '2026-01-15T07:00:00Z',
      'endTime': '2026-01-15T07:45:00Z',
      'value': {
        'activityType': 'running',
        'durationMillis': 2700000.0,
        'calories': 350.0,
        'distanceMeters': 6200.0,
        'steps': 7800.0,
      },
    };

    test('fromJson parses nested value object and both timestamps', () {
      final data = GoogleHealthExerciseData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(
        data.startTime,
        DateTime.parse('2026-01-15T07:00:00Z').toLocal(),
      );
      expect(
        data.endTime,
        DateTime.parse('2026-01-15T07:45:00Z').toLocal(),
      );
      expect(data.activityType, 'running');
      expect(data.durationMillis, 2700000.0);
      expect(data.calories, 350.0);
      expect(data.distanceMeters, 6200.0);
      expect(data.steps, 7800.0);
    });

    test('fromJson accepts top-level keys as a fallback', () {
      final data = GoogleHealthExerciseData.fromJson({
        'userId': 'user_123',
        'startTime': '2026-01-15T07:00:00Z',
        'endTime': '2026-01-15T07:30:00Z',
        'activityType': 'cycling',
        'durationMillis': 1800000,
        'calories': 250,
        'distanceMeters': 12000,
        'steps': 0,
      });
      expect(data.activityType, 'cycling');
      expect(data.durationMillis, 1800000.0);
      expect(data.calories, 250.0);
      expect(data.distanceMeters, 12000.0);
      expect(data.steps, 0.0);
    });

    test('toJson serializes with nested value object', () {
      final data = GoogleHealthExerciseData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['startTime'], '2026-01-15T07:00:00.000Z');
      expect(json['endTime'], '2026-01-15T07:45:00.000Z');
      final value = json['value'] as Map<String, dynamic>;
      expect(value['activityType'], 'running');
      expect(value['durationMillis'], 2700000.0);
      expect(value['calories'], 350.0);
      expect(value['distanceMeters'], 6200.0);
      expect(value['steps'], 7800.0);
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthExerciseData.fromJson(fullJson);
      final roundtripped = GoogleHealthExerciseData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.startTime, original.startTime);
      expect(roundtripped.endTime, original.endTime);
      expect(roundtripped.activityType, original.activityType);
      expect(roundtripped.durationMillis, original.durationMillis);
      expect(roundtripped.calories, original.calories);
      expect(roundtripped.distanceMeters, original.distanceMeters);
      expect(roundtripped.steps, original.steps);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthExerciseData.fromJson({});
      expect(data.userId, isNull);
      expect(data.startTime, isNull);
      expect(data.endTime, isNull);
      expect(data.activityType, isNull);
      expect(data.durationMillis, isNull);
      expect(data.calories, isNull);
      expect(data.distanceMeters, isNull);
      expect(data.steps, isNull);
    });
  });
}
