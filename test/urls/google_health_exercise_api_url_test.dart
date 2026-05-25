import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthExerciseAPIURL', () {
    test('dateRange() builds GET list URL with filter', () {
      final url = GoogleHealthExerciseAPIURL.dateRange(
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 1, 31),
      );
      expect(url.method, GoogleHealthRequestMethod.get);
      expect(
        url.uri.path,
        '/v4/users/me/dataTypes/exercise/dataPoints',
      );
      expect(
        url.uri.queryParameters['filter'],
        contains('exercise.interval.civil_start_time'),
      );
    });
  });
}
