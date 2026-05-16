import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthDistanceData', () {
    final fullJson = <String, dynamic>{
      'userId': 'user_123',
      'startTime': '2026-01-15T10:00:00Z',
      'value': 1234.5,
    };

    test('fromJson parses all fields correctly', () {
      final data = GoogleHealthDistanceData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(
        data.dateTime,
        DateTime.parse('2026-01-15T10:00:00Z').toLocal(),
      );
      expect(data.distanceMeters, 1234.5);
    });

    test('fromJson coerces integer value to double', () {
      final data = GoogleHealthDistanceData.fromJson({
        ...fullJson,
        'value': 1234,
      });
      expect(data.distanceMeters, 1234.0);
    });

    test('toJson serializes correctly', () {
      final data = GoogleHealthDistanceData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['startTime'], '2026-01-15T10:00:00.000Z');
      expect(json['value'], 1234.5);
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthDistanceData.fromJson(fullJson);
      final roundtripped = GoogleHealthDistanceData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.dateTime, original.dateTime);
      expect(roundtripped.distanceMeters, original.distanceMeters);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthDistanceData.fromJson({});
      expect(data.userId, isNull);
      expect(data.dateTime, isNull);
      expect(data.distanceMeters, isNull);
    });
  });
}
