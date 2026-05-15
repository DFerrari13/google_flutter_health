/// The authenticated user's Google Health profile and settings.
///
/// Combines data from the `users.me.profile` and `users.me.settings`
/// endpoints. All fields are nullable because the API may not have data
/// for a given user.
class GoogleHealthProfileData {
  /// The Google Health user ID.
  final String? userId;

  /// The user's full display name.
  final String? displayName;

  /// The user's given (first) name.
  final String? givenName;

  /// The user's family (last) name.
  final String? familyName;

  /// The user's date of birth as an ISO 8601 date string (`YYYY-MM-DD`).
  final String? birthdate;

  /// The user's height in centimetres.
  final double? heightCm;

  /// The user's weight in kilograms.
  final double? weightKg;

  /// The user's biological sex.
  ///
  /// Typical API values: `"male"`, `"female"`, `"unspecified"`.
  final String? sex;

  /// The user's preferred locale (e.g. `"en-US"`).
  final String? locale;

  /// The user's configured time zone (e.g. `"America/New_York"`).
  final String? timezone;

  const GoogleHealthProfileData({
    this.userId,
    this.displayName,
    this.givenName,
    this.familyName,
    this.birthdate,
    this.heightCm,
    this.weightKg,
    this.sex,
    this.locale,
    this.timezone,
  });

  /// Creates a [GoogleHealthProfileData] from a merged profile + settings JSON map.
  factory GoogleHealthProfileData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthProfileData(
      userId: json['userId'] as String?,
      displayName: json['displayName'] as String?,
      givenName: json['givenName'] as String?,
      familyName: json['familyName'] as String?,
      birthdate: json['birthdate'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      sex: json['sex'] as String?,
      locale: json['locale'] as String?,
      timezone: json['timezone'] as String?,
    );
  }

  /// Serialises this profile to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'givenName': givenName,
        'familyName': familyName,
        'birthdate': birthdate,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'sex': sex,
        'locale': locale,
        'timezone': timezone,
      };

  @override
  String toString() =>
      'GoogleHealthProfileData(userId: $userId, displayName: $displayName, '
      'givenName: $givenName, familyName: $familyName, birthdate: $birthdate, '
      'heightCm: $heightCm, weightKg: $weightKg, sex: $sex, '
      'locale: $locale, timezone: $timezone)';
}
