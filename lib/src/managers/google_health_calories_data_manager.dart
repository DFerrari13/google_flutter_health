import '../data/google_health_calories_data.dart';
import 'google_health_data_manager.dart';

/// Fetches total-calories data from the Google Health API.
///
/// Requires the `googlehealth.activity_and_fitness.readonly` scope.
class GoogleHealthCaloriesDataManager
    extends GoogleHealthDataManager<GoogleHealthCaloriesData> {
  GoogleHealthCaloriesDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthCaloriesData> parseDataPoints(Map<String, dynamic> json) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthCaloriesData.fromJson)
        .toList(growable: false);
  }
}
