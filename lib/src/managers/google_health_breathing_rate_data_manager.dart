import '../data/google_health_breathing_rate_data.dart';
import 'google_health_data_manager.dart';

/// Fetches daily breathing rate (respiratory rate) data from the Google
/// Health API.
///
/// Requires the
/// `googlehealth.health_metrics_and_measurements.readonly` scope.
class GoogleHealthBreathingRateDataManager
    extends GoogleHealthDataManager<GoogleHealthBreathingRateData> {
  GoogleHealthBreathingRateDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthBreathingRateData> parseDataPoints(
    Map<String, dynamic> json,
  ) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthBreathingRateData.fromJson)
        .toList(growable: false);
  }
}
