import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthSleepDataManager', () {
    late GoogleHealthCredentials credentials;

    setUp(() {
      credentials = GoogleHealthCredentials(
        accessToken: 'valid_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.sleepReadonly],
      );
    });

    test('fetch() flattens session stages into segments', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'name': 'users/me/dataTypes/sleep/dataPoints/s1',
            'sleep': {
              'interval': {
                'startTime': '2026-01-15T22:00:00Z',
                'endTime': '2026-01-16T06:00:00Z',
              },
              'type': 'STAGES',
              'stages': [
                {
                  'type': 'LIGHT',
                  'interval': {
                    'startTime': '2026-01-15T22:00:00Z',
                    'endTime': '2026-01-16T01:00:00Z',
                  },
                },
                {
                  'type': 'DEEP',
                  'interval': {
                    'startTime': '2026-01-16T01:00:00Z',
                    'endTime': '2026-01-16T03:00:00Z',
                  },
                },
              ],
            },
          },
        ],
      });

      final client = MockClient((request) async {
        return http.Response(body, 200);
      });

      final manager = GoogleHealthSleepDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthSleepAPIURL.day(date: DateTime(2026, 1, 15)),
      );
      expect(result.data, hasLength(2));
      expect(result.data.first.stage, 'LIGHT');
      expect(result.data[1].stage, 'DEEP');
      expect(result.data[1].duration, const Duration(hours: 2));
    });

    test('fetch() returns empty list when dataPoints is missing', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({}), 200);
      });
      final manager = GoogleHealthSleepDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthSleepAPIURL.day(date: DateTime(2026, 1, 15)),
      );
      expect(result.data, isEmpty);
    });
  });
}
