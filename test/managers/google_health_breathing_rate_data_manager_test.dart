import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthBreathingRateDataManager', () {
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

    test('fetch() parses real API response shape', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'name': 'users/me/dataTypes/daily-respiratory-rate/dataPoints/abc',
            'dailyRespiratoryRate': {
              'date': {'year': 2025, 'month': 6, 'day': 12},
              'breathsPerMinute': 14.5,
            },
          },
        ],
      });
      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthBreathingRateDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthBreathingRateAPIURL.day(date: DateTime(2025, 6, 12)),
      );
      expect(result.data, hasLength(1));
      final point = result.data.first;
      expect(point.startTime, DateTime(2025, 6, 12));
      expect(point.breathsPerMinute, closeTo(14.5, 0.001));
    });

    test('fetch() returns empty list when dataPoints absent', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthBreathingRateDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthBreathingRateAPIURL.day(date: DateTime(2025, 6, 12)),
      );
      expect(result.data, isEmpty);
    });
  });
}
