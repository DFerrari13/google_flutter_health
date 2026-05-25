import '_parsing_helpers.dart';

String? _parseMembershipDate(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    final y = value['year'];
    final m = value['month'];
    final d = value['day'];
    if (y != null && m != null && d != null) {
      return '${y.toString().padLeft(4, '0')}-'
          '${m.toString().padLeft(2, '0')}-'
          '${d.toString().padLeft(2, '0')}';
    }
  }
  return null;
}

/// The authenticated user's Google Health profile and settings.
///
/// Combines fields from the `users/me/profile` and `users/me/settings`
/// endpoints. The Google Health API only exposes a narrow set of
/// profile fields (age, membership start date, stride lengths) and a unit-
/// preference set in settings (distance, weight, temperature, etc.). For
/// richer demographic data (display name, profile photo) use the Google
/// account profile from your sign-in library.
class GoogleHealthProfileData {
  /// Profile resource name (`users/me/profile`).
  final String? profileName;

  /// User's age in completed years.
  final int? age;

  /// Date the user joined Google Health, formatted as an ISO 8601 date
  /// (`YYYY-MM-DD`).
  final String? membershipStartDate;

  /// User-configured walking stride length in millimetres.
  final int? userConfiguredWalkingStrideLengthMm;

  /// User-configured running stride length in millimetres.
  final int? userConfiguredRunningStrideLengthMm;

  /// Automatically-derived walking stride length in millimetres (output only).
  final int? autoWalkingStrideLengthMm;

  /// Automatically-derived running stride length in millimetres (output only).
  final int? autoRunningStrideLengthMm;

  /// Settings resource name (`users/me/settings`).
  final String? settingsName;

  /// Whether automatic stride-length detection is enabled.
  final bool? autoStrideEnabled;

  /// Distance unit preference: `MILES` or `KILOMETERS`.
  final String? distanceUnit;

  /// Glucose unit preference: `MG_DL` or `MMOL_L`.
  final String? glucoseUnit;

  /// Height unit preference: `INCHES` or `CENTIMETERS`.
  final String? heightUnit;

  /// User locale (e.g. `en-US`).
  final String? languageLocale;

  /// UTC offset as a duration string (e.g. `-28800s`).
  final String? utcOffset;

  /// IANA time zone identifier (e.g. `America/New_York`).
  final String? timeZone;

  /// Preferred stride-length source for walking
  /// (`USER_CONFIGURED` or `AUTOMATIC`).
  final String? strideLengthWalkingType;

  /// Preferred stride-length source for running.
  final String? strideLengthRunningType;

  /// Swim distance unit preference: `METERS` or `YARDS`.
  final String? swimUnit;

  /// Temperature unit preference: `CELSIUS` or `FAHRENHEIT`.
  final String? temperatureUnit;

  /// Weight unit preference: `POUNDS`, `STONE`, or `KILOGRAMS`.
  final String? weightUnit;

  /// Water unit preference: `ML`, `FL_OZ`, or `CUP`.
  final String? waterUnit;

  const GoogleHealthProfileData({
    this.profileName,
    this.age,
    this.membershipStartDate,
    this.userConfiguredWalkingStrideLengthMm,
    this.userConfiguredRunningStrideLengthMm,
    this.autoWalkingStrideLengthMm,
    this.autoRunningStrideLengthMm,
    this.settingsName,
    this.autoStrideEnabled,
    this.distanceUnit,
    this.glucoseUnit,
    this.heightUnit,
    this.languageLocale,
    this.utcOffset,
    this.timeZone,
    this.strideLengthWalkingType,
    this.strideLengthRunningType,
    this.swimUnit,
    this.temperatureUnit,
    this.weightUnit,
    this.waterUnit,
  });

  /// Creates a [GoogleHealthProfileData] from a merged profile + settings map.
  factory GoogleHealthProfileData.fromMerged({
    required Map<String, dynamic> profile,
    required Map<String, dynamic> settings,
  }) {
    return GoogleHealthProfileData(
      profileName: profile['name'] as String?,
      age: parseInt64(profile['age']),
      membershipStartDate: _parseMembershipDate(profile['membershipStartDate']),
      userConfiguredWalkingStrideLengthMm:
          parseInt64(profile['userConfiguredWalkingStrideLengthMm']),
      userConfiguredRunningStrideLengthMm:
          parseInt64(profile['userConfiguredRunningStrideLengthMm']),
      autoWalkingStrideLengthMm:
          parseInt64(profile['autoWalkingStrideLengthMm']),
      autoRunningStrideLengthMm:
          parseInt64(profile['autoRunningStrideLengthMm']),
      settingsName: settings['name'] as String?,
      autoStrideEnabled: settings['autoStrideEnabled'] as bool?,
      distanceUnit: settings['distanceUnit'] as String?,
      glucoseUnit: settings['glucoseUnit'] as String?,
      heightUnit: settings['heightUnit'] as String?,
      languageLocale: settings['languageLocale'] as String?,
      utcOffset: settings['utcOffset'] as String?,
      timeZone: settings['timeZone'] as String?,
      strideLengthWalkingType: settings['strideLengthWalkingType'] as String?,
      strideLengthRunningType: settings['strideLengthRunningType'] as String?,
      swimUnit: settings['swimUnit'] as String?,
      temperatureUnit: settings['temperatureUnit'] as String?,
      weightUnit: settings['weightUnit'] as String?,
      waterUnit: settings['waterUnit'] as String?,
    );
  }

  /// Convenience for restoring a previously-serialised profile.
  factory GoogleHealthProfileData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthProfileData(
      profileName: json['profileName'] as String?,
      age: parseInt64(json['age']),
      membershipStartDate: json['membershipStartDate'] as String?,
      userConfiguredWalkingStrideLengthMm:
          parseInt64(json['userConfiguredWalkingStrideLengthMm']),
      userConfiguredRunningStrideLengthMm:
          parseInt64(json['userConfiguredRunningStrideLengthMm']),
      autoWalkingStrideLengthMm: parseInt64(json['autoWalkingStrideLengthMm']),
      autoRunningStrideLengthMm: parseInt64(json['autoRunningStrideLengthMm']),
      settingsName: json['settingsName'] as String?,
      autoStrideEnabled: json['autoStrideEnabled'] as bool?,
      distanceUnit: json['distanceUnit'] as String?,
      glucoseUnit: json['glucoseUnit'] as String?,
      heightUnit: json['heightUnit'] as String?,
      languageLocale: json['languageLocale'] as String?,
      utcOffset: json['utcOffset'] as String?,
      timeZone: json['timeZone'] as String?,
      strideLengthWalkingType: json['strideLengthWalkingType'] as String?,
      strideLengthRunningType: json['strideLengthRunningType'] as String?,
      swimUnit: json['swimUnit'] as String?,
      temperatureUnit: json['temperatureUnit'] as String?,
      weightUnit: json['weightUnit'] as String?,
      waterUnit: json['waterUnit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'profileName': profileName,
        'age': age,
        'membershipStartDate': membershipStartDate,
        'userConfiguredWalkingStrideLengthMm':
            userConfiguredWalkingStrideLengthMm,
        'userConfiguredRunningStrideLengthMm':
            userConfiguredRunningStrideLengthMm,
        'autoWalkingStrideLengthMm': autoWalkingStrideLengthMm,
        'autoRunningStrideLengthMm': autoRunningStrideLengthMm,
        'settingsName': settingsName,
        'autoStrideEnabled': autoStrideEnabled,
        'distanceUnit': distanceUnit,
        'glucoseUnit': glucoseUnit,
        'heightUnit': heightUnit,
        'languageLocale': languageLocale,
        'utcOffset': utcOffset,
        'timeZone': timeZone,
        'strideLengthWalkingType': strideLengthWalkingType,
        'strideLengthRunningType': strideLengthRunningType,
        'swimUnit': swimUnit,
        'temperatureUnit': temperatureUnit,
        'weightUnit': weightUnit,
        'waterUnit': waterUnit,
      };

  @override
  String toString() => 'GoogleHealthProfileData('
      'age: $age, membershipStartDate: $membershipStartDate, '
      'distanceUnit: $distanceUnit, weightUnit: $weightUnit, '
      'temperatureUnit: $temperatureUnit, timeZone: $timeZone)';
}
