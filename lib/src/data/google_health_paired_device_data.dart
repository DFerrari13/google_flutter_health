import '_parsing_helpers.dart';

/// Data for a single Bluetooth device paired to the authenticated Google Health
/// user (`users/*/pairedDevices/*`).
///
/// Returned by [GoogleHealthPairedDeviceDataManager] when called with
/// [GoogleHealthPairedDeviceAPIURL.list] (one item per device) or
/// [GoogleHealthPairedDeviceAPIURL.get] (single device).
///
/// Requires the `googlehealth.settings.readonly` scope.
class GoogleHealthPairedDeviceData {
  /// Resource name (e.g. `users/me/pairedDevices/abc123`).
  final String? name;

  /// Device type enum string (e.g. `SMARTWATCH`, `FITNESS_TRACKER`).
  final String? deviceType;

  /// Human-readable battery status string (e.g. `LOW`, `MEDIUM`, `HIGH`).
  final String? batteryStatus;

  /// Battery level as a percentage (0–100).
  final int? batteryLevel;

  /// RFC 3339 timestamp of the most recent sync.
  final String? lastSyncTime;

  /// Firmware or software version string.
  final String? deviceVersion;

  /// MAC address of the device.
  final String? macAddress;

  /// Feature identifiers supported by the device.
  final List<String> features;

  const GoogleHealthPairedDeviceData({
    this.name,
    this.deviceType,
    this.batteryStatus,
    this.batteryLevel,
    this.lastSyncTime,
    this.deviceVersion,
    this.macAddress,
    this.features = const [],
  });

  factory GoogleHealthPairedDeviceData.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    final features = rawFeatures is List
        ? rawFeatures.whereType<String>().toList(growable: false)
        : const <String>[];

    return GoogleHealthPairedDeviceData(
      name: json['name'] as String?,
      deviceType: json['deviceType'] as String?,
      batteryStatus: json['batteryStatus'] as String?,
      batteryLevel: parseInt64(json['batteryLevel']),
      lastSyncTime: json['lastSyncTime'] as String?,
      deviceVersion: json['deviceVersion'] as String?,
      macAddress: json['macAddress'] as String?,
      features: features,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'deviceType': deviceType,
        'batteryStatus': batteryStatus,
        'batteryLevel': batteryLevel,
        'lastSyncTime': lastSyncTime,
        'deviceVersion': deviceVersion,
        'macAddress': macAddress,
        'features': features,
      };

  @override
  String toString() => 'GoogleHealthPairedDeviceData('
      'name: $name, deviceType: $deviceType, '
      'batteryStatus: $batteryStatus, batteryLevel: $batteryLevel%, '
      'lastSyncTime: $lastSyncTime)';
}
