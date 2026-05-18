import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthDistanceData', () {
    test('fromJson parses dailyRollUp aggregate', () {
      final data = GoogleHealthDistanceData.fromJson(<String, dynamic>{
        'civilStartTime': {
          'date': {'year': 2026, 'month': 1, 'day': 15},
        },
        'civilEndTime': {
          'date': {'year': 2026, 'month': 1, 'day': 16},
        },
        'distance': {'distanceMetersSum': 8543.5},
      });
      expect(data.startTime, DateTime(2026, 1, 15));
      expect(data.distanceMeters, 8543.5);
    });

    test('fromJson parses a raw list interval', () {
      final data = GoogleHealthDistanceData.fromJson(<String, dynamic>{
        'distance': {
          'distanceMeters': 200.0,
          'interval': {
            'startTime': '2026-01-15T10:00:00Z',
            'endTime': '2026-01-15T10:05:00Z',
          },
        },
      });
      expect(data.distanceMeters, 200.0);
      expect(
        data.startTime,
        DateTime.parse('2026-01-15T10:00:00Z').toLocal(),
      );
    });

    test('fromJson handles missing fields gracefully', () {
      final data = GoogleHealthDistanceData.fromJson(<String, dynamic>{});
      expect(data.distanceMeters, isNull);
      expect(data.startTime, isNull);
    });
  });
}
