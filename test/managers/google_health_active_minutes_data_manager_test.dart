import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthActiveMinutesDataManager', () {
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

    test('fetch() POSTs to :rollUp and parses 3-level rollup point', () async {
      final body = jsonEncode({
        'rollupDataPoints': [
          {
            'startTime': '2026-05-26T00:00:00Z',
            'endTime': '2026-05-27T00:00:00Z',
            'activeMinutes': {
              'activeMinutesRollupByActivityLevel': [
                {'activityLevel': 'LIGHT', 'activeMinutesSum': '40'},
                {'activityLevel': 'MODERATE', 'activeMinutesSum': '15'},
                {'activityLevel': 'VIGOROUS', 'activeMinutesSum': '5'},
              ],
            },
          },
        ],
      });

      var endpointHit = false;
      final client = MockClient((request) async {
        if (request.url.path ==
                '/v4/users/me/dataTypes/active-minutes/dataPoints:rollUp' &&
            request.method == 'POST') {
          endpointHit = true;
          final reqBody = jsonDecode(request.body) as Map<String, dynamic>;
          expect(reqBody['windowSize'], '86400s');
          return http.Response(body, 200);
        }
        return http.Response('Not found', 404);
      });

      final manager = GoogleHealthActiveMinutesDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthActiveMinutesAPIURL.day(date: DateTime(2026, 5, 26)),
      );

      expect(endpointHit, isTrue);
      expect(result.data, hasLength(1));
      final d = result.data.first;
      expect(d.lightlyActiveMinutes, 40);
      expect(d.moderatelyActiveMinutes, 15);
      expect(d.veryActiveMinutes, 5);
      expect(d.totalActiveMinutes, 60);
    });

    test('fetch() returns empty list when rollupDataPoints absent', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthActiveMinutesDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthActiveMinutesAPIURL.day(date: DateTime(2026, 5, 26)),
      );
      expect(result.data, isEmpty);
    });
  });
}
