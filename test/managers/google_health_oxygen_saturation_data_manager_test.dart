import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthOxygenSaturationDataManager', () {
    late GoogleHealthCredentials credentials;
    late GoogleHealthCredentials expiredCredentials;

    setUp(() {
      credentials = GoogleHealthCredentials(
        accessToken: 'valid_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.healthMetricsReadonly],
      );

      expiredCredentials = GoogleHealthCredentials(
        accessToken: 'expired_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().subtract(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.healthMetricsReadonly],
      );
    });

    test('fetch() returns parsed data points and unchanged credentials',
        () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'userId': 'user_123',
            'startTime': '2026-01-15T00:00:00Z',
            'value': {
              'spo2Percentage': 97.0,
              'spo2Low': 94.0,
              'spo2High': 99.0,
            },
          },
        ],
      });

      var endpointHit = false;
      final client = MockClient((request) async {
        if (request.url.path ==
            '/v4/users/me/dataTypes/daily-oxygen-saturation/dataPoints:dailyRollup') {
          endpointHit = true;
          expect(request.headers['Authorization'], 'Bearer valid_token');
          return http.Response(body, 200);
        }
        return http.Response('Not found', 404);
      });

      final manager = GoogleHealthOxygenSaturationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthOxygenSaturationAPIURL.dailyRollup(
          startDate: DateTime(2026, 1, 15),
          endDate: DateTime(2026, 1, 15),
        ),
      );

      expect(endpointHit, isTrue);
      expect(result.data, hasLength(1));
      expect(result.data.first.spo2Percentage, 97.0);
      expect(result.data.first.spo2Low, 94.0);
      expect(result.credentials.accessToken, credentials.accessToken);
    });

    test('fetch() returns empty list when dataPoints is missing', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({}), 200);
      });

      final manager = GoogleHealthOxygenSaturationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthOxygenSaturationAPIURL.dailyRollup(
          startDate: DateTime(2026, 1, 15),
          endDate: DateTime(2026, 1, 15),
        ),
      );

      expect(result.data, isEmpty);
    });

    test('fetch() refreshes token when isExpired is true', () async {
      final newTokenBody = jsonEncode({
        'access_token': 'new_access_token',
        'expires_in': 3600,
        'token_type': 'Bearer',
      });
      final dataBody = jsonEncode({'dataPoints': []});

      final client = MockClient((request) async {
        if (request.url.host == 'oauth2.googleapis.com') {
          return http.Response(newTokenBody, 200);
        }
        return http.Response(dataBody, 200);
      });

      final manager = GoogleHealthOxygenSaturationDataManager(
        credentials: expiredCredentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthOxygenSaturationAPIURL.dailyRollup(
          startDate: DateTime(2026, 1, 15),
          endDate: DateTime(2026, 1, 15),
        ),
      );

      expect(result.credentials.accessToken, 'new_access_token');
    });

    test('fetch() throws GoogleHealthTokenExpiredException on 401', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final manager = GoogleHealthOxygenSaturationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      expect(
        () => manager.fetch(
          GoogleHealthOxygenSaturationAPIURL.dailyRollup(
            startDate: DateTime(2026, 1, 15),
            endDate: DateTime(2026, 1, 15),
          ),
        ),
        throwsA(isA<GoogleHealthTokenExpiredException>()),
      );
    });

    test('fetch() throws GoogleHealthRateLimitException on 429', () async {
      final client = MockClient((request) async {
        return http.Response('Rate limit exceeded', 429);
      });

      final manager = GoogleHealthOxygenSaturationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      expect(
        () => manager.fetch(
          GoogleHealthOxygenSaturationAPIURL.dailyRollup(
            startDate: DateTime(2026, 1, 15),
            endDate: DateTime(2026, 1, 15),
          ),
        ),
        throwsA(isA<GoogleHealthRateLimitException>()),
      );
    });
  });
}
