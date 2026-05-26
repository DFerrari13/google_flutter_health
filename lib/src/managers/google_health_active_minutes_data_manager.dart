import '../data/google_health_active_minutes_data.dart';
import 'google_health_data_manager.dart';

/// Fetches daily active-minutes rollup data from the Google Health API.
///
/// Requires the `googlehealth.activity_and_fitness.readonly` scope.
///
/// Uses the `active-minutes:rollUp` POST endpoint. The response contains one
/// rollup point per UTC calendar day, broken down into LIGHTLY_ACTIVE,
/// MODERATELY_ACTIVE, and VERY_ACTIVE buckets. Sedentary minutes are returned
/// by the separate `sedentary-period:rollUp` endpoint.
class GoogleHealthActiveMinutesDataManager
    extends GoogleHealthDataManager<GoogleHealthActiveMinutesData> {
  GoogleHealthActiveMinutesDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthActiveMinutesData> parseDataPoints(
    Map<String, dynamic> json,
  ) {
    final raw = json['rollupDataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthActiveMinutesData.fromJson)
        .toList(growable: false);
  }
}
