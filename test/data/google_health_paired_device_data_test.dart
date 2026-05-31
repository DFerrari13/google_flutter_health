import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthPairedDeviceData', () {
    test('fromJson parses all fields', () {
      final data = GoogleHealthPairedDeviceData.fromJson({
        'name': 'users/me/pairedDevices/abc123',
        'deviceType': 'SMARTWATCH',
        'batteryStatus': 'MEDIUM',
        'batteryLevel': 72,
        'lastSyncTime': '2025-05-31T08:00:00Z',
        'deviceVersion': '1.2.3',
        'macAddress': 'AA:BB:CC:DD:EE:FF',
        'features': ['HEART_RATE', 'STEPS'],
      });

      expect(data.name, 'users/me/pairedDevices/abc123');
      expect(data.deviceType, 'SMARTWATCH');
      expect(data.batteryStatus, 'MEDIUM');
      expect(data.batteryLevel, 72);
      expect(data.lastSyncTime, '2025-05-31T08:00:00Z');
      expect(data.deviceVersion, '1.2.3');
      expect(data.macAddress, 'AA:BB:CC:DD:EE:FF');
      expect(data.features, ['HEART_RATE', 'STEPS']);
    });

    test('fromJson handles string-encoded batteryLevel', () {
      final data = GoogleHealthPairedDeviceData.fromJson({
        'name': 'users/me/pairedDevices/x',
        'batteryLevel': '45',
      });
      expect(data.batteryLevel, 45);
    });

    test('fromJson handles missing optional fields', () {
      final data = GoogleHealthPairedDeviceData.fromJson(
        const <String, dynamic>{},
      );
      expect(data.name, isNull);
      expect(data.deviceType, isNull);
      expect(data.batteryStatus, isNull);
      expect(data.batteryLevel, isNull);
      expect(data.features, isEmpty);
    });

    test('fromJson handles missing features key', () {
      final data = GoogleHealthPairedDeviceData.fromJson({
        'name': 'users/me/pairedDevices/x',
      });
      expect(data.features, isEmpty);
    });

    test('toJson/fromJson roundtrip preserves all fields', () {
      const original = GoogleHealthPairedDeviceData(
        name: 'users/me/pairedDevices/xyz',
        deviceType: 'FITNESS_TRACKER',
        batteryStatus: 'LOW',
        batteryLevel: 15,
        lastSyncTime: '2025-05-30T22:00:00Z',
        deviceVersion: '2.0',
        macAddress: '11:22:33:44:55:66',
        features: ['SPO2', 'SLEEP'],
      );
      final restored = GoogleHealthPairedDeviceData.fromJson(original.toJson());
      expect(restored.name, original.name);
      expect(restored.deviceType, original.deviceType);
      expect(restored.batteryStatus, original.batteryStatus);
      expect(restored.batteryLevel, original.batteryLevel);
      expect(restored.lastSyncTime, original.lastSyncTime);
      expect(restored.deviceVersion, original.deviceVersion);
      expect(restored.macAddress, original.macAddress);
      expect(restored.features, original.features);
    });
  });
}
