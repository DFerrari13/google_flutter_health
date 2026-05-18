import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GoogleHealthProfileDataManager', () {
    late GoogleHealthCredentials credentials;

    setUp(() {
      credentials = GoogleHealthCredentials(
        accessToken: 'valid_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [
          GoogleHealthScopes.profileReadonly,
          GoogleHealthScopes.settingsReadonly,
        ],
      );
    });

    test('fetch() calls both endpoints and merges results', () async {
      final profileBody = jsonEncode({
        'name': 'users/me/profile',
        'age': '32',
        'membershipStartDate': '2022-04-01',
      });
      final settingsBody = jsonEncode({
        'name': 'users/me/settings',
        'distanceUnit': 'KILOMETERS',
        'weightUnit': 'KILOGRAMS',
        'timeZone': 'America/New_York',
        'languageLocale': 'en-US',
      });

      var profileCalled = false;
      var settingsCalled = false;
      final client = MockClient((request) async {
        if (request.url.path == '/v4/users/me/profile') {
          profileCalled = true;
          return http.Response(profileBody, 200);
        }
        if (request.url.path == '/v4/users/me/settings') {
          settingsCalled = true;
          return http.Response(settingsBody, 200);
        }
        return http.Response('Not found', 404);
      });

      final manager = GoogleHealthProfileDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(GoogleHealthProfileAPIURL.profile);
      expect(profileCalled, isTrue);
      expect(settingsCalled, isTrue);
      expect(result.data, hasLength(1));
      expect(result.data.first.age, 32);
      expect(result.data.first.distanceUnit, 'KILOMETERS');
      expect(result.data.first.timeZone, 'America/New_York');
    });

    test('fetch() throws on 401', () async {
      final client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });
      final manager = GoogleHealthProfileDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );
      expect(
        () => manager.fetch(GoogleHealthProfileAPIURL.profile),
        throwsA(isA<GoogleHealthTokenExpiredException>()),
      );
    });
  });
}
