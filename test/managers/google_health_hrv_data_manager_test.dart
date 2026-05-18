import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthHrvDataManager', () {
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

    test('fetch() parses HRV data points', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'dailyHeartRateVariability': {
              'rmssd': 38.0,
              'coverage': 0.85,
            },
          },
        ],
      });
      final client = MockClient((request) async {
        return http.Response(body, 200);
      });
      final manager = GoogleHealthHrvDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthHrvAPIURL.day(date: DateTime(2026, 1, 15)),
      );
      expect(result.data.first.rmssd, 38.0);
      expect(result.data.first.coverage, 0.85);
    });
  });
}
