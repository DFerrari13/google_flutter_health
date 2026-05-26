import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

Map<String, dynamic> _rollupPoint({String countSum = '8500'}) => {
      'startTime': '2025-06-12T00:00:00Z',
      'endTime': '2025-06-13T00:00:00Z',
      'steps': {'countSum': countSum},
    };

void main() {
  group('GoogleHealthStepsData', () {
    test('fromJson parses rollup point with string countSum', () {
      final data = GoogleHealthStepsData.fromJson(_rollupPoint());
      expect(data.startTime, DateTime.parse('2025-06-12T00:00:00Z').toLocal());
      expect(data.endTime, DateTime.parse('2025-06-13T00:00:00Z').toLocal());
      expect(data.countSum, 8500);
    });

    test('fromJson accepts numeric countSum', () {
      final data = GoogleHealthStepsData.fromJson({
        'steps': {'countSum': 75},
      });
      expect(data.countSum, 75);
    });

    test('fromJson handles missing fields gracefully', () {
      final data = GoogleHealthStepsData.fromJson(<String, dynamic>{});
      expect(data.startTime, isNull);
      expect(data.endTime, isNull);
      expect(data.countSum, isNull);
    });

    test('fromJson handles missing steps wrapper gracefully', () {
      final data = GoogleHealthStepsData.fromJson({
        'startTime': '2025-06-12T00:00:00Z',
        'endTime': '2025-06-13T00:00:00Z',
      });
      expect(data.countSum, isNull);
    });

    test('toJson round-trips correctly', () {
      final data = GoogleHealthStepsData(
        startTime: DateTime.utc(2025, 6, 12),
        endTime: DateTime.utc(2025, 6, 13),
        countSum: 8500,
      );
      final json = data.toJson();
      expect(json['countSum'], 8500);
      expect(json['startTime'], '2025-06-12T00:00:00.000Z');
      expect(json['endTime'], '2025-06-13T00:00:00.000Z');
    });
  });
}
