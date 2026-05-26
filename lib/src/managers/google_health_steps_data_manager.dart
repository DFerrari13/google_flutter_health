import '../data/google_health_steps_data.dart';
import 'google_health_data_manager.dart';

/// Fetches daily step-count rollup data from the Google Health API.
///
/// Requires the `googlehealth.activity_and_fitness.readonly` scope.
///
/// Uses the `steps:rollUp` POST endpoint, which returns one aggregated
/// [GoogleHealthStepsData] point per UTC calendar day. Each point's
/// [GoogleHealthStepsData.countSum] is the total step count for that day.
///
/// ```dart
/// final manager = GoogleHealthStepsDataManager(
///   credentials: credentials,
///   clientID: 'YOUR_CLIENT_ID',
///   clientSecret: 'YOUR_CLIENT_SECRET',
/// );
/// final result = await manager.fetch(
///   GoogleHealthStepsAPIURL.day(date: DateTime.now()),
/// );
/// final steps = result.data.firstOrNull?.countSum;
/// print('Today: $steps steps');
/// ```
class GoogleHealthStepsDataManager
    extends GoogleHealthDataManager<GoogleHealthStepsData> {
  GoogleHealthStepsDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthStepsData> parseDataPoints(Map<String, dynamic> json) {
    final raw = json['rollupDataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthStepsData.fromJson)
        .toList(growable: false);
  }
}
