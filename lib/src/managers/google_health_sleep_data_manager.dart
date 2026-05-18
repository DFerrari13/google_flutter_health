import '../data/google_health_sleep_data.dart';
import 'google_health_data_manager.dart';

/// Fetches sleep sessions from the Google Health API.
///
/// Requires the `googlehealth.sleep.readonly` scope. Sessions are flattened
/// into one [GoogleHealthSleepData] per stage segment; sessions without a
/// stage breakdown yield a single segment covering the whole session.
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
        .expand(GoogleHealthSleepData.listFromJson)
        .toList(growable: false);
  }
}
