import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthOxygenSaturationData', () {
    final fullJson = <String, dynamic>{
      'userId': 'user_123',
      'startTime': '2026-01-15T00:00:00Z',
      'value': {
        'spo2Percentage': 97.5,
        'spo2Low': 94.0,
        'spo2High': 99.0,
      },
    };

    test('fromJson parses nested value object', () {
      final data = GoogleHealthOxygenSaturationData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(
        data.dateTime,
        DateTime.parse('2026-01-15T00:00:00Z').toLocal(),
      );
      expect(data.spo2Percentage, 97.5);
      expect(data.spo2Low, 94.0);
      expect(data.spo2High, 99.0);
    });

    test('fromJson accepts top-level keys as a fallback', () {
      final data = GoogleHealthOxygenSaturationData.fromJson({
        'userId': 'user_123',
        'startTime': '2026-01-15T00:00:00Z',
        'spo2Percentage': 96,
        'spo2Low': 92,
        'spo2High': 98,
      });
      expect(data.spo2Percentage, 96.0);
      expect(data.spo2Low, 92.0);
      expect(data.spo2High, 98.0);
    });

    test('toJson serializes with nested value object', () {
      final data = GoogleHealthOxygenSaturationData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['startTime'], '2026-01-15T00:00:00.000Z');
      final value = json['value'] as Map<String, dynamic>;
      expect(value['spo2Percentage'], 97.5);
      expect(value['spo2Low'], 94.0);
      expect(value['spo2High'], 99.0);
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthOxygenSaturationData.fromJson(fullJson);
      final roundtripped =
          GoogleHealthOxygenSaturationData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.dateTime, original.dateTime);
      expect(roundtripped.spo2Percentage, original.spo2Percentage);
      expect(roundtripped.spo2Low, original.spo2Low);
      expect(roundtripped.spo2High, original.spo2High);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthOxygenSaturationData.fromJson({});
      expect(data.userId, isNull);
      expect(data.dateTime, isNull);
      expect(data.spo2Percentage, isNull);
      expect(data.spo2Low, isNull);
      expect(data.spo2High, isNull);
    });
  });
}
