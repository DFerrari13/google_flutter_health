import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthSkinTemperatureDataManager', () {
    late GoogleHealthCredentials credentials;

    setUp(() {
      credentials = GoogleHealthCredentials(
        accessToken: 'valid_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.healthMetricsReadonly],
      );
    });

    test('fetch() parses real API response shape', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'name':
                'users/me/dataTypes/daily-sleep-temperature-derivations/dataPoints/abc',
            'dailySleepTemperatureDerivations': {
              'date': {'year': 2025, 'month': 6, 'day': 12},
              'nightlyTemperatureCelsius': 36.4,
              'baselineTemperatureCelsius': 36.1,
              'relativeNightlyStddev30dCelsius': 0.3,
            },
          },
        ],
      });
      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthSkinTemperatureDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthSkinTemperatureAPIURL.day(date: DateTime(2025, 6, 12)),
      );
      expect(result.data, hasLength(1));
      final point = result.data.first;
      expect(point.startTime, DateTime(2025, 6, 12));
      expect(point.nightlyCelsius, closeTo(36.4, 0.001));
      expect(point.baselineCelsius, closeTo(36.1, 0.001));
      expect(point.relativeStddev30dCelsius, closeTo(0.3, 0.001));
    });

    test('fetch() returns empty list when dataPoints absent', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthSkinTemperatureDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthSkinTemperatureAPIURL.day(date: DateTime(2025, 6, 12)),
      );
      expect(result.data, isEmpty);
    });
  });
}
