import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthRestingHeartRateData', () {
    final fullJson = <String, dynamic>{
      'userId': 'user_123',
      'startTime': '2026-01-15T00:00:00Z',
      'value': 58.5,
    };

    test('fromJson parses all fields correctly', () {
      final data = GoogleHealthRestingHeartRateData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(
        data.dateTime,
        DateTime.parse('2026-01-15T00:00:00Z').toLocal(),
      );
      expect(data.beatsPerMinute, 58.5);
    });

    test('fromJson coerces integer value to double', () {
      final data = GoogleHealthRestingHeartRateData.fromJson({
        ...fullJson,
        'value': 60,
      });
      expect(data.beatsPerMinute, 60.0);
    });

    test('toJson serializes correctly', () {
      final data = GoogleHealthRestingHeartRateData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['startTime'], '2026-01-15T00:00:00.000Z');
      expect(json['value'], 58.5);
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthRestingHeartRateData.fromJson(fullJson);
      final roundtripped =
          GoogleHealthRestingHeartRateData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.dateTime, original.dateTime);
      expect(roundtripped.beatsPerMinute, original.beatsPerMinute);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthRestingHeartRateData.fromJson({});
      expect(data.userId, isNull);
      expect(data.dateTime, isNull);
      expect(data.beatsPerMinute, isNull);
    });
  });
}
