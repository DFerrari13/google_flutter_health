class GoogleHealthCredentials {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpirationDateTime;
  final String userID;
  final List<String> scopes;

  const GoogleHealthCredentials({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpirationDateTime,
    required this.userID,
    required this.scopes,
  });

  bool get isExpired => DateTime.now().toUtc().isAfter(
        accessTokenExpirationDateTime.subtract(const Duration(seconds: 60)),
      );

  factory GoogleHealthCredentials.fromJson(Map<String, dynamic> json) {
    return GoogleHealthCredentials(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpirationDateTime: DateTime.parse(
        json['accessTokenExpirationDateTime'] as String,
      ),
      userID: json['userID'] as String,
      scopes: (json['scopes'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'accessTokenExpirationDateTime':
            accessTokenExpirationDateTime.toUtc().toIso8601String(),
        'userID': userID,
        'scopes': scopes,
      };

  @override
  String toString() =>
      'GoogleHealthCredentials(userID: $userID, scopes: $scopes)';
}
