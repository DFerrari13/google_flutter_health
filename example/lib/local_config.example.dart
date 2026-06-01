// Template for local OAuth config.
//
// Copy this file to `local_config.dart` (same directory) and replace the
// placeholders with your real Google OAuth **Web application** client
// credentials from Google Cloud Console. `local_config.dart` is gitignored —
// never commit real secrets.
//
//   cp local_config.example.dart local_config.dart
//
// For Android testing you ALSO need a separate OAuth **Android** client
// (package name + SHA-1) registered in the same Cloud project. That Android
// client ID is matched natively and is not referenced in Dart code.
library;

/// OAuth 2.0 **Web application** client ID (used as serverClientId and for the
/// server-side auth-code exchange).
const webClientID = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

/// OAuth 2.0 **Web application** client secret.
const webClientSecret = 'YOUR_WEB_CLIENT_SECRET';
