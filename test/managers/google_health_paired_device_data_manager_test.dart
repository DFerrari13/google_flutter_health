import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthPairedDeviceDataManager', () {
    late GoogleHealthCredentials credentials;

    setUp(() {
      credentials = GoogleHealthCredentials(
        accessToken: 'valid_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.settingsReadonly],
      );
    });

    test('fetch() with list URL parses pairedDevices array', () async {
      final body = jsonEncode({
        'pairedDevices': [
          {
            'name': 'users/me/pairedDevices/dev1',
            'deviceType': 'SMARTWATCH',
            'batteryStatus': 'HIGH',
            'batteryLevel': 88,
            'lastSyncTime': '2025-05-31T08:00:00Z',
            'deviceVersion': '3.0.1',
            'macAddress': 'AA:BB:CC:DD:EE:01',
            'features': ['HEART_RATE', 'STEPS'],
          },
          {
            'name': 'users/me/pairedDevices/dev2',
            'deviceType': 'FITNESS_TRACKER',
            'batteryStatus': 'LOW',
            'batteryLevel': 12,
            'lastSyncTime': '2025-05-30T20:00:00Z',
            'deviceVersion': '1.5.0',
            'macAddress': 'AA:BB:CC:DD:EE:02',
            'features': ['STEPS'],
          },
        ],
      });
      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthPairedDeviceDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(GoogleHealthPairedDeviceAPIURL.list);

      expect(result.data, hasLength(2));
      final first = result.data[0];
      expect(first.name, 'users/me/pairedDevices/dev1');
      expect(first.deviceType, 'SMARTWATCH');
      expect(first.batteryStatus, 'HIGH');
      expect(first.batteryLevel, 88);
      expect(first.features, ['HEART_RATE', 'STEPS']);

      final second = result.data[1];
      expect(second.name, 'users/me/pairedDevices/dev2');
      expect(second.batteryLevel, 12);
    });

    test('fetch() with get URL parses single device object', () async {
      final body = jsonEncode({
        'name': 'users/me/pairedDevices/dev1',
        'deviceType': 'SMARTWATCH',
        'batteryStatus': 'MEDIUM',
        'batteryLevel': 55,
        'lastSyncTime': '2025-05-31T09:00:00Z',
        'deviceVersion': '3.0.1',
        'macAddress': 'AA:BB:CC:DD:EE:01',
        'features': ['HEART_RATE'],
      });
      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthPairedDeviceDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthPairedDeviceAPIURL.get('users/me/pairedDevices/dev1'),
      );

      expect(result.data, hasLength(1));
      expect(result.data.first.name, 'users/me/pairedDevices/dev1');
      expect(result.data.first.batteryLevel, 55);
      expect(result.data.first.batteryStatus, 'MEDIUM');
    });

    test('fetch() returns empty list when pairedDevices absent', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthPairedDeviceDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(GoogleHealthPairedDeviceAPIURL.list);
      expect(result.data, isEmpty);
    });

    test('fetch() throws on 401', () async {
      final client = MockClient(
        (_) async => http.Response('Unauthorized', 401),
      );
      final manager = GoogleHealthPairedDeviceDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      expect(
        () => manager.fetch(GoogleHealthPairedDeviceAPIURL.list),
        throwsA(isA<GoogleHealthTokenExpiredException>()),
      );
    });

    test('fetch() sends Authorization header', () async {
      String? capturedAuth;
      final client = MockClient((request) async {
        capturedAuth = request.headers['Authorization'];
        return http.Response(
          jsonEncode({'pairedDevices': []}),
          200,
        );
      });
      final manager = GoogleHealthPairedDeviceDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      await manager.fetch(GoogleHealthPairedDeviceAPIURL.list);
      expect(capturedAuth, 'Bearer valid_token');
    });
  });
}
