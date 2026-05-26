import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthOxygenSaturationDataManager', () {
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

    test('fetch() parses SpO2 data using real API field names', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'name': 'users/me/dataTypes/daily-oxygen-saturation/dataPoints/abc',
            'dailyOxygenSaturation': {
              'date': {'year': 2026, 'month': 1, 'day': 15},
              'averagePercentage': 97.0,
              'lowerBoundPercentage': 95.0,
              'upperBoundPercentage': 99.0,
              'standardDeviationPercentage': 0.8,
            },
          },
        ],
      });
      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthOxygenSaturationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthOxygenSaturationAPIURL.day(date: DateTime(2026, 1, 15)),
      );
      expect(result.data, hasLength(1));
      final point = result.data.first;
      expect(point.startTime, DateTime(2026, 1, 15));
      expect(point.percentageAvg, 97.0);
      expect(point.percentageMin, 95.0);
      expect(point.percentageMax, 99.0);
      expect(point.percentageStdDev, 0.8);
    });

    test('fetch() returns empty list when dataPoints is absent', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthOxygenSaturationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      final result = await manager.fetch(
        GoogleHealthOxygenSaturationAPIURL.day(date: DateTime(2026, 1, 15)),
      );
      expect(result.data, isEmpty);
    });
  });
}
