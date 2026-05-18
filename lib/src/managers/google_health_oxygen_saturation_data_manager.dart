import '../data/google_health_oxygen_saturation_data.dart';
import 'google_health_data_manager.dart';

/// Fetches daily oxygen saturation (SpO2) data from the Google Health API.
///
/// Requires the
/// `googlehealth.health_metrics_and_measurements.readonly` scope.
class GoogleHealthOxygenSaturationDataManager
    extends GoogleHealthDataManager<GoogleHealthOxygenSaturationData> {
  GoogleHealthOxygenSaturationDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthOxygenSaturationData> parseDataPoints(
    Map<String, dynamic> json,
  ) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthOxygenSaturationData.fromJson)
        .toList(growable: false);
  }
}
