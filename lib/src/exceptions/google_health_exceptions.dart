sealed class GoogleHealthException implements Exception {
  final String message;
  const GoogleHealthException(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

final class GoogleHealthAuthException extends GoogleHealthException {
  const GoogleHealthAuthException(super.message);
}

final class GoogleHealthTokenExpiredException extends GoogleHealthException {
  const GoogleHealthTokenExpiredException(super.message);
}

final class GoogleHealthRateLimitException extends GoogleHealthException {
  final Duration? retryAfter;
  const GoogleHealthRateLimitException(super.message, {this.retryAfter});
}

final class GoogleHealthDataTypeException extends GoogleHealthException {
  const GoogleHealthDataTypeException(super.message);
}

final class GoogleHealthNetworkException extends GoogleHealthException {
  const GoogleHealthNetworkException(super.message);
}

final class GoogleHealthDataException extends GoogleHealthException {
  const GoogleHealthDataException(super.message);
}
