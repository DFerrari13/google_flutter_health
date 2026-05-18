import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthHeartRateData', () {
    test('fromJson parses a dailyRollUp data point', () {
      final data = GoogleHealthHeartRateData.fromJson(<String, dynamic>{
        'civilStartTime': {
          'date': {'year': 2026, 'month': 1, 'day': 15},
        },
        'civilEndTime': {
          'date': {'year': 2026, 'month': 1, 'day': 16},
        },
        'heartRate': {
          'beatsPerMinuteAvg': 72.5,
          'beatsPerMinuteMin': 55.0,
          'beatsPerMinuteMax': 145.0,
        },
      });
      expect(data.civilStartTime, DateTime(2026, 1, 15));
      expect(data.civilEndTime, DateTime(2026, 1, 16));
      expect(data.beatsPerMinuteAvg, 72.5);
      expect(data.beatsPerMinuteMin, 55.0);
      expect(data.beatsPerMinuteMax, 145.0);
      expect(data.beatsPerMinute, isNull);
    });

    test('fromJson parses a raw list sample', () {
      final data = GoogleHealthHeartRateData.fromJson(<String, dynamic>{
        'name': 'users/me/dataTypes/heart-rate/dataPoints/abc',
        'heartRate': {
          'beatsPerMinute': '75',
          'sampleTime': {'physicalTime': '2026-01-15T10:00:00Z'},
        },
      });
      expect(data.name, 'users/me/dataTypes/heart-rate/dataPoints/abc');
      expect(
        data.sampleTime,
        DateTime.parse('2026-01-15T10:00:00Z').toLocal(),
      );
      expect(data.beatsPerMinute, 75);
      expect(data.beatsPerMinuteAvg, isNull);
    });

    test('fromJson handles missing fields gracefully', () {
      final data = GoogleHealthHeartRateData.fromJson(<String, dynamic>{});
      expect(data.beatsPerMinute, isNull);
      expect(data.beatsPerMinuteAvg, isNull);
      expect(data.sampleTime, isNull);
      expect(data.civilStartTime, isNull);
    });

    test('toJson exposes all fields', () {
      final data = GoogleHealthHeartRateData(
        name: 'users/me/dataTypes/heart-rate/dataPoints/x',
        sampleTime: DateTime.utc(2026, 1, 15, 10),
        beatsPerMinute: 75,
      );
      final json = data.toJson();
      expect(json['name'], 'users/me/dataTypes/heart-rate/dataPoints/x');
      expect(json['sampleTime'], '2026-01-15T10:00:00.000Z');
      expect(json['beatsPerMinute'], 75);
    });
  });
}
