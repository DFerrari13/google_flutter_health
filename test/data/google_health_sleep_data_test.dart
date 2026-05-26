import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

Map<String, dynamic> _fullSession({String type = 'MAIN_SLEEP'}) => {
      'name': 'users/me/dataTypes/sleep/dataPoints/s1',
      'sleep': {
        'interval': {
          'startTime': '2026-05-25T22:00:00Z',
          'endTime': '2026-05-26T06:00:00Z',
        },
        'type': type,
        'summary': {
          'minutesAsleep': '440',
          'minutesAwake': '40',
          'minutesInSleepPeriod': '480',
          'stagesSummary': [
            {'type': 'AWAKE', 'minutes': '40', 'count': '8'},
            {'type': 'LIGHT', 'minutes': '200', 'count': '12'},
            {'type': 'DEEP', 'minutes': '120', 'count': '4'},
            {'type': 'REM', 'minutes': '120', 'count': '5'},
          ],
        },
      },
    };

void main() {
  group('GoogleHealthSleepData', () {
    test('fromJson parses interval, type, summary totals, and stage minutes',
        () {
      final d = GoogleHealthSleepData.fromJson(_fullSession());
      expect(d.startTime, DateTime.parse('2026-05-25T22:00:00Z').toLocal());
      expect(d.endTime, DateTime.parse('2026-05-26T06:00:00Z').toLocal());
      expect(d.sleepType, 'MAIN_SLEEP');
      expect(d.minutesAsleep, 440);
      expect(d.minutesAwake, 40);
      expect(d.minutesInSleepPeriod, 480);
      expect(d.awakeMinutes, 40);
      expect(d.lightMinutes, 200);
      expect(d.deepMinutes, 120);
      expect(d.remMinutes, 120);
      expect(d.awakeCount, 8);
      expect(d.lightCount, 12);
      expect(d.deepCount, 4);
      expect(d.remCount, 5);
    });

    test('duration getter returns endTime − startTime', () {
      final d = GoogleHealthSleepData.fromJson(_fullSession());
      expect(d.duration, const Duration(hours: 8));
    });

    test('fromJson handles missing summary gracefully', () {
      final d = GoogleHealthSleepData.fromJson({
        'sleep': {
          'interval': {
            'startTime': '2026-05-25T22:00:00Z',
            'endTime': '2026-05-26T06:00:00Z',
          },
          'type': 'MAIN_SLEEP',
        },
      });
      expect(d.minutesAsleep, isNull);
      expect(d.deepMinutes, isNull);
    });

    test('fromJson handles missing fields gracefully', () {
      final d = GoogleHealthSleepData.fromJson(<String, dynamic>{});
      expect(d.startTime, isNull);
      expect(d.sleepType, isNull);
      expect(d.duration, isNull);
    });

    test('toJson round-trips stage minutes', () {
      final d = GoogleHealthSleepData.fromJson(_fullSession());
      final json = d.toJson();
      expect(json['deepMinutes'], 120);
      expect(json['remMinutes'], 120);
      expect(json['sleepType'], 'MAIN_SLEEP');
    });
  });
}
