import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthSleepData', () {
    final fullJson = <String, dynamic>{
      'userId': 'user_123',
      'startTime': '2026-01-15T22:00:00Z',
      'endTime': '2026-01-16T06:00:00Z',
      'sleepStage': 'DEEP',
    };

    test('fromJson parses all fields correctly', () {
      final data = GoogleHealthSleepData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(
        data.startTime,
        DateTime.parse('2026-01-15T22:00:00Z').toLocal(),
      );
      expect(
        data.endTime,
        DateTime.parse('2026-01-16T06:00:00Z').toLocal(),
      );
      expect(data.sleepStage, 'DEEP');
    });

    test('duration returns endTime - startTime when both set', () {
      final data = GoogleHealthSleepData.fromJson(fullJson);
      expect(data.duration, const Duration(hours: 8));
    });

    test('duration returns null when either bound is missing', () {
      final data = GoogleHealthSleepData.fromJson({
        'startTime': '2026-01-15T22:00:00Z',
      });
      expect(data.duration, isNull);
    });

    test('toJson serializes correctly', () {
      final data = GoogleHealthSleepData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['startTime'], '2026-01-15T22:00:00.000Z');
      expect(json['endTime'], '2026-01-16T06:00:00.000Z');
      expect(json['sleepStage'], 'DEEP');
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthSleepData.fromJson(fullJson);
      final roundtripped = GoogleHealthSleepData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.startTime, original.startTime);
      expect(roundtripped.endTime, original.endTime);
      expect(roundtripped.sleepStage, original.sleepStage);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthSleepData.fromJson({});
      expect(data.userId, isNull);
      expect(data.startTime, isNull);
      expect(data.endTime, isNull);
      expect(data.sleepStage, isNull);
      expect(data.duration, isNull);
    });
  });
}
