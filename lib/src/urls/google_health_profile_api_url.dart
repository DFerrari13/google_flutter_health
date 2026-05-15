import 'google_health_api_url.dart';

class GoogleHealthProfileAPIURL extends GoogleHealthAPIURL {
  GoogleHealthProfileAPIURL._({required super.uri});

  static final GoogleHealthProfileAPIURL profile = GoogleHealthProfileAPIURL._(
    uri: Uri.https('health.googleapis.com', '/v4/users/me/profile'),
  );

  static final GoogleHealthProfileAPIURL settings = GoogleHealthProfileAPIURL._(
    uri: Uri.https('health.googleapis.com', '/v4/users/me/settings'),
  );
}
