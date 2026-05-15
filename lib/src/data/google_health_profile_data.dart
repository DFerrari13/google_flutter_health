class GoogleHealthProfileData {
  final String? userId;
  final String? displayName;
  final String? givenName;
  final String? familyName;
  final String? birthdate;
  final double? heightCm;
  final double? weightKg;
  final String? sex;
  final String? locale;
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
