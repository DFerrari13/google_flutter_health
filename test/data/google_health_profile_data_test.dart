import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthProfileData', () {
    const fullJson = <String, dynamic>{
      'userId': 'user_123',
      'displayName': 'John Doe',
      'givenName': 'John',
      'familyName': 'Doe',
      'birthdate': '1990-01-15',
      'heightCm': 175.0,
      'weightKg': 70.5,
      'sex': 'MALE',
      'locale': 'en_US',
      'timezone': 'America/New_York',
    };

    test('fromJson parses all fields correctly', () {
      final data = GoogleHealthProfileData.fromJson(fullJson);
      expect(data.userId, 'user_123');
      expect(data.displayName, 'John Doe');
      expect(data.givenName, 'John');
      expect(data.familyName, 'Doe');
      expect(data.birthdate, '1990-01-15');
      expect(data.heightCm, 175.0);
      expect(data.weightKg, 70.5);
      expect(data.sex, 'MALE');
      expect(data.locale, 'en_US');
      expect(data.timezone, 'America/New_York');
    });

    test('toJson serializes correctly', () {
      final data = GoogleHealthProfileData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['userId'], 'user_123');
      expect(json['displayName'], 'John Doe');
      expect(json['givenName'], 'John');
      expect(json['familyName'], 'Doe');
      expect(json['birthdate'], '1990-01-15');
      expect(json['heightCm'], 175.0);
      expect(json['weightKg'], 70.5);
      expect(json['sex'], 'MALE');
      expect(json['locale'], 'en_US');
      expect(json['timezone'], 'America/New_York');
    });

    test('fromJson/toJson roundtrip', () {
      final original = GoogleHealthProfileData.fromJson(fullJson);
      final roundtripped = GoogleHealthProfileData.fromJson(original.toJson());
      expect(roundtripped.userId, original.userId);
      expect(roundtripped.displayName, original.displayName);
      expect(roundtripped.givenName, original.givenName);
      expect(roundtripped.familyName, original.familyName);
      expect(roundtripped.birthdate, original.birthdate);
      expect(roundtripped.heightCm, original.heightCm);
      expect(roundtripped.weightKg, original.weightKg);
      expect(roundtripped.sex, original.sex);
      expect(roundtripped.locale, original.locale);
      expect(roundtripped.timezone, original.timezone);
    });

    test('fromJson handles null fields gracefully', () {
      final data = GoogleHealthProfileData.fromJson({});
      expect(data.userId, isNull);
      expect(data.displayName, isNull);
      expect(data.givenName, isNull);
      expect(data.familyName, isNull);
      expect(data.birthdate, isNull);
      expect(data.heightCm, isNull);
      expect(data.weightKg, isNull);
      expect(data.sex, isNull);
      expect(data.locale, isNull);
      expect(data.timezone, isNull);
    });
  });
}
