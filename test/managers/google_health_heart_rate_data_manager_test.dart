import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthHeartRateDataManager', () {
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

    test('fetch() GETs list endpoint and parses raw samples', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'heartRate': {
              'beatsPerMinute': '68',
              'sampleTime': {'physicalTime': '2026-01-15T10:00:00Z'},
            },
          },
          {
            'heartRate': {
              'beatsPerMinute': '75',
              'sampleTime': {'physicalTime': '2026-01-15T10:01:00Z'},
            },
          },
        ],
      });

      var endpointHit = false;
      final client = MockClient((request) async {
        if (request.url.path ==
                '/v4/users/me/dataTypes/heart-rate/dataPoints' &&
            request.method == 'GET') {
          endpointHit = true;
          expect(request.headers['Authorization'], 'Bearer valid_token');
          return http.Response(body, 200);
        }
        return http.Response('Not found', 404);
      });

      final manager = GoogleHealthHeartRateDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthHeartRateAPIURL.intraday(
          startTime: DateTime.utc(2026, 1, 15, 10),
          endTime: DateTime.utc(2026, 1, 15, 11),
        ),
      );
      expect(endpointHit, isTrue);
      expect(result.data, hasLength(2));
      expect(result.data.first.beatsPerMinute, 68);
      expect(result.data[1].beatsPerMinute, 75);
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
            'heartRate': {
              'beatsPerMinuteAvg': 72.0,
              'beatsPerMinuteMin': 50.0,
              'beatsPerMinuteMax': 140.0,
            },
          },
        ],
      });

      final client = MockClient((request) async {
        if (request.method == 'POST') {
          return http.Response(body, 200);
        }
        return http.Response('Not found', 404);
      });

      final manager = GoogleHealthHeartRateDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthHeartRateAPIURL.day(date: DateTime(2026, 1, 15)),
      );
      expect(result.data, hasLength(1));
      expect(result.data.first.beatsPerMinuteAvg, 72.0);
      expect(result.data.first.beatsPerMinuteMin, 50.0);
      expect(result.data.first.beatsPerMinuteMax, 140.0);
    });

    test('fetch() throws on 401', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final manager = GoogleHealthHeartRateDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      expect(
        () => manager.fetch(
          GoogleHealthHeartRateAPIURL.day(date: DateTime(2026, 1, 15)),
        ),
        throwsA(isA<GoogleHealthTokenExpiredException>()),
      );
    });
  });
}
