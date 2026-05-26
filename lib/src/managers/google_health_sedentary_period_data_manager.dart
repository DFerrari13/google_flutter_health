import '../data/google_health_sedentary_period_data.dart';
import 'google_health_data_manager.dart';

/// Fetches daily sedentary-period rollup data from the Google Health API.
///
/// Requires the `googlehealth.activity_and_fitness.readonly` scope.
///
/// Uses the `sedentary-period:rollUp` POST endpoint. The response contains
/// one rollup point per UTC calendar day with the total sedentary duration
/// for that window. Active minutes are returned by the separate
/// `active-minutes:rollUp` endpoint.
class GoogleHealthSedentaryPeriodDataManager
    extends GoogleHealthDataManager<GoogleHealthSedentaryPeriodData> {
  GoogleHealthSedentaryPeriodDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthSedentaryPeriodData> parseDataPoints(
    Map<String, dynamic> json,
  ) {
    final raw = json['rollupDataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthSedentaryPeriodData.fromJson)
        .toList(growable: false);
  }
}
