import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthActiveZoneMinutesDataManager', () {
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

    test('fetch() POSTs dailyRollUp and parses AZM aggregates', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'civilStartTime': {
              'date': {'year': 2026, 'month': 1, 'day': 15},
            },
            'civilEndTime': {
              'date': {'year': 2026, 'month': 1, 'day': 16},
            },
            'activeZoneMinutes': {
              'fatBurnMinutesSum': 10.0,
              'cardioMinutesSum': 20.0,
              'peakMinutesSum': 5.0,
              'totalMinutesSum': 35.0,
            },
          },
        ],
      });
      final client = MockClient((request) async {
        return http.Response(body, 200);
      });
      final manager = GoogleHealthActiveZoneMinutesDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthActiveZoneMinutesAPIURL.day(date: DateTime(2026, 1, 15)),
      );
      expect(result.data.first.totalMinutes, 35.0);
      expect(result.data.first.cardioMinutes, 20.0);
    });
  });
}
