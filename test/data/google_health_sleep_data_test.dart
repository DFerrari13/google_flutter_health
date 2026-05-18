import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthSleepData', () {
    test('listFromJson flattens stages into segments', () {
      final segments = GoogleHealthSleepData.listFromJson(<String, dynamic>{
        'name': 'users/me/dataTypes/sleep/dataPoints/session1',
        'sleep': {
          'interval': {
            'startTime': '2026-01-15T22:00:00Z',
            'endTime': '2026-01-16T06:00:00Z',
          },
          'type': 'STAGES',
          'stages': [
            {
              'type': 'LIGHT',
              'interval': {
                'startTime': '2026-01-15T22:00:00Z',
                'endTime': '2026-01-16T01:00:00Z',
              },
            },
            {
              'type': 'DEEP',
              'interval': {
                'startTime': '2026-01-16T01:00:00Z',
                'endTime': '2026-01-16T03:00:00Z',
              },
            },
          ],
        },
      });

      expect(segments, hasLength(2));
      expect(segments.first.stage, 'LIGHT');
      expect(segments.first.duration, const Duration(hours: 3));
      expect(segments[1].stage, 'DEEP');
      expect(segments[1].duration, const Duration(hours: 2));
      expect(segments.first.sessionType, 'STAGES');
    });

    test('listFromJson returns whole session when stages are absent', () {
      final segments = GoogleHealthSleepData.listFromJson(<String, dynamic>{
        'name': 'users/me/dataTypes/sleep/dataPoints/session2',
        'sleep': {
          'interval': {
            'startTime': '2026-01-15T22:00:00Z',
            'endTime': '2026-01-16T06:00:00Z',
          },
          'type': 'CLASSIC',
        },
      });
      expect(segments, hasLength(1));
      expect(segments.first.sessionType, 'CLASSIC');
      expect(segments.first.stage, isNull);
      expect(segments.first.duration, const Duration(hours: 8));
    });

    test('duration returns null when either bound is missing', () {
      final data = GoogleHealthSleepData(
        startTime: DateTime.utc(2026, 1, 15, 22),
      );
      expect(data.duration, isNull);
    });
  });
}
