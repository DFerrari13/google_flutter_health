import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthWeightDataManager', () {
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

    test('fetch() parses raw weight samples', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'weight': {
              'weightKilograms': 70.0,
              'sampleTime': {'physicalTime': '2026-01-15T08:00:00Z'},
            },
          },
        ],
      });
      final client = MockClient((request) async {
        return http.Response(body, 200);
      });
      final manager = GoogleHealthWeightDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthWeightAPIURL.intraday(
          startTime: DateTime.utc(2026, 1, 15),
          endTime: DateTime.utc(2026, 1, 16),
        ),
      );
      expect(result.data.first.weightKg, 70.0);
    });
  });
}
