import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthSedentaryPeriodDataManager', () {
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

    test('fetch() POSTs to :rollUp and parses sedentary duration', () async {
      final body = jsonEncode({
        'rollupDataPoints': [
          {
            'startTime': '2026-05-26T00:00:00Z',
            'endTime': '2026-05-27T00:00:00Z',
            'sedentaryPeriod': {'durationSum': '28800s'},
          },
        ],
      });

      var endpointHit = false;
      final client = MockClient((request) async {
        if (request.url.path ==
                '/v4/users/me/dataTypes/sedentary-period/dataPoints:rollUp' &&
            request.method == 'POST') {
          endpointHit = true;
          final reqBody = jsonDecode(request.body) as Map<String, dynamic>;
          expect(reqBody['windowSize'], '86400s');
          return http.Response(body, 200);
        }
        return http.Response('Not found', 404);
      });

      final manager = GoogleHealthSedentaryPeriodDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthSedentaryPeriodAPIURL.day(date: DateTime(2026, 5, 26)),
      );

      expect(endpointHit, isTrue);
      expect(result.data, hasLength(1));
      expect(result.data.first.duration, const Duration(hours: 8));
    });

    test('fetch() returns empty list when rollupDataPoints absent', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthSedentaryPeriodDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthSedentaryPeriodAPIURL.day(date: DateTime(2026, 5, 26)),
      );
      expect(result.data, isEmpty);
    });
  });
}
