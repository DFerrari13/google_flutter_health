import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthCredentials', () {
    test('isExpired returns false for a token that expires in 1 hour', () {
      final creds = GoogleHealthCredentials(
        accessToken: 'a',
        refreshToken: 'r',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(hours: 1)),
        userID: 'u',
        scopes: const [GoogleHealthScopes.activityAndFitnessReadonly],
      );
      expect(creds.isExpired, isFalse);
    });

    test('isExpired returns true within the 60-second buffer', () {
      final creds = GoogleHealthCredentials(
        accessToken: 'a',
        refreshToken: 'r',
        accessTokenExpirationDateTime:
            DateTime.now().toUtc().add(const Duration(seconds: 30)),
        userID: 'u',
        scopes: const [GoogleHealthScopes.activityAndFitnessReadonly],
      );
      expect(creds.isExpired, isTrue);
    });

    test('toJson / fromJson roundtrip', () {
      final creds = GoogleHealthCredentials(
        accessToken: 'abc',
        refreshToken: 'def',
        accessTokenExpirationDateTime: DateTime.utc(2026, 1, 15, 12),
        userID: 'user_123',
        scopes: const [
          GoogleHealthScopes.activityAndFitnessReadonly,
          GoogleHealthScopes.sleepReadonly,
        ],
      );
      final restored = GoogleHealthCredentials.fromJson(creds.toJson());
      expect(restored.accessToken, 'abc');
      expect(restored.refreshToken, 'def');
      expect(
        restored.accessTokenExpirationDateTime,
        DateTime.utc(2026, 1, 15, 12),
      );
      expect(restored.userID, 'user_123');
      expect(restored.scopes, hasLength(2));
    });
  });
}
