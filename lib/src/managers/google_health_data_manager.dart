import 'dart:convert';

import 'package:http/http.dart' as http;

import '../connectors/google_health_credentials.dart';
import '../exceptions/google_health_exceptions.dart';
import '../urls/google_health_api_url.dart';

abstract class GoogleHealthDataManager<T> {
  final GoogleHealthCredentials credentials;
  final String clientID;
  final String clientSecret;
  final http.Client httpClient;

  GoogleHealthDataManager({
    required this.credentials,
    required this.clientID,
    required this.clientSecret,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  Future<({List<T> data, GoogleHealthCredentials credentials})> fetch(
    GoogleHealthAPIURL url,
  );

  Future<GoogleHealthCredentials> refreshIfNeeded(
    GoogleHealthCredentials creds,
  ) async {
    if (!creds.isExpired) return creds;
    final response = await httpClient.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': creds.refreshToken,
        'client_id': clientID,
        'client_secret': clientSecret,
      },
    );
    if (response.statusCode != 200) {
      throw const GoogleHealthTokenExpiredException(
        'Access token expired and refresh failed.',
      );
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return GoogleHealthCredentials(
      accessToken: json['access_token'] as String,
      refreshToken: creds.refreshToken,
      accessTokenExpirationDateTime: DateTime.now().toUtc().add(
            Duration(seconds: (json['expires_in'] as num).toInt()),
          ),
      userID: creds.userID,
      scopes: creds.scopes,
    );
  }
}
