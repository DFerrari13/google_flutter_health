import '../data/google_health_steps_data.dart';
import 'google_health_data_manager.dart';

/// Fetches step count data from the Google Health API.
///
/// Requires the `googlehealth.activity_and_fitness.readonly` scope.
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
/// for (final step in result.data) {
///   print('${step.startTime}: ${step.count} steps');
/// }
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
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthStepsData.fromJson)
        .toList(growable: false);
  }
}
