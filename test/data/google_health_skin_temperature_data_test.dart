import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthSkinTemperatureData.fromJson', () {
    test('parses real API response fields', () {
      final json = {
        'name':
            'users/me/dataTypes/daily-sleep-temperature-derivations/dataPoints/abc',
        'dailySleepTemperatureDerivations': {
          'date': {'year': 2025, 'month': 6, 'day': 12},
          'nightlyTemperatureCelsius': 36.4,
          'baselineTemperatureCelsius': 36.1,
          'relativeNightlyStddev30dCelsius': 0.3,
        },
      };
      final d = GoogleHealthSkinTemperatureData.fromJson(json);
      expect(d.startTime, DateTime(2025, 6, 12));
      expect(d.nightlyCelsius, closeTo(36.4, 0.001));
      expect(d.baselineCelsius, closeTo(36.1, 0.001));
      expect(d.relativeStddev30dCelsius, closeTo(0.3, 0.001));
      expect(d.name, contains('daily-sleep-temperature-derivations'));
    });

    test('handles missing nested fields gracefully', () {
      final d = GoogleHealthSkinTemperatureData.fromJson({
        'dailySleepTemperatureDerivations': <String, dynamic>{},
      });
      expect(d.startTime, isNull);
      expect(d.nightlyCelsius, isNull);
      expect(d.baselineCelsius, isNull);
      expect(d.relativeStddev30dCelsius, isNull);
    });

    test('handles missing top-level key gracefully', () {
      final d = GoogleHealthSkinTemperatureData.fromJson(<String, dynamic>{});
      expect(d.startTime, isNull);
      expect(d.nightlyCelsius, isNull);
    });

    test('toJson round-trips correctly', () {
      final original = GoogleHealthSkinTemperatureData(
        name: 'test',
        startTime: DateTime(2025, 6, 12),
        nightlyCelsius: 36.4,
        baselineCelsius: 36.1,
        relativeStddev30dCelsius: 0.3,
      );
      final json = original.toJson();
      expect(json['nightlyCelsius'], 36.4);
      expect(json['baselineCelsius'], 36.1);
      expect(json['relativeStddev30dCelsius'], 0.3);
    });
  });
}
