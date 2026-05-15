import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthHeartRateData', () {
    final fullJson = <String, dynamic>{
      'userId': 'user_123',
      'startTime': '2026-01-15T10:00:00Z',
      'value': 72.5,
    };

    test('fromJson parses all fields correctly', () {
      final data = GoogleHealthHeartRateData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(
        data.dateTime,
        DateTime.parse('2026-01-15T10:00:00Z').toLocal(),
      );
      expect(data.bpm, 72.5);
    });

    test('fromJson converts integer value to double', () {
      final data = GoogleHealthHeartRateData.fromJson({
        ...fullJson,
        'value': 72,
      });
      expect(data.bpm, 72.0);
    });

    test('toJson serializes correctly', () {
      final data = GoogleHealthHeartRateData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['startTime'], '2026-01-15T10:00:00.000Z');
      expect(json['value'], 72.5);
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthHeartRateData.fromJson(fullJson);
      final roundtripped =
          GoogleHealthHeartRateData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.dateTime, original.dateTime);
      expect(roundtripped.bpm, original.bpm);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthHeartRateData.fromJson({});
      expect(data.userId, isNull);
      expect(data.dateTime, isNull);
      expect(data.bpm, isNull);
    });
  });
}
