import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthDistanceDataManager', () {
    late GoogleHealthCredentials credentials;

    setUp(() {
      credentials = GoogleHealthCredentials(
        accessToken: 'valid_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.activityAndFitnessReadonly],
      );
    });

    test('fetch() POSTs dailyRollUp and parses aggregates', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'civilStartTime': {
              'date': {'year': 2026, 'month': 1, 'day': 15},
            },
            'civilEndTime': {
              'date': {'year': 2026, 'month': 1, 'day': 16},
            },
            'distance': {'distanceMetersSum': 4200.0},
          },
        ],
      });

      final client = MockClient((request) async {
        if (request.method == 'POST') return http.Response(body, 200);
        return http.Response('Not found', 404);
      });

      final manager = GoogleHealthDistanceDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthDistanceAPIURL.day(date: DateTime(2026, 1, 15)),
      );
      expect(result.data.first.distanceMeters, 4200.0);
    });

    test('fetch() throws on 401', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });
      final manager = GoogleHealthDistanceDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      expect(
        () => manager.fetch(
          GoogleHealthDistanceAPIURL.day(date: DateTime(2026, 1, 15)),
        ),
        throwsA(isA<GoogleHealthTokenExpiredException>()),
      );
    });
  });
}
