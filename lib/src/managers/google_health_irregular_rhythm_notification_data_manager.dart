import '../data/google_health_irregular_rhythm_notification_data.dart';
import 'google_health_data_manager.dart';

/// Fetches Irregular Rhythm Notification (IRN/AFib) sessions from the Google
/// Health API.
///
/// Requires the `googlehealth.irn.readonly` scope
/// ([GoogleHealthScopes.irnReadonly]).
class GoogleHealthIrregularRhythmNotificationDataManager
    extends GoogleHealthDataManager<
        GoogleHealthIrregularRhythmNotificationData> {
  GoogleHealthIrregularRhythmNotificationDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthIrregularRhythmNotificationData> parseDataPoints(
    Map<String, dynamic> json,
  ) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthIrregularRhythmNotificationData.fromJson)
        .toList(growable: false);
  }
}
