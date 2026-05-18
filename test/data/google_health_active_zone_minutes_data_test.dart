import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthActiveZoneMinutesData', () {
    test('fromJson parses dailyRollUp aggregate', () {
      final data =
          GoogleHealthActiveZoneMinutesData.fromJson(<String, dynamic>{
        'civilStartTime': {
          'date': {'year': 2026, 'month': 1, 'day': 15},
        },
        'civilEndTime': {
          'date': {'year': 2026, 'month': 1, 'day': 16},
        },
        'activeZoneMinutes': {
          'fatBurnMinutesSum': 25.0,
          'cardioMinutesSum': 15.0,
          'peakMinutesSum': 5.0,
          'totalMinutesSum': 45.0,
        },
      });
      expect(data.fatBurnMinutes, 25.0);
      expect(data.cardioMinutes, 15.0);
      expect(data.peakMinutes, 5.0);
      expect(data.totalMinutes, 45.0);
    });

    test('fromJson handles missing fields gracefully', () {
      final data =
          GoogleHealthActiveZoneMinutesData.fromJson(<String, dynamic>{});
      expect(data.totalMinutes, isNull);
    });
  });
}
