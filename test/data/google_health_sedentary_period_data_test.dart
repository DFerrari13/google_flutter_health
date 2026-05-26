import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

Map<String, dynamic> _rollupPoint({String durationSum = '3600s'}) => {
      'startTime': '2026-05-26T00:00:00Z',
      'endTime': '2026-05-27T00:00:00Z',
      'sedentaryPeriod': {'durationSum': durationSum},
    };

void main() {
  group('GoogleHealthSedentaryPeriodData', () {
    test('fromJson parses durationSum in whole seconds', () {
      final d = GoogleHealthSedentaryPeriodData.fromJson(_rollupPoint());
      expect(d.startTime, DateTime.parse('2026-05-26T00:00:00Z').toLocal());
      expect(d.endTime, DateTime.parse('2026-05-27T00:00:00Z').toLocal());
      expect(d.duration, const Duration(hours: 1));
    });

    test('fromJson parses fractional duration like "3.5s"', () {
      final d = GoogleHealthSedentaryPeriodData.fromJson(
        _rollupPoint(durationSum: '3.5s'),
      );
      expect(d.duration, const Duration(milliseconds: 3500));
    });

    test('fromJson handles missing wrapper gracefully', () {
      final d = GoogleHealthSedentaryPeriodData.fromJson(<String, dynamic>{});
      expect(d.duration, isNull);
      expect(d.startTime, isNull);
    });

    test('fromJson returns null for malformed duration string', () {
      final d = GoogleHealthSedentaryPeriodData.fromJson({
        'sedentaryPeriod': {'durationSum': 'not-a-duration'},
      });
      expect(d.duration, isNull);
    });

    test('toJson exposes durationSeconds for round-trip', () {
      const d = GoogleHealthSedentaryPeriodData(
        duration: Duration(hours: 2),
      );
      expect(d.toJson()['durationSeconds'], 7200);
    });
  });
}
