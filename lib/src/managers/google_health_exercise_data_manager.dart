import '../data/google_health_exercise_data.dart';
import 'google_health_data_manager.dart';

/// Fetches exercise sessions from the Google Health API.
///
/// Requires the `googlehealth.activity_and_fitness.readonly` scope.
class GoogleHealthExerciseDataManager
    extends GoogleHealthDataManager<GoogleHealthExerciseData> {
  GoogleHealthExerciseDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthExerciseData> parseDataPoints(Map<String, dynamic> json) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthExerciseData.fromJson)
        .toList(growable: false);
  }
}
