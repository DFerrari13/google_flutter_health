import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthSleepDataManager', () {
    late GoogleHealthCredentials credentials;
    late GoogleHealthCredentials expiredCredentials;

    setUp(() {
      credentials = GoogleHealthCredentials(
        accessToken: 'valid_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.sleepReadonly],
      );

      expiredCredentials = GoogleHealthCredentials(
        accessToken: 'expired_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().subtract(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.sleepReadonly],
      );
    });

    test('fetch() returns parsed sleep segments and unchanged credentials',
        () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'userId': 'user_123',
            'startTime': '2026-01-15T22:00:00Z',
            'endTime': '2026-01-16T01:00:00Z',
            'sleepStage': 'LIGHT',
          },
          {
            'userId': 'user_123',
            'startTime': '2026-01-16T01:00:00Z',
            'endTime': '2026-01-16T03:00:00Z',
            'sleepStage': 'DEEP',
          },
        ],
      });

      var endpointHit = false;
      final client = MockClient((request) async {
        if (request.url.path == '/v4/users/me/dataTypes/sleep/dataPoints') {
          endpointHit = true;
          expect(request.headers['Authorization'], 'Bearer valid_token');
          return http.Response(body, 200);
        }
        return http.Response('Not found', 404);
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

      expect(endpointHit, isTrue);
      expect(result.data, hasLength(2));
      expect(result.data.first.sleepStage, 'LIGHT');
      expect(result.data[1].sleepStage, 'DEEP');
      expect(result.data[1].duration, const Duration(hours: 2));
      expect(result.credentials.accessToken, credentials.accessToken);
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

      final manager = GoogleHealthSleepDataManager(
        credentials: expiredCredentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthSleepAPIURL.day(date: DateTime(2026, 1, 15)),
      );

      expect(result.credentials.accessToken, 'new_access_token');
    });

    test('fetch() throws GoogleHealthTokenExpiredException on 401', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final manager = GoogleHealthSleepDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      expect(
        () => manager.fetch(
          GoogleHealthSleepAPIURL.day(date: DateTime(2026, 1, 15)),
        ),
        throwsA(isA<GoogleHealthTokenExpiredException>()),
      );
    });

    test('fetch() throws GoogleHealthRateLimitException on 429', () async {
      final client = MockClient((request) async {
        return http.Response('Rate limit exceeded', 429);
      });

      final manager = GoogleHealthSleepDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      expect(
        () => manager.fetch(
          GoogleHealthSleepAPIURL.day(date: DateTime(2026, 1, 15)),
        ),
        throwsA(isA<GoogleHealthRateLimitException>()),
      );
    });
  });
}
