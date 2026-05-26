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

    test('fetch() parses HRV data using real API field names', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'name':
                'users/me/dataTypes/daily-heart-rate-variability/dataPoints/x',
            'dailyHeartRateVariability': {
              'date': {'year': 2025, 'month': 6, 'day': 12},
              'averageHeartRateVariabilityMilliseconds': 38.0,
              'nonRemHeartRateBeatsPerMinute': '60',
              'entropy': 1.1,
              'deepSleepRootMeanSquareOfSuccessiveDifferencesMilliseconds':
                  41.0,
            },
          },
        ],
      });
      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthHrvDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthHrvAPIURL.day(date: DateTime(2025, 6, 12)),
      );
      expect(result.data, hasLength(1));
      final point = result.data.first;
      expect(point.startTime, DateTime(2025, 6, 12));
      expect(point.rmssd, 38.0);
      expect(point.nonRemBpm, 60);
      expect(point.entropy, 1.1);
      expect(point.deepSleepRmssdMs, 41.0);
    });

    test('fetch() returns empty list when dataPoints absent', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthHrvDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthHrvAPIURL.day(date: DateTime(2025, 6, 12)),
      );
      expect(result.data, isEmpty);
    });
  });
}
