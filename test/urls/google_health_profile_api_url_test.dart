import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthProfileAPIURL', () {
    test('profile URL is correct', () {
      expect(
        GoogleHealthProfileAPIURL.profile.uri.toString(),
        'https://health.googleapis.com/v4/users/me/profile',
      );
    });

    test('settings URL is correct', () {
      expect(
        GoogleHealthProfileAPIURL.settings.uri.toString(),
        'https://health.googleapis.com/v4/users/me/settings',
      );
    });
  });
}
