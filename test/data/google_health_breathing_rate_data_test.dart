import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthBreathingRateData.fromJson', () {
    test('parses real API response fields', () {
      final json = {
        'name': 'users/me/dataTypes/daily-respiratory-rate/dataPoints/abc',
        'dailyRespiratoryRate': {
          'date': {'year': 2025, 'month': 6, 'day': 12},
          'breathsPerMinute': 14.5,
        },
      };
      final d = GoogleHealthBreathingRateData.fromJson(json);
      expect(d.startTime, DateTime(2025, 6, 12));
      expect(d.breathsPerMinute, closeTo(14.5, 0.001));
      expect(d.name, contains('daily-respiratory-rate'));
    });

    test('handles missing nested fields gracefully', () {
      final d = GoogleHealthBreathingRateData.fromJson(
        {'dailyRespiratoryRate': <String, dynamic>{}},
      );
      expect(d.startTime, isNull);
      expect(d.breathsPerMinute, isNull);
    });

    test('handles missing top-level key gracefully', () {
      final d = GoogleHealthBreathingRateData.fromJson(<String, dynamic>{});
      expect(d.startTime, isNull);
      expect(d.breathsPerMinute, isNull);
    });

    test('toJson round-trips correctly', () {
      final original = GoogleHealthBreathingRateData(
        name: 'test',
        startTime: DateTime(2025, 6, 12),
        breathsPerMinute: 14.5,
      );
      final json = original.toJson();
      expect(json['breathsPerMinute'], 14.5);
    });
  });
}
