/// Base class for all exceptions thrown by the `google_flutter_health` package.
///
/// Catch this type to handle any library error in a single `catch` block, or
/// catch a specific subclass to handle individual failure modes.
sealed class GoogleHealthException implements Exception {
  /// Human-readable description of what went wrong.
  final String message;

  const GoogleHealthException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when OAuth 2.0 authorization fails or is cancelled by the user.
///
/// This exception is raised by [GoogleHealthConnector.authorize] if the
/// authorization server returns an error or the user denies consent.
final class GoogleHealthAuthException extends GoogleHealthException {
  const GoogleHealthAuthException(super.message);
}

/// Thrown when the access token has expired and the refresh attempt failed.
///
/// This can happen when the refresh token has been revoked (e.g. the user
/// revoked access in their Google account settings) or has expired after
/// 6 months of inactivity. Prompt the user to re-authorise.
final class GoogleHealthTokenExpiredException extends GoogleHealthException {
  const GoogleHealthTokenExpiredException(super.message);
}

/// Thrown on HTTP 429 (Too Many Requests) — back off and retry.
///
/// The optional [retryAfter] field indicates how long to wait before
/// retrying, if the API included a `Retry-After` header.
final class GoogleHealthRateLimitException extends GoogleHealthException {
  /// Suggested wait duration before retrying, if provided by the API.
  final Duration? retryAfter;

  const GoogleHealthRateLimitException(super.message, {this.retryAfter});
}

/// Thrown when the API returns an error for a specific data type request.
///
/// Covers HTTP 4xx/5xx responses that are not 401 or 429, for example
/// when the requested data type is not available for the user's device.
final class GoogleHealthDataTypeException extends GoogleHealthException {
  const GoogleHealthDataTypeException(super.message);
}

/// Thrown on network failure such as no connectivity or a request timeout.
///
/// Wrap your fetch calls in a try/catch for this exception to handle
/// offline scenarios gracefully.
final class GoogleHealthNetworkException extends GoogleHealthException {
  const GoogleHealthNetworkException(super.message);
}

/// Thrown when JSON parsing fails or a required API response field is missing.
///
/// If you see this exception, the Google Health API may have changed its
/// response schema. Please open an issue on the repository.
final class GoogleHealthDataException extends GoogleHealthException {
  const GoogleHealthDataException(super.message);
}
