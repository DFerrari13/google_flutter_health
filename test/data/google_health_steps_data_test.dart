import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthStepsData', () {
    test('fromJson parses a dailyRollUp data point', () {
      final data = GoogleHealthStepsData.fromJson(<String, dynamic>{
        'civilStartTime': {
          'date': {'year': 2026, 'month': 1, 'day': 15},
        },
        'civilEndTime': {
          'date': {'year': 2026, 'month': 1, 'day': 16},
        },
        'steps': {'countSum': '12000'},
      });
      expect(data.startTime, DateTime(2026, 1, 15));
      expect(data.endTime, DateTime(2026, 1, 16));
      expect(data.count, 12000);
    });

    test('fromJson parses a raw list data point', () {
      final data = GoogleHealthStepsData.fromJson(<String, dynamic>{
        'name': 'users/me/dataTypes/steps/dataPoints/abc123',
        'steps': {
          'count': '50',
          'interval': {
            'startTime': '2026-01-15T10:00:00Z',
            'endTime': '2026-01-15T10:15:00Z',
          },
        },
      });
      expect(data.name, 'users/me/dataTypes/steps/dataPoints/abc123');
      expect(
        data.startTime,
        DateTime.parse('2026-01-15T10:00:00Z').toLocal(),
      );
      expect(
        data.endTime,
        DateTime.parse('2026-01-15T10:15:00Z').toLocal(),
      );
      expect(data.count, 50);
    });

    test('fromJson accepts numeric count in addition to string', () {
      final data = GoogleHealthStepsData.fromJson(<String, dynamic>{
        'steps': {'count': 75},
      });
      expect(data.count, 75);
    });

    test('fromJson handles missing fields gracefully', () {
      final data = GoogleHealthStepsData.fromJson(<String, dynamic>{});
      expect(data.name, isNull);
      expect(data.startTime, isNull);
      expect(data.endTime, isNull);
      expect(data.count, isNull);
    });

    test('toJson exposes the canonical Dart-side shape', () {
      final data = GoogleHealthStepsData(
        name: 'users/me/dataTypes/steps/dataPoints/abc123',
        startTime: DateTime.utc(2026, 1, 15, 10),
        endTime: DateTime.utc(2026, 1, 15, 10, 15),
        count: 50,
      );
      final json = data.toJson();
      expect(json['name'], 'users/me/dataTypes/steps/dataPoints/abc123');
      expect(json['startTime'], '2026-01-15T10:00:00.000Z');
      expect(json['endTime'], '2026-01-15T10:15:00.000Z');
      expect(json['count'], 50);
    });
  });
}
