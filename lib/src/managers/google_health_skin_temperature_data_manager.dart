import '../data/google_health_skin_temperature_data.dart';
import 'google_health_data_manager.dart';

/// Fetches nightly skin temperature variation from the Google Health API.
///
/// Requires the
/// `googlehealth.health_metrics_and_measurements.readonly` scope.
class GoogleHealthSkinTemperatureDataManager
    extends GoogleHealthDataManager<GoogleHealthSkinTemperatureData> {
  GoogleHealthSkinTemperatureDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthSkinTemperatureData> parseDataPoints(
    Map<String, dynamic> json,
  ) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthSkinTemperatureData.fromJson)
        .toList(growable: false);
  }
}
