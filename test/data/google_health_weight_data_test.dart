import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthWeightData', () {
    final fullJson = <String, dynamic>{
      'userId': 'user_123',
      'startTime': '2026-01-15T08:30:00Z',
      'value': {
        'weightKg': 72.5,
        'bmi': 22.1,
        'bodyFatPercentage': 18.4,
      },
    };

    test('fromJson parses nested value object', () {
      final data = GoogleHealthWeightData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(
        data.dateTime,
        DateTime.parse('2026-01-15T08:30:00Z').toLocal(),
      );
      expect(data.weightKg, 72.5);
      expect(data.bmi, 22.1);
      expect(data.bodyFatPercentage, 18.4);
    });

    test('fromJson accepts top-level keys as a fallback', () {
      final data = GoogleHealthWeightData.fromJson({
        'userId': 'user_123',
        'startTime': '2026-01-15T08:30:00Z',
        'weightKg': 70,
        'bmi': 21,
        'bodyFatPercentage': 17,
      });
      expect(data.weightKg, 70.0);
      expect(data.bmi, 21.0);
      expect(data.bodyFatPercentage, 17.0);
    });

    test('toJson serializes with nested value object', () {
      final data = GoogleHealthWeightData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['startTime'], '2026-01-15T08:30:00.000Z');
      final value = json['value'] as Map<String, dynamic>;
      expect(value['weightKg'], 72.5);
      expect(value['bmi'], 22.1);
      expect(value['bodyFatPercentage'], 18.4);
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthWeightData.fromJson(fullJson);
      final roundtripped = GoogleHealthWeightData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.dateTime, original.dateTime);
      expect(roundtripped.weightKg, original.weightKg);
      expect(roundtripped.bmi, original.bmi);
      expect(roundtripped.bodyFatPercentage, original.bodyFatPercentage);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthWeightData.fromJson({});
      expect(data.userId, isNull);
      expect(data.dateTime, isNull);
      expect(data.weightKg, isNull);
      expect(data.bmi, isNull);
      expect(data.bodyFatPercentage, isNull);
    });
  });
}
