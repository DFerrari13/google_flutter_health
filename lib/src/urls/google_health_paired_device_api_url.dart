import 'google_health_api_url.dart';

/// URL builder for the Google Health paired-devices endpoints.
///
/// Requires the `googlehealth.settings.readonly` scope
/// ([GoogleHealthScopes.settingsReadonly]).
///
/// Use [list] to fetch all devices paired to the authenticated user, or
/// [get] to fetch a single device by its resource [name].
class GoogleHealthPairedDeviceAPIURL extends GoogleHealthAPIURL {
  GoogleHealthPairedDeviceAPIURL._({required super.uri});

  /// URL for listing all paired devices (`GET /v4/users/me/pairedDevices`).
  ///
  /// The response contains a `pairedDevices` array with one entry per device.
  static final GoogleHealthPairedDeviceAPIURL list =
      GoogleHealthPairedDeviceAPIURL._(
    uri: Uri.https('health.googleapis.com', '/v4/users/me/pairedDevices'),
  );

  /// URL for fetching a single paired device by resource [name].
  ///
  /// [name] must be in the form `users/me/pairedDevices/{deviceId}` as
  /// returned by the `name` field of a list response.
  factory GoogleHealthPairedDeviceAPIURL.get(String name) {
    return GoogleHealthPairedDeviceAPIURL._(
      uri: Uri.https('health.googleapis.com', '/v4/$name'),
    );
  }
}
