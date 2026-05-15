import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthProfileDataManager', () {
    late GoogleHealthCredentials credentials;
    late GoogleHealthCredentials expiredCredentials;

    setUp(() {
      credentials = GoogleHealthCredentials(
        accessToken: 'valid_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.profileReadonly],
      );

      expiredCredentials = GoogleHealthCredentials(
        accessToken: 'expired_token',
        refreshToken: 'refresh_token',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().subtract(const Duration(hours: 1)),
        userID: 'user_123',
        scopes: [GoogleHealthScopes.profileReadonly],
      );
    });

    test('fetch() calls both endpoints and merges results', () async {
      final profileBody = jsonEncode({
        'userId': 'user_123',
        'displayName': 'John Doe',
        'givenName': 'John',
        'familyName': 'Doe',
        'birthdate': '1990-01-15',
        'sex': 'MALE',
      });
      final settingsBody = jsonEncode({
        'heightCm': 175.0,
        'weightKg': 70.5,
        'locale': 'en_US',
        'timezone': 'America/New_York',
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
      expect(result.data.first.userId, 'user_123');
      expect(result.data.first.displayName, 'John Doe');
      expect(result.data.first.heightCm, 175.0);
      expect(result.data.first.locale, 'en_US');
      expect(result.credentials.accessToken, credentials.accessToken);
    });

    test('fetch() refreshes token when isExpired is true', () async {
      final newTokenBody = jsonEncode({
        'access_token': 'new_access_token',
        'expires_in': 3600,
        'token_type': 'Bearer',
      });
      final profileBody = jsonEncode({'userId': 'user_123'});
      final settingsBody = jsonEncode({'locale': 'en_US'});

      final client = MockClient((request) async {
        if (request.url.host == 'oauth2.googleapis.com') {
          return http.Response(newTokenBody, 200);
        }
        if (request.url.path == '/v4/users/me/profile') {
          return http.Response(profileBody, 200);
        }
        if (request.url.path == '/v4/users/me/settings') {
          return http.Response(settingsBody, 200);
        }
        return http.Response('Not found', 404);
      });

      final manager = GoogleHealthProfileDataManager(
        credentials: expiredCredentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      final result = await manager.fetch(GoogleHealthProfileAPIURL.profile);

      expect(result.credentials.accessToken, 'new_access_token');
    });

    test('fetch() throws GoogleHealthTokenExpiredException on 401', () async {
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

    test('fetch() throws GoogleHealthRateLimitException on 429', () async {
      final client = MockClient((request) async {
        return http.Response('Rate limit exceeded', 429);
      });

      final manager = GoogleHealthProfileDataManager(
        credentials: credentials,
        clientID: 'client_id',
        clientSecret: 'client_secret',
        httpClient: client,
      );

      expect(
        () => manager.fetch(GoogleHealthProfileAPIURL.profile),
        throwsA(isA<GoogleHealthRateLimitException>()),
      );
    });
  });
}
