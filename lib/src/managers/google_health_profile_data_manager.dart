import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;

import '../connectors/google_health_credentials.dart';
import '../data/google_health_profile_data.dart';
import '../exceptions/google_health_exceptions.dart';
import '../urls/google_health_api_url.dart';
import '../urls/google_health_profile_api_url.dart';
import 'google_health_data_manager.dart';

/// Fetches the authenticated user's Google Health profile and settings.
///
/// Requires the `googlehealth.profile.readonly` and
/// `googlehealth.settings.readonly` scopes.
///
/// Makes two API calls internally — one to `users/me/profile` and one to
/// `users/me/settings` — and merges the responses into a single
/// [GoogleHealthProfileData] instance. The [url] parameter passed to [fetch]
/// is accepted for interface consistency but ignored.
class GoogleHealthProfileDataManager
    extends GoogleHealthDataManager<GoogleHealthProfileData> {
  GoogleHealthProfileDataManager({
    required super.credentials,
    required super.clientID,
    required super.clientSecret,
    super.httpClient,
  });

  /// Overrides the base [fetch] because the profile endpoint requires two
  /// HTTP calls that are merged into a single data object.
  @override
  Future<
      ({
        List<GoogleHealthProfileData> data,
        GoogleHealthCredentials credentials,
      })> fetch(GoogleHealthAPIURL url) async {
    final creds = await refreshIfNeeded(credentials);
    final headers = {'Authorization': 'Bearer ${creds.accessToken}'};

    final profileResponse = await httpClient.get(
      GoogleHealthProfileAPIURL.profile.uri,
      headers: headers,
    );
    checkResponse(profileResponse);
    if (kDebugMode) {
      debugPrint('[GoogleHealth] profile → ${profileResponse.body}');
    }

    final settingsResponse = await httpClient.get(
      GoogleHealthProfileAPIURL.settings.uri,
      headers: headers,
    );
    checkResponse(settingsResponse);
    if (kDebugMode) {
      debugPrint('[GoogleHealth] settings → ${settingsResponse.body}');
    }

    final profileJson = _decode(profileResponse);
    final settingsJson = _decode(settingsResponse);
    final data = GoogleHealthProfileData.fromMerged(
      profile: profileJson,
      settings: settingsJson,
    );
    return (data: [data], credentials: creds);
  }

  @override
  List<GoogleHealthProfileData> parseDataPoints(Map<String, dynamic> json) =>
      const [];

  Map<String, dynamic> _decode(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw GoogleHealthDataException(
        'Failed to decode profile/settings response: $e',
      );
    }
  }
}
