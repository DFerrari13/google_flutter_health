import '../data/google_health_electrocardiogram_data.dart';
import 'google_health_data_manager.dart';

/// Fetches Electrocardiogram (ECG) readings from the Google Health API.
///
/// Requires the `googlehealth.ecg.readonly` scope
/// ([GoogleHealthScopes.ecgReadonly]).
class GoogleHealthElectrocardiogramDataManager
    extends GoogleHealthDataManager<GoogleHealthElectrocardiogramData> {
  GoogleHealthElectrocardiogramDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthElectrocardiogramData> parseDataPoints(
    Map<String, dynamic> json,
  ) {
    final raw = json['dataPoints'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(GoogleHealthElectrocardiogramData.fromJson)
        .toList(growable: false);
  }
}
