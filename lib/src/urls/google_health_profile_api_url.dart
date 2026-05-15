import 'google_health_api_url.dart';

/// URL builder for the Google Health profile and settings endpoints.
///
/// Unlike other URL builders, [GoogleHealthProfileAPIURL] exposes static
/// instances rather than factory constructors, because the profile and
/// settings endpoints have no query parameters.
///
/// Pass [profile] or [settings] to [GoogleHealthProfileDataManager.fetch].
///
/// Requires the [GoogleHealthScopes.profileReadonly] scope.
class GoogleHealthProfileAPIURL extends GoogleHealthAPIURL {
  GoogleHealthProfileAPIURL._({required super.uri});

  /// URL for the `users.me.profile` endpoint.
  ///
  /// Returns demographic information such as display name, birthdate, height,
  /// weight, and biological sex.
  static final GoogleHealthProfileAPIURL profile = GoogleHealthProfileAPIURL._(
    uri: Uri.https('health.googleapis.com', '/v4/users/me/profile'),
  );

  /// URL for the `users.me.settings` endpoint.
  ///
  /// Returns locale and timezone preferences for the authenticated user.
  static final GoogleHealthProfileAPIURL settings = GoogleHealthProfileAPIURL._(
    uri: Uri.https('health.googleapis.com', '/v4/users/me/settings'),
  );
}
