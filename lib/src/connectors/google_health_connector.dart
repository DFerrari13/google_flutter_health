import 'dart:convert';

import 'package:http/http.dart' as http;

import 'google_health_credentials.dart';

class GoogleHealthConnector {
  GoogleHealthConnector._();

  static Future<GoogleHealthCredentials?> authorize({
    required String clientID,
    required String clientSecret,
    required String redirectUri,
    required List<String> scopes,
  }) async {
    throw UnimplementedError('authorize() requires platform-specific setup');
  }

  static Future<GoogleHealthCredentials?> refreshToken({
    required GoogleHealthCredentials credentials,
    required String clientID,
    required String clientSecret,
  }) async {
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': credentials.refreshToken,
        'client_id': clientID,
        'client_secret': clientSecret,
      },
    );
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GoogleHealthCredentials(
      accessToken: json['access_token'] as String,
      refreshToken: credentials.refreshToken,
      accessTokenExpirationDateTime: DateTime.now().toUtc().add(
            Duration(seconds: (json['expires_in'] as num).toInt()),
          ),
      userID: credentials.userID,
      scopes: credentials.scopes,
    );
  }

  static Future<String?> getUserId({
    required GoogleHealthCredentials credentials,
  }) async {
    final response = await http.get(
      Uri.https('health.googleapis.com', '/v4/users/me:getIdentity'),
      headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
    );
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['userId'] as String?;
  }

  static Future<bool> unauthorize({
    required GoogleHealthCredentials credentials,
  }) async {
    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/revoke'),
      body: {'token': credentials.accessToken},
    );
    return response.statusCode == 200;
  }
}
