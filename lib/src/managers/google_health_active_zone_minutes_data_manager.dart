import '../data/google_health_active_zone_minutes_data.dart';
import 'google_health_data_manager.dart';

/// Fetches active-zone-minutes data from the Google Health API.
///
/// Requires the `googlehealth.activity_and_fitness.readonly` scope.
class GoogleHealthActiveZoneMinutesDataManager
    extends GoogleHealthDataManager<GoogleHealthActiveZoneMinutesData> {
  GoogleHealthActiveZoneMinutesDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthActiveZoneMinutesData> parseDataPoints(
    Map<String, dynamic> json,
  ) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthActiveZoneMinutesData.fromJson)
        .toList(growable: false);
  }
}
