import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthActiveZoneMinutesData', () {
    final fullJson = <String, dynamic>{
      'userId': 'user_123',
      'startTime': '2026-01-15T10:00:00Z',
      'value': {
        'fatBurnMinutes': 30.0,
        'cardioMinutes': 15.0,
        'peakMinutes': 5.0,
        'totalMinutes': 50.0,
      },
    };

    test('fromJson parses nested value object', () {
      final data = GoogleHealthActiveZoneMinutesData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(
        data.dateTime,
        DateTime.parse('2026-01-15T10:00:00Z').toLocal(),
      );
      expect(data.fatBurnMinutes, 30.0);
      expect(data.cardioMinutes, 15.0);
      expect(data.peakMinutes, 5.0);
      expect(data.totalMinutes, 50.0);
    });

    test('fromJson accepts top-level keys as a fallback', () {
      final data = GoogleHealthActiveZoneMinutesData.fromJson({
        'userId': 'user_123',
        'startTime': '2026-01-15T10:00:00Z',
        'fatBurnMinutes': 12,
        'cardioMinutes': 8,
        'peakMinutes': 2,
        'totalMinutes': 22,
      });
      expect(data.fatBurnMinutes, 12.0);
      expect(data.cardioMinutes, 8.0);
      expect(data.peakMinutes, 2.0);
      expect(data.totalMinutes, 22.0);
    });

    test('toJson serializes with nested value object', () {
      final data = GoogleHealthActiveZoneMinutesData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['startTime'], '2026-01-15T10:00:00.000Z');
      final value = json['value'] as Map<String, dynamic>;
      expect(value['fatBurnMinutes'], 30.0);
      expect(value['cardioMinutes'], 15.0);
      expect(value['peakMinutes'], 5.0);
      expect(value['totalMinutes'], 50.0);
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthActiveZoneMinutesData.fromJson(fullJson);
      final roundtripped =
          GoogleHealthActiveZoneMinutesData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.dateTime, original.dateTime);
      expect(roundtripped.fatBurnMinutes, original.fatBurnMinutes);
      expect(roundtripped.cardioMinutes, original.cardioMinutes);
      expect(roundtripped.peakMinutes, original.peakMinutes);
      expect(roundtripped.totalMinutes, original.totalMinutes);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthActiveZoneMinutesData.fromJson({});
      expect(data.userId, isNull);
      expect(data.dateTime, isNull);
      expect(data.fatBurnMinutes, isNull);
      expect(data.cardioMinutes, isNull);
      expect(data.peakMinutes, isNull);
      expect(data.totalMinutes, isNull);
    });
  });
}
