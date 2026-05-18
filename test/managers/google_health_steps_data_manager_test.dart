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

    test('fetch() POSTs to dailyRollUp and parses civil-time data points',
        () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'civilStartTime': {
              'date': {'year': 2026, 'month': 1, 'day': 15},
            },
            'civilEndTime': {
              'date': {'year': 2026, 'month': 1, 'day': 16},
            },
            'steps': {'countSum': '5000'},
          },
          {
            'civilStartTime': {
              'date': {'year': 2026, 'month': 1, 'day': 16},
            },
            'civilEndTime': {
              'date': {'year': 2026, 'month': 1, 'day': 17},
            },
            'steps': {'countSum': '7500'},
          },
        ],
      });

      var endpointHit = false;
      final client = MockClient((request) async {
        if (request.url.path ==
                '/v4/users/me/dataTypes/steps/dataPoints:dailyRollUp' &&
            request.method == 'POST') {
          endpointHit = true;
          expect(request.headers['Authorization'], 'Bearer valid_token');
          expect(request.headers['Content-Type'], contains('application/json'));
          final decoded = jsonDecode(request.body) as Map<String, dynamic>;
          expect(decoded['range'], isNotNull);
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
        GoogleHealthStepsAPIURL.day(date: DateTime(2026, 1, 15)),
      );

      expect(endpointHit, isTrue);
      expect(result.data, hasLength(2));
      expect(result.data.first.count, 5000);
      expect(result.data[1].count, 7500);
      expect(result.credentials.accessToken, credentials.accessToken);
    });

    test('fetch() returns empty list when dataPoints is missing', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({}), 200);
      });

      final manager = GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthStepsAPIURL.day(date: DateTime(2026, 1, 15)),
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

      final manager = GoogleHealthStepsDataManager(
        credentials: expiredCredentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthStepsAPIURL.day(date: DateTime(2026, 1, 15)),
      );
      expect(result.credentials.accessToken, 'new_access_token');
    });

    test('fetch() throws GoogleHealthTokenExpiredException on 401', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final manager = GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      expect(
        () => manager.fetch(
          GoogleHealthStepsAPIURL.day(date: DateTime(2026, 1, 15)),
        ),
        throwsA(isA<GoogleHealthTokenExpiredException>()),
      );
    });

    test('fetch() throws GoogleHealthRateLimitException on 429', () async {
      final client = MockClient((request) async {
        return http.Response('Rate limit exceeded', 429,
            headers: {'retry-after': '30'});
      });

      final manager = GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      expect(
        () => manager.fetch(
          GoogleHealthStepsAPIURL.day(date: DateTime(2026, 1, 15)),
        ),
        throwsA(isA<GoogleHealthRateLimitException>()),
      );
    });
  });
}
