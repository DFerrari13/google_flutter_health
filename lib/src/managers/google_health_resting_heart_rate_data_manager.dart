import '../data/google_health_resting_heart_rate_data.dart';
import 'google_health_data_manager.dart';

/// Fetches daily resting heart rate data from the Google Health API.
///
/// Requires the
/// `googlehealth.health_metrics_and_measurements.readonly` scope.
class GoogleHealthRestingHeartRateDataManager
    extends GoogleHealthDataManager<GoogleHealthRestingHeartRateData> {
  GoogleHealthRestingHeartRateDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthRestingHeartRateData> parseDataPoints(
    Map<String, dynamic> json,
  ) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthRestingHeartRateData.fromJson)
        .toList(growable: false);
  }
}
