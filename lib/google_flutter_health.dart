/// A Flutter package for the Google Health API.
///
/// Wraps the Google Health REST API in a type-safe, Dart-idiomatic interface.
/// Handles OAuth 2.0 authentication and transparent token refresh.
/// The spiritual successor to the [Fitbitter](https://pub.dev/packages/fitbitter) package.
///
/// ## Quick start
///
/// ```dart
/// // 1. Authorize
/// final credentials = await GoogleHealthConnector.authorize(
///   clientID: 'YOUR_CLIENT_ID',
///   clientSecret: 'YOUR_CLIENT_SECRET',
///   redirectUri: 'com.example.app:/oauth2redirect',
///   scopes: [GoogleHealthScopes.activityAndFitnessReadonly],
/// );
///
/// // 2. Fetch today's steps
/// final manager = GoogleHealthStepsDataManager(
///   credentials: credentials!,
///   clientID: 'YOUR_CLIENT_ID',
///   clientSecret: 'YOUR_CLIENT_SECRET',
/// );
/// final result = await manager.fetch(
///   GoogleHealthStepsAPIURL.day(date: DateTime.now()),
/// );
/// print(result.data.first.value); // step count
/// ```
library google_flutter_health;

export 'src/connectors/google_health_connector.dart';
export 'src/connectors/google_health_credentials.dart';
export 'src/connectors/google_health_scopes.dart';
export 'src/connectors/google_health_session.dart';
export 'src/exceptions/google_health_exceptions.dart';
export 'src/managers/google_health_data_manager.dart';
export 'src/managers/google_health_profile_data_manager.dart';
export 'src/urls/google_health_api_url.dart';
export 'src/urls/google_health_profile_api_url.dart';
export 'src/data/google_health_profile_data.dart';
export 'src/managers/google_health_steps_data_manager.dart';
export 'src/urls/google_health_steps_api_url.dart';
export 'src/data/google_health_steps_data.dart';
export 'src/managers/google_health_heart_rate_data_manager.dart';
export 'src/urls/google_health_heart_rate_api_url.dart';
export 'src/data/google_health_heart_rate_data.dart';
export 'src/managers/google_health_sleep_data_manager.dart';
export 'src/urls/google_health_sleep_api_url.dart';
export 'src/data/google_health_sleep_data.dart';
