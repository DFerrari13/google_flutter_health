import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _session(String type, String name) => {
      'name': name,
      'sleep': {
        'interval': {
          'startTime': '2026-05-25T22:00:00Z',
          'endTime': '2026-05-26T06:00:00Z',
        },
        'type': type,
        'summary': {
          'minutesAsleep': '440',
          'minutesAwake': '40',
          'stagesSummary': [
            {'type': 'DEEP', 'minutes': '120', 'count': '4'},
            {'type': 'REM', 'minutes': '120', 'count': '5'},
            {'type': 'LIGHT', 'minutes': '200', 'count': '12'},
            {'type': 'AWAKE', 'minutes': '40', 'count': '8'},
          ],
        },
      },
    };

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

    test('fetch() parses main sleep session with summary and stages', () async {
      final body = jsonEncode({
        'dataPoints': [
          _session('MAIN_SLEEP', 'users/me/dataTypes/sleep/dataPoints/s1')
        ],
      });
      var endpointHit = false;
      final client = MockClient((request) async {
        if (request.url.path == '/v4/users/me/dataTypes/sleep/dataPoints' &&
            request.method == 'GET') {
          endpointHit = true;
          final filter = request.url.queryParameters['filter']!;
          expect(filter, contains('sleep.interval.end_time'));
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
        GoogleHealthSleepAPIURL.day(date: DateTime(2026, 5, 26)),
      );
      expect(endpointHit, isTrue);
      expect(result.data, hasLength(1));
      final s = result.data.first;
      expect(s.sleepType, 'MAIN_SLEEP');
      expect(s.minutesAsleep, 440);
      expect(s.deepMinutes, 120);
      expect(s.remMinutes, 120);
      expect(s.lightMinutes, 200);
      expect(s.awakeMinutes, 40);
      expect(s.duration, const Duration(hours: 8));
    });

    test('fetch() filters out NAP sessions', () async {
      final body = jsonEncode({
        'dataPoints': [
          _session('MAIN_SLEEP', 'users/me/dataTypes/sleep/dataPoints/s1'),
          _session('NAP', 'users/me/dataTypes/sleep/dataPoints/s2'),
        ],
      });
      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthSleepDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthSleepAPIURL.day(date: DateTime(2026, 5, 26)),
      );
      expect(result.data, hasLength(1));
      expect(result.data.first.sleepType, 'MAIN_SLEEP');
    });

    test('fetch() returns empty list when dataPoints absent', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthSleepDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthSleepAPIURL.day(date: DateTime(2026, 5, 26)),
      );
      expect(result.data, isEmpty);
    });
  });
}
