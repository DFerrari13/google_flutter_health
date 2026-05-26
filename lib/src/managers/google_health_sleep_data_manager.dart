import '../data/google_health_sleep_data.dart';
import 'google_health_data_manager.dart';

/// Fetches sleep sessions from the Google Health API.
///
/// Requires the `googlehealth.sleep.readonly` scope.
/// Returns one [GoogleHealthSleepData] per session. NAP sessions are filtered
/// out — only `MAIN_SLEEP` and `SLEEP_TYPE_UNSPECIFIED` sessions are returned.
class GoogleHealthSleepDataManager
    extends GoogleHealthDataManager<GoogleHealthSleepData> {
  GoogleHealthSleepDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthSleepData> parseDataPoints(Map<String, dynamic> json) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthSleepData.fromJson)
        .where((s) => s.sleepType != 'NAP')
        .toList(growable: false);
  }
}
