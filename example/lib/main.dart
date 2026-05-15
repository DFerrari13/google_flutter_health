import 'package:flutter/material.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_sign_in_service.dart';

// Web OAuth 2.0 client — used as `serverClientId` for google_sign_in AND for
// the server-side token exchange. The Web client must exist in Google Cloud
// Console alongside the Android client (which `google_sign_in` selects
// automatically from the app's package name + SHA-1).
const _webClientID =
    'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
const _webClientSecret = 'YOUR_CLIENT_SECRET';

const _scopes = <String>[GoogleHealthScopes.activityAndFitnessReadonly];

void main() => runApp(const GoogleHealthExampleApp());

class GoogleHealthExampleApp extends StatelessWidget {
  const GoogleHealthExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Health Example',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GoogleSignInService _auth;

  int? _steps;
  bool _loading = false;
  String? _error;
  bool _signInReady = false;

  @override
  void initState() {
    super.initState();
    _auth = GoogleSignInService(
      webClientID: _webClientID,
      webClientSecret: _webClientSecret,
      scopes: _scopes,
    );
    _auth.initialize().then((_) {
      if (!mounted) return;
      _auth.session.addListener(_onSessionChanged);
      setState(() => _signInReady = true);
    });
  }

  @override
  void dispose() {
    _auth.session.removeListener(_onSessionChanged);
    _auth.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.login();
    } on GoogleHealthAuthException catch (e) {
      setState(() => _error = 'Authorization failed: ${e.message}');
    } on GoogleSignInException catch (e) {
      setState(() => _error = 'Sign-in error: ${e.code.name}');
    } catch (e) {
      setState(() => _error = 'Unexpected error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchSteps() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final manager = GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      );
      final result = await manager.fetch(
        GoogleHealthStepsAPIURL.day(date: DateTime.now()),
      );
      // Persist the potentially-refreshed access token.
      _auth.session.updateCredentials(result.credentials);
      setState(() {
        _steps = result.data.isNotEmpty ? result.data.first.value : 0;
      });
    } on GoogleHealthTokenExpiredException {
      await _auth.logout();
      setState(() => _error = 'Session expired. Please log in again.');
    } on GoogleHealthRateLimitException {
      setState(() => _error = 'Too many requests. Please wait and try again.');
    } on GoogleHealthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Unexpected error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    setState(() {
      _steps = null;
      _error = null;
    });
    await _auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = _auth.session.isAuthenticated;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Health Example'),
        actions: [
          if (isSignedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: _logout,
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_loading || !_signInReady)
                const CircularProgressIndicator()
              else if (!isSignedIn) ...[
                const Icon(Icons.health_and_safety,
                    size: 64, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Connect your Google Health account to get started.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _login,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
              ] else ...[
                const Icon(Icons.directions_walk,
                    size: 64, color: Colors.green),
                const SizedBox(height: 16),
                if (_steps != null)
                  Text(
                    '$_steps steps today',
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                else
                  const Text('Tap the button to fetch your steps.'),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _fetchSteps,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Fetch today's steps"),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
