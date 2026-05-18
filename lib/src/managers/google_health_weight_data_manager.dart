import '../data/google_health_weight_data.dart';
import 'google_health_data_manager.dart';

/// Fetches weight data from the Google Health API.
///
/// Requires the
/// `googlehealth.health_metrics_and_measurements.readonly` scope.
class GoogleHealthWeightDataManager
    extends GoogleHealthDataManager<GoogleHealthWeightData> {
  GoogleHealthWeightDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthWeightData> parseDataPoints(Map<String, dynamic> json) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthWeightData.fromJson)
        .toList(growable: false);
  }
}
