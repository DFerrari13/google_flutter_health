import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthProfileData', () {
    test('fromMerged combines profile and settings responses', () {
      final data = GoogleHealthProfileData.fromMerged(
        profile: <String, dynamic>{
          'name': 'users/me/profile',
          'age': '32',
          'membershipStartDate': '2022-04-01',
          'userConfiguredWalkingStrideLengthMm': 740,
          'autoRunningStrideLengthMm': 1180,
        },
        settings: <String, dynamic>{
          'name': 'users/me/settings',
          'autoStrideEnabled': true,
          'distanceUnit': 'KILOMETERS',
          'weightUnit': 'KILOGRAMS',
          'temperatureUnit': 'CELSIUS',
          'timeZone': 'America/New_York',
          'languageLocale': 'en-US',
        },
      );
      expect(data.profileName, 'users/me/profile');
      expect(data.age, 32);
      expect(data.membershipStartDate, '2022-04-01');
      expect(data.userConfiguredWalkingStrideLengthMm, 740);
      expect(data.autoRunningStrideLengthMm, 1180);
      expect(data.settingsName, 'users/me/settings');
      expect(data.autoStrideEnabled, isTrue);
      expect(data.distanceUnit, 'KILOMETERS');
      expect(data.weightUnit, 'KILOGRAMS');
      expect(data.temperatureUnit, 'CELSIUS');
      expect(data.timeZone, 'America/New_York');
      expect(data.languageLocale, 'en-US');
    });

    test('fromJson/toJson roundtrip preserves all fields', () {
      const data = GoogleHealthProfileData(
        age: 40,
        membershipStartDate: '2020-01-01',
        distanceUnit: 'MILES',
        weightUnit: 'POUNDS',
        timeZone: 'UTC',
      );
      final json = data.toJson();
      final restored = GoogleHealthProfileData.fromJson(json);
      expect(restored.age, 40);
      expect(restored.membershipStartDate, '2020-01-01');
      expect(restored.distanceUnit, 'MILES');
      expect(restored.weightUnit, 'POUNDS');
      expect(restored.timeZone, 'UTC');
    });

    test('handles missing fields gracefully', () {
      final data = GoogleHealthProfileData.fromMerged(
        profile: const <String, dynamic>{},
        settings: const <String, dynamic>{},
      );
      expect(data.age, isNull);
      expect(data.distanceUnit, isNull);
    });
  });
}
