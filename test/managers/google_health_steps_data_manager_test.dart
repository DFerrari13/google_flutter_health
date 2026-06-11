import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthStepsDataManager', () {
    late GoogleHealthCredentials credentials;
    late GoogleHealthCredentials expiredCredentials;

    setUp(() {
      credentials = GoogleHealthCredentials(
        accessToken: 'valid_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.activityAndFitnessReadonly],
      );

      expiredCredentials = GoogleHealthCredentials(
        accessToken: 'expired_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().subtract(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.activityAndFitnessReadonly],
      );
    });

    test('fetch() POSTs to :rollUp endpoint and parses rollupDataPoints',
        () async {
      final body = jsonEncode({
        'rollupDataPoints': [
          {
            'startTime': '2025-06-12T00:00:00Z',
            'endTime': '2025-06-13T00:00:00Z',
            'steps': {'countSum': '8500'},
          },
        ],
      });

      var endpointHit = false;
      final client = MockClient((request) async {
        if (request.url.path ==
                '/v4/users/me/dataTypes/steps/dataPoints:rollUp' &&
            request.method == 'POST') {
          endpointHit = true;
          final reqBody = jsonDecode(request.body) as Map<String, dynamic>;
          expect(reqBody['windowSize'], '86400s');
          expect((reqBody['range'] as Map)['startTime'],
              '2025-06-12T00:00:00.000Z');
          return http.Response(body, 200);
        }
        return http.Response('Not found', 404);
      });

      final manager = GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthStepsAPIURL.day(date: DateTime(2025, 6, 12)),
      );

      expect(endpointHit, isTrue);
      expect(result.data, hasLength(1));
      expect(result.data.first.countSum, 8500);
    });

    test('fetch() returns empty list when rollupDataPoints is missing',
        () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthStepsAPIURL.day(date: DateTime(2025, 6, 12)),
      );
      expect(result.data, isEmpty);
    });

    test('fetch() refreshes token when isExpired is true', () async {
      final client = MockClient((request) async {
        if (request.url.host == 'oauth2.googleapis.com') {
          return http.Response(
            jsonEncode({
              'access_token': 'new_access_token',
              'expires_in': 3600,
              'token_type': 'Bearer',
            }),
            200,
          );
        }
        return http.Response(jsonEncode({'rollupDataPoints': []}), 200);
      });
      final manager = GoogleHealthStepsDataManager(
        credentials: expiredCredentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthStepsAPIURL.day(date: DateTime(2025, 6, 12)),
      );
      expect(result.credentials.accessToken, 'new_access_token');
    });

    test('fetch() throws GoogleHealthTokenExpiredException on 401', () async {
      final client =
          MockClient((_) async => http.Response('Unauthorized', 401));
      final manager = GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      expect(
        () => manager.fetch(
          GoogleHealthStepsAPIURL.day(date: DateTime(2025, 6, 12)),
        ),
        throwsA(isA<GoogleHealthTokenExpiredException>()),
      );
    });

    test('fetch() force-refreshes and retries once on unexpected 401',
        () async {
      var dataCalls = 0;
      final client = MockClient((request) async {
        if (request.url.host == 'oauth2.googleapis.com') {
          return http.Response(
            jsonEncode({
              'access_token': 'recovered_token',
              'expires_in': 3600,
              'token_type': 'Bearer',
            }),
            200,
          );
        }
        dataCalls++;
        if (request.headers['Authorization'] == 'Bearer recovered_token') {
          return http.Response(jsonEncode({'rollupDataPoints': []}), 200);
        }
        // Token is locally valid but rejected server-side (clock skew /
        // server-side invalidation).
        return http.Response('Unauthorized', 401);
      });
      final manager = GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthStepsAPIURL.day(date: DateTime(2025, 6, 12)),
      );
      expect(dataCalls, 2);
      expect(result.credentials.accessToken, 'recovered_token');
    });

    test('fetch() adopts a rotated refresh token from the token endpoint',
        () async {
      final client = MockClient((request) async {
        if (request.url.host == 'oauth2.googleapis.com') {
          return http.Response(
            jsonEncode({
              'access_token': 'new_access_token',
              'refresh_token': 'rotated_refresh_token',
              'expires_in': 3600,
              'token_type': 'Bearer',
            }),
            200,
          );
        }
        return http.Response(jsonEncode({'rollupDataPoints': []}), 200);
      });
      final manager = GoogleHealthStepsDataManager(
        credentials: expiredCredentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthStepsAPIURL.day(date: DateTime(2025, 6, 12)),
      );
      expect(result.credentials.refreshToken, 'rotated_refresh_token');
    });

    test('fetch() wraps network failures in GoogleHealthNetworkException',
        () async {
      final client = MockClient(
        (_) async => throw http.ClientException('Connection failed'),
      );
      final manager = GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      expect(
        () => manager.fetch(
          GoogleHealthStepsAPIURL.day(date: DateTime(2025, 6, 12)),
        ),
        throwsA(isA<GoogleHealthNetworkException>()),
      );
    });

    test('fetch() throws GoogleHealthRateLimitException on 429', () async {
      final client = MockClient((_) async => http.Response(
            'Rate limit exceeded',
            429,
            headers: {'retry-after': '30'},
          ));
      final manager = GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      expect(
        () => manager.fetch(
          GoogleHealthStepsAPIURL.day(date: DateTime(2025, 6, 12)),
        ),
        throwsA(isA<GoogleHealthRateLimitException>()),
      );
    });
  });
}
