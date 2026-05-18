import '../data/google_health_hrv_data.dart';
import 'google_health_data_manager.dart';

/// Fetches daily heart rate variability (HRV) data from the Google Health API.
///
/// Requires the
/// `googlehealth.health_metrics_and_measurements.readonly` scope.
class GoogleHealthHrvDataManager
    extends GoogleHealthDataManager<GoogleHealthHrvData> {
  GoogleHealthHrvDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthHrvData> parseDataPoints(Map<String, dynamic> json) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthHrvData.fromJson)
        .toList(growable: false);
  }
}
