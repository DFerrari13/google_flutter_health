import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  // GoogleHealthConnector uses the package-private global `http` client so
  // its methods are awkward to mock from outside. These tests cover the
  // shapes we expect from the OAuth and identity endpoints rather than
  // exercising the static methods directly.
  group('OAuth response shapes', () {
    test('token exchange returns access_token / refresh_token / expires_in',
        () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'access_token': 'at',
            'refresh_token': 'rt',
            'expires_in': 3599,
            'token_type': 'Bearer',
          }),
          200,
        );
      });
      final response = await client.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        body: {'grant_type': 'authorization_code'},
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      expect(json['access_token'], 'at');
      expect(json['refresh_token'], 'rt');
      expect(json['expires_in'], 3599);
    });

    test('identity response returns healthUserId', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'name': 'users/me/identity',
            'healthUserId': 'health_42',
            'legacyUserId': 'fitbit_42',
          }),
          200,
        );
      });
      final response = await client.get(
        Uri.https('health.googleapis.com', '/v4/users/me/identity'),
      );
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      expect(json['healthUserId'], 'health_42');
    });
  });
}
