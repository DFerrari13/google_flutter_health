import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

Map<String, dynamic> _rollupPoint() => {
      'startTime': '2026-05-26T00:00:00Z',
      'endTime': '2026-05-27T00:00:00Z',
      'activeMinutes': {
        'activeMinutesRollupByActivityLevel': [
          {'activityLevel': 'LIGHT', 'activeMinutesSum': '30'},
          {'activityLevel': 'MODERATE', 'activeMinutesSum': '20'},
          {'activityLevel': 'VIGOROUS', 'activeMinutesSum': '10'},
        ],
      },
    };

void main() {
  group('GoogleHealthActiveMinutesData', () {
    test('fromJson parses 3-level breakdown', () {
      final d = GoogleHealthActiveMinutesData.fromJson(_rollupPoint());
      expect(d.startTime, DateTime.parse('2026-05-26T00:00:00Z').toLocal());
      expect(d.endTime, DateTime.parse('2026-05-27T00:00:00Z').toLocal());
      expect(d.lightlyActiveMinutes, 30);
      expect(d.moderatelyActiveMinutes, 20);
      expect(d.veryActiveMinutes, 10);
      expect(d.totalActiveMinutes, 60);
    });

    test('fromJson ignores unknown activity levels', () {
      final d = GoogleHealthActiveMinutesData.fromJson({
        'activeMinutes': {
          'activeMinutesRollupByActivityLevel': [
            {'activityLevel': 'LIGHT', 'activeMinutesSum': '15'},
            {'activityLevel': 'SEDENTARY', 'activeMinutesSum': '300'},
            {'activityLevel': 'UNKNOWN_LEVEL', 'activeMinutesSum': '5'},
          ],
        },
      });
      expect(d.lightlyActiveMinutes, 15);
      expect(d.moderatelyActiveMinutes, isNull);
      expect(d.veryActiveMinutes, isNull);
      expect(d.totalActiveMinutes, 15);
    });

    test('fromJson handles missing rollup gracefully', () {
      final d = GoogleHealthActiveMinutesData.fromJson(<String, dynamic>{});
      expect(d.startTime, isNull);
      expect(d.lightlyActiveMinutes, isNull);
      expect(d.totalActiveMinutes, isNull);
    });

    test('fromJson handles missing activeMinutes wrapper', () {
      final d = GoogleHealthActiveMinutesData.fromJson({
        'startTime': '2026-05-26T00:00:00Z',
        'endTime': '2026-05-27T00:00:00Z',
      });
      expect(d.startTime, isNotNull);
      expect(d.lightlyActiveMinutes, isNull);
      expect(d.totalActiveMinutes, isNull);
    });

    test('toJson round-trips correctly', () {
      const d = GoogleHealthActiveMinutesData(
        lightlyActiveMinutes: 30,
        moderatelyActiveMinutes: 20,
        veryActiveMinutes: 10,
      );
      final json = d.toJson();
      expect(json['lightlyActiveMinutes'], 30);
      expect(json['moderatelyActiveMinutes'], 20);
      expect(json['veryActiveMinutes'], 10);
    });
  });
}
