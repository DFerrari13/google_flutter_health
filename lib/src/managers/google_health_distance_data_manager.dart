import '../data/google_health_distance_data.dart';
import 'google_health_data_manager.dart';

/// Fetches distance data from the Google Health API.
///
/// Requires the `googlehealth.activity_and_fitness.readonly` scope.
class GoogleHealthDistanceDataManager
    extends GoogleHealthDataManager<GoogleHealthDistanceData> {
  GoogleHealthDistanceDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthDistanceData> parseDataPoints(Map<String, dynamic> json) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthDistanceData.fromJson)
        .toList(growable: false);
  }
}
