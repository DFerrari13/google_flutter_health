import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthExerciseDataManager', () {
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

    test('fetch() parses exercise sessions', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'exercise': {
              'exerciseType': 'WALKING',
              'displayName': 'Evening walk',
              'interval': {
                'startTime': '2026-01-15T18:00:00Z',
                'endTime': '2026-01-15T18:30:00Z',
              },
              'metricsSummary': {
                'energyKilocalories': 150.0,
                'distanceMeters': 2500.0,
                'steps': '3000',
              },
            },
          },
        ],
      });
      final client = MockClient((request) async {
        return http.Response(body, 200);
      });
      final manager = GoogleHealthExerciseDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthExerciseAPIURL.day(date: DateTime(2026, 1, 15)),
      );
      expect(result.data, hasLength(1));
      expect(result.data.first.exerciseType, 'WALKING');
      expect(result.data.first.steps, 3000);
      expect(result.data.first.distanceMeters, 2500.0);
    });
  });
}
