/// OAuth 2.0 scope URL constants for the Google Health API.
///
/// Pass a subset of these constants to [GoogleHealthConnector.authorize]
/// to request the permissions your app needs. Request only the scopes
/// your app actually uses — the user sees a consent screen listing them.
///
/// ```dart
/// final credentials = await GoogleHealthConnector.authorize(
///   clientID: 'YOUR_CLIENT_ID',
///   clientSecret: 'YOUR_CLIENT_SECRET',
///   redirectUri: 'com.example.app:/oauth2redirect',
///   scopes: [
///     GoogleHealthScopes.activityAndFitnessReadonly,
///     GoogleHealthScopes.sleepReadonly,
///   ],
/// );
/// ```
class GoogleHealthScopes {
  GoogleHealthScopes._();

  /// Read and write access to activity and fitness data (steps, distance, calories, etc.).
  static const String activityAndFitness =
      'https://www.googleapis.com/auth/googlehealth.activity_and_fitness';

  /// Read-only access to activity and fitness data (steps, distance, calories, etc.).
  ///
  /// Prefer this over [activityAndFitness] unless you need write access.
  static const String activityAndFitnessReadonly =
      'https://www.googleapis.com/auth/googlehealth.activity_and_fitness.readonly';

  /// Read and write access to health metrics (heart rate, weight, oxygen saturation, HRV, etc.).
  static const String healthMetrics =
      'https://www.googleapis.com/auth/googlehealth.health_metrics_and_measurements';

  /// Read-only access to health metrics (heart rate, weight, oxygen saturation, HRV, etc.).
  ///
  /// Prefer this over [healthMetrics] unless you need write access.
  static const String healthMetricsReadonly =
      'https://www.googleapis.com/auth/googlehealth.health_metrics_and_measurements.readonly';

  /// Read and write access to sleep data.
  static const String sleep =
      'https://www.googleapis.com/auth/googlehealth.sleep';

  /// Read-only access to sleep data.
  ///
  /// Prefer this over [sleep] unless you need write access.
  static const String sleepReadonly =
      'https://www.googleapis.com/auth/googlehealth.sleep.readonly';

  /// Read and write access to the user's Google Health profile.
  static const String profile =
      'https://www.googleapis.com/auth/googlehealth.profile';

  /// Read-only access to the user's Google Health profile.
  ///
  /// Prefer this over [profile] unless you need write access.
  static const String profileReadonly =
      'https://www.googleapis.com/auth/googlehealth.profile.readonly';

  /// Read-only access to location data.
  static const String locationReadonly =
      'https://www.googleapis.com/auth/googlehealth.location.readonly';

  /// Read-only access to nutrition data.
  static const String nutritionReadonly =
      'https://www.googleapis.com/auth/googlehealth.nutrition.readonly';
}
