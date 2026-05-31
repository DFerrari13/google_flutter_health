import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthIrregularRhythmNotificationDataManager', () {
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

    test('fetch() parses full API response', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'name':
                'users/me/dataTypes/irregular-rhythm-notification/dataPoints/abc',
            'irregularRhythmNotification': {
              'interval': {
                'startTime': '2025-05-31T02:10:00Z',
                'endTime': '2025-05-31T02:25:00Z',
              },
              'alertWindows': [
                {
                  'startTime': '2025-05-31T02:10:00Z',
                  'startUtcOffset': '+02:00',
                  'endTime': '2025-05-31T02:15:00Z',
                  'endUtcOffset': '+02:00',
                  'positive': true,
                  'heartBeats': [
                    {
                      'physicalTime': '2025-05-31T02:11:00Z',
                      'utcOffset': '+02:00',
                      'beatsPerMinute': 112,
                    },
                  ],
                },
              ],
              'medicalDeviceInfo': {
                'algorithmVersion': '2.1.0',
                'deviceModel': 'Pixel Watch 2',
              },
            },
          },
        ],
      });

      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthIrregularRhythmNotificationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthIrregularRhythmNotificationAPIURL.day(
          date: DateTime(2025, 5, 31),
        ),
      );

      expect(result.data, hasLength(1));
      final point = result.data.first;
      expect(
        point.name,
        'users/me/dataTypes/irregular-rhythm-notification/dataPoints/abc',
      );
      expect(point.startTime, DateTime.parse('2025-05-31T02:10:00Z').toLocal());
      expect(point.alertWindows, hasLength(1));
      expect(point.alertWindows.first.positive, isTrue);
      expect(point.alertWindows.first.heartBeats.first.beatsPerMinute, 112);
      expect(point.medicalDeviceInfo!.algorithmVersion, '2.1.0');
      expect(point.medicalDeviceInfo!.deviceModel, 'Pixel Watch 2');
    });

    test('fetch() handles multiple dataPoints', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'name':
                'users/me/dataTypes/irregular-rhythm-notification/dataPoints/1',
            'irregularRhythmNotification': {
              'interval': {
                'startTime': '2025-05-30T01:00:00Z',
                'endTime': '2025-05-30T01:15:00Z',
              },
              'alertWindows': <dynamic>[],
            },
          },
          {
            'name':
                'users/me/dataTypes/irregular-rhythm-notification/dataPoints/2',
            'irregularRhythmNotification': {
              'interval': {
                'startTime': '2025-05-31T02:00:00Z',
                'endTime': '2025-05-31T02:20:00Z',
              },
              'alertWindows': <dynamic>[],
            },
          },
        ],
      });

      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthIrregularRhythmNotificationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthIrregularRhythmNotificationAPIURL.dateRange(
          startDate: DateTime(2025, 5, 30),
          endDate: DateTime(2025, 5, 31),
        ),
      );

      expect(result.data, hasLength(2));
    });

    test('fetch() returns empty list when dataPoints absent', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthIrregularRhythmNotificationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthIrregularRhythmNotificationAPIURL.day(
          date: DateTime(2025, 5, 31),
        ),
      );
      expect(result.data, isEmpty);
    });

    test('fetch() throws on 401', () async {
      final client = MockClient(
        (_) async => http.Response('Unauthorized', 401),
      );
      final manager = GoogleHealthIrregularRhythmNotificationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      expect(
        () => manager.fetch(
          GoogleHealthIrregularRhythmNotificationAPIURL.day(
            date: DateTime(2025, 5, 31),
          ),
        ),
        throwsA(isA<GoogleHealthTokenExpiredException>()),
      );
    });

    test('fetch() sends Authorization header', () async {
      String? capturedAuth;
      final client = MockClient((request) async {
        capturedAuth = request.headers['Authorization'];
        return http.Response(
          jsonEncode({'dataPoints': <dynamic>[]}),
          200,
        );
      });
      final manager = GoogleHealthIrregularRhythmNotificationDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      await manager.fetch(
        GoogleHealthIrregularRhythmNotificationAPIURL.day(
          date: DateTime(2025, 5, 31),
        ),
      );
      expect(capturedAuth, 'Bearer valid_token');
    });
  });
}
