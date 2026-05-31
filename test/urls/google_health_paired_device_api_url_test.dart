import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthPairedDeviceAPIURL', () {
    test('list points to correct endpoint', () {
      final url = GoogleHealthPairedDeviceAPIURL.list;
      expect(url.uri.host, 'health.googleapis.com');
      expect(url.uri.path, '/v4/users/me/pairedDevices');
      expect(url.method, GoogleHealthRequestMethod.get);
    });

    test('get() encodes resource name in path', () {
      const name = 'users/me/pairedDevices/abc123';
      final url = GoogleHealthPairedDeviceAPIURL.get(name);
      expect(url.uri.host, 'health.googleapis.com');
      expect(url.uri.path, '/v4/users/me/pairedDevices/abc123');
      expect(url.method, GoogleHealthRequestMethod.get);
    });

    test('list has no query parameters', () {
      expect(GoogleHealthPairedDeviceAPIURL.list.uri.queryParameters, isEmpty);
    });

    test('get() has no query parameters', () {
      final url = GoogleHealthPairedDeviceAPIURL.get(
        'users/me/pairedDevices/xyz',
      );
      expect(url.uri.queryParameters, isEmpty);
    });
  });
}
