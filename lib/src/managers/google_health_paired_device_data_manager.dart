import '../data/google_health_paired_device_data.dart';
import 'google_health_data_manager.dart';

/// Fetches paired devices from the Google Health API.
///
/// Requires the `googlehealth.settings.readonly` scope
/// ([GoogleHealthScopes.settingsReadonly]).
///
/// Use with [GoogleHealthPairedDeviceAPIURL.list] to retrieve all devices
/// paired to the authenticated user, or with
/// [GoogleHealthPairedDeviceAPIURL.get] to retrieve a single device by its
/// resource name.
class GoogleHealthPairedDeviceDataManager
    extends GoogleHealthDataManager<GoogleHealthPairedDeviceData> {
  GoogleHealthPairedDeviceDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  List<GoogleHealthPairedDeviceData> parseDataPoints(
    Map<String, dynamic> json,
  ) {
    // List endpoint: {"pairedDevices": [...]}
    final raw = json['pairedDevices'];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(GoogleHealthPairedDeviceData.fromJson)
          .toList(growable: false);
    }
    // Get-single endpoint returns the device object directly.
    if (json.containsKey('name')) {
      return [GoogleHealthPairedDeviceData.fromJson(json)];
    }
    return const [];
  }
}
