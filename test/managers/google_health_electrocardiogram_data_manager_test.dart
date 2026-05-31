import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthElectrocardiogramDataManager', () {
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
            'name': 'users/me/dataTypes/electrocardiogram/dataPoints/abc',
            'electrocardiogram': {
              'interval': {
                'startTime': '2025-05-31T10:00:00Z',
                'endTime': '2025-05-31T10:00:00Z',
              },
              'resultClassification': 'NORMAL_SINUS_RHYTHM',
              'waveformSamples': [0, 100, 200, -100],
              'medicalDeviceInfo': {
                'firmwareVersion': '4.0.2',
                'deviceModel': 'Pixel Watch 2',
              },
              'beatsPerMinuteAvg': '68',
              'samplingFrequencyHertz': 500,
              'millivoltsScalingFactor': 200,
              'leadNumber': 1,
            },
          },
        ],
      });

      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthElectrocardiogramDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthElectrocardiogramAPIURL.day(date: DateTime(2025, 5, 31)),
      );

      expect(result.data, hasLength(1));
      final ecg = result.data.first;
      expect(
        ecg.resultClassification,
        GoogleHealthEcgResultClassification.normalSinusRhythm,
      );
      expect(ecg.waveformSamples, [0, 100, 200, -100]);
      expect(ecg.waveformMillivolts, [0.0, 0.5, 1.0, -0.5]);
      expect(ecg.beatsPerMinuteAvg, 68);
      expect(ecg.samplingFrequencyHertz, 500);
      expect(ecg.leadNumber, 1);
      expect(ecg.medicalDeviceInfo!.deviceModel, 'Pixel Watch 2');
    });

    test('fetch() handles multiple readings', () async {
      final body = jsonEncode({
        'dataPoints': [
          {
            'name': 'users/me/dataTypes/electrocardiogram/dataPoints/1',
            'electrocardiogram': {
              'interval': {
                'startTime': '2025-05-30T09:00:00Z',
                'endTime': '2025-05-30T09:00:00Z',
              },
              'resultClassification': 'ATRIAL_FIBRILLATION',
              'waveformSamples': <int>[],
            },
          },
          {
            'name': 'users/me/dataTypes/electrocardiogram/dataPoints/2',
            'electrocardiogram': {
              'interval': {
                'startTime': '2025-05-31T10:00:00Z',
                'endTime': '2025-05-31T10:00:00Z',
              },
              'resultClassification': 'INCONCLUSIVE',
              'waveformSamples': <int>[],
            },
          },
        ],
      });

      final client = MockClient((_) async => http.Response(body, 200));
      final manager = GoogleHealthElectrocardiogramDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthElectrocardiogramAPIURL.dateRange(
          startDate: DateTime(2025, 5, 30),
          endDate: DateTime(2025, 5, 31),
        ),
      );

      expect(result.data, hasLength(2));
      expect(
        result.data[0].resultClassification,
        GoogleHealthEcgResultClassification.atrialFibrillation,
      );
      expect(
        result.data[1].resultClassification,
        GoogleHealthEcgResultClassification.inconclusive,
      );
    });

    test('fetch() returns empty list when dataPoints absent', () async {
      final client = MockClient(
        (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
      );
      final manager = GoogleHealthElectrocardiogramDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(
        GoogleHealthElectrocardiogramAPIURL.day(date: DateTime(2025, 5, 31)),
      );
      expect(result.data, isEmpty);
    });

    test('fetch() throws on 401', () async {
      final client = MockClient(
        (_) async => http.Response('Unauthorized', 401),
      );
      final manager = GoogleHealthElectrocardiogramDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      expect(
        () => manager.fetch(
          GoogleHealthElectrocardiogramAPIURL.day(date: DateTime(2025, 5, 31)),
        ),
        throwsA(isA<GoogleHealthTokenExpiredException>()),
      );
    });

    test('fetch() sends Authorization header', () async {
      String? capturedAuth;
      final client = MockClient((request) async {
        capturedAuth = request.headers['Authorization'];
        return http.Response(jsonEncode({'dataPoints': <dynamic>[]}), 200);
      });
      final manager = GoogleHealthElectrocardiogramDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      await manager.fetch(
        GoogleHealthElectrocardiogramAPIURL.day(date: DateTime(2025, 5, 31)),
      );
      expect(capturedAuth, 'Bearer valid_token');
    });
  });
}
