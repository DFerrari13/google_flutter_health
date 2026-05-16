import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthHrvData', () {
    final fullJson = <String, dynamic>{
      'userId': 'user_123',
      'startTime': '2026-01-15T00:00:00Z',
      'value': {
        'rmssd': 45.2,
        'coverage': 0.85,
        'hfPower': 320.5,
        'lfPower': 410.0,
      },
    };

    test('fromJson parses nested value object', () {
      final data = GoogleHealthHrvData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(
        data.dateTime,
        DateTime.parse('2026-01-15T00:00:00Z').toLocal(),
      );
      expect(data.rmssd, 45.2);
      expect(data.coverage, 0.85);
      expect(data.hfPower, 320.5);
      expect(data.lfPower, 410.0);
    });

    test('fromJson accepts top-level keys as a fallback', () {
      final data = GoogleHealthHrvData.fromJson({
        'userId': 'user_123',
        'startTime': '2026-01-15T00:00:00Z',
        'rmssd': 40,
        'coverage': 1,
        'hfPower': 300,
        'lfPower': 400,
      });
      expect(data.rmssd, 40.0);
      expect(data.coverage, 1.0);
      expect(data.hfPower, 300.0);
      expect(data.lfPower, 400.0);
    });

    test('toJson serializes with nested value object', () {
      final data = GoogleHealthHrvData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['startTime'], '2026-01-15T00:00:00.000Z');
      final value = json['value'] as Map<String, dynamic>;
      expect(value['rmssd'], 45.2);
      expect(value['coverage'], 0.85);
      expect(value['hfPower'], 320.5);
      expect(value['lfPower'], 410.0);
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthHrvData.fromJson(fullJson);
      final roundtripped = GoogleHealthHrvData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.dateTime, original.dateTime);
      expect(roundtripped.rmssd, original.rmssd);
      expect(roundtripped.coverage, original.coverage);
      expect(roundtripped.hfPower, original.hfPower);
      expect(roundtripped.lfPower, original.lfPower);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthHrvData.fromJson({});
      expect(data.userId, isNull);
      expect(data.dateTime, isNull);
      expect(data.rmssd, isNull);
      expect(data.coverage, isNull);
      expect(data.hfPower, isNull);
      expect(data.lfPower, isNull);
    });
  });
}
