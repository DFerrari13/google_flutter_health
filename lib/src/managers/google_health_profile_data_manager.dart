import 'dart:convert';

import 'package:http/http.dart' as http;

import '../connectors/google_health_credentials.dart';
import '../data/google_health_profile_data.dart';
import '../exceptions/google_health_exceptions.dart';
import '../urls/google_health_api_url.dart';
import '../urls/google_health_profile_api_url.dart';
import 'google_health_data_manager.dart';

class GoogleHealthProfileDataManager
    extends GoogleHealthDataManager<GoogleHealthProfileData> {
  GoogleHealthProfileDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  @override
  Future<
      ({
        List<GoogleHealthProfileData> data,
        GoogleHealthCredentials credentials
      })> fetch(
    GoogleHealthAPIURL url,
  ) async {
    var creds = credentials;
    creds = await refreshIfNeeded(creds);

    final headers = {'Authorization': 'Bearer ${creds.accessToken}'};

    final profileResponse = await httpClient.get(
      GoogleHealthProfileAPIURL.profile.uri,
      headers: headers,
    );
    _checkResponse(profileResponse);

    final settingsResponse = await httpClient.get(
      GoogleHealthProfileAPIURL.settings.uri,
      headers: headers,
    );
    _checkResponse(settingsResponse);

    final profileJson =
        jsonDecode(profileResponse.body) as Map<String, dynamic>;
    final settingsJson =
        jsonDecode(settingsResponse.body) as Map<String, dynamic>;

    final merged = {...profileJson, ...settingsJson};
    final data = GoogleHealthProfileData.fromJson(merged);

    return (data: [data], credentials: creds);
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw const GoogleHealthTokenExpiredException(
        'Unauthorized: access token rejected by the API.',
      );
    }
    if (response.statusCode == 429) {
      throw const GoogleHealthRateLimitException(
        'Rate limit exceeded.',
      );
    }
    if (response.statusCode != 200) {
      throw GoogleHealthDataTypeException(
        'API error: ${response.statusCode}',
      );
    }
  }
}
