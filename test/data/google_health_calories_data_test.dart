import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthCaloriesData', () {
    final fullJson = <String, dynamic>{
      'userId': 'user_123',
      'startTime': '2026-01-15T10:00:00Z',
      'value': 2150.75,
    };

    test('fromJson parses all fields correctly', () {
      final data = GoogleHealthCaloriesData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(
        data.dateTime,
        DateTime.parse('2026-01-15T10:00:00Z').toLocal(),
      );
      expect(data.calories, 2150.75);
    });

    test('fromJson coerces integer value to double', () {
      final data = GoogleHealthCaloriesData.fromJson({
        ...fullJson,
        'value': 2000,
      });
      expect(data.calories, 2000.0);
    });

    test('toJson serializes correctly', () {
      final data = GoogleHealthCaloriesData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['startTime'], '2026-01-15T10:00:00.000Z');
      expect(json['value'], 2150.75);
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthCaloriesData.fromJson(fullJson);
      final roundtripped = GoogleHealthCaloriesData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.dateTime, original.dateTime);
      expect(roundtripped.calories, original.calories);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthCaloriesData.fromJson({});
      expect(data.userId, isNull);
      expect(data.dateTime, isNull);
      expect(data.calories, isNull);
    });
  });
}
