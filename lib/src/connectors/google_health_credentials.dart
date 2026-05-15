/// Holds the OAuth 2.0 credentials for a Google Health API session.
///
/// Credentials are **never stored by the library** — you are responsible for
/// persisting and restoring them (e.g. using `flutter_secure_storage`).
/// Use [toJson] to serialise and [fromJson] to restore them.
///
/// Every `DataManager.fetch()` call checks [isExpired] and transparently
/// refreshes the token when needed, returning updated credentials alongside
/// the fetched data.
class GoogleHealthCredentials {
  /// The OAuth 2.0 Bearer token used in API request headers.
  final String accessToken;

  /// The long-lived token used to obtain new access tokens.
  ///
  /// Expires after 6 months of non-use. If refresh fails, the user must
  /// re-authorise via [GoogleHealthConnector.authorize].
  final String refreshToken;

  /// The UTC [DateTime] at which [accessToken] expires.
  ///
  /// Google access tokens last 1 hour. [isExpired] uses this value with a
  /// 60-second buffer to trigger proactive refresh.
  final DateTime accessTokenExpirationDateTime;

  /// The Google Health user ID for the authenticated user.
  ///
  /// Obtained by calling [GoogleHealthConnector.getUserId] after the initial
  /// authorization. Required for user-scoped API requests.
  final String userID;

  /// The list of OAuth 2.0 scopes granted during authorization.
  ///
  /// Use constants from [GoogleHealthScopes] when calling
  /// [GoogleHealthConnector.authorize].
  final List<String> scopes;

  /// Creates a [GoogleHealthCredentials] instance.
  ///
  /// All fields are required. Use [fromJson] to restore persisted credentials.
  const GoogleHealthCredentials({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpirationDateTime,
    required this.userID,
    required this.scopes,
  });

  /// Returns `true` if the access token has expired or expires within 60 seconds.
  ///
  /// The 60-second buffer prevents API errors caused by tokens that expire
  /// mid-request. Data managers call this before every fetch and refresh
  /// automatically when it returns `true`.
  bool get isExpired => DateTime.now().toUtc().isAfter(
        accessTokenExpirationDateTime.subtract(const Duration(seconds: 60)),
      );

  /// Creates [GoogleHealthCredentials] from a JSON map.
  ///
  /// Use this to restore credentials previously serialised with [toJson].
  ///
  /// Throws a [TypeError] if any required field is missing or has the wrong type.
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

  /// Serialises these credentials to a JSON-compatible map.
  ///
  /// Store the result with `flutter_secure_storage` or another secure store
  /// and restore it later with [fromJson].
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
