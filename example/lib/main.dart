import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

// Replace these with your Google Cloud Console credentials.
const _clientID = 'YOUR_CLIENT_ID';
const _clientSecret = 'YOUR_CLIENT_SECRET';
const _redirectUri = 'com.example.googleflutterhealthexample:/oauth2redirect';

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
  final _storage = const FlutterSecureStorage();

  GoogleHealthCredentials? _credentials;
  int? _steps;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final raw = await _storage.read(key: 'credentials');
    if (raw == null) return;
    final creds = GoogleHealthCredentials.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    setState(() => _credentials = creds);
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final creds = await GoogleHealthConnector.authorize(
        clientID: _clientID,
        clientSecret: _clientSecret,
        redirectUri: _redirectUri,
        scopes: [GoogleHealthScopes.activityAndFitnessReadonly],
      );
      if (creds != null) {
        await _storage.write(
          key: 'credentials',
          value: jsonEncode(creds.toJson()),
        );
        setState(() => _credentials = creds);
      }
    } on GoogleHealthAuthException catch (e) {
      setState(() => _error = 'Authorization failed: ${e.message}');
    } catch (e) {
      setState(() => _error = 'Unexpected error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchSteps() async {
    if (_credentials == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final manager = GoogleHealthStepsDataManager(
        credentials: _credentials!,
        clientID: _clientID,
        clientSecret: _clientSecret,
      );
      final result = await manager.fetch(
        GoogleHealthStepsAPIURL.day(date: DateTime.now()),
      );
      // Persist the returned credentials — they may have been refreshed.
      await _storage.write(
        key: 'credentials',
        value: jsonEncode(result.credentials.toJson()),
      );
      setState(() {
        _credentials = result.credentials;
        _steps = result.data.isNotEmpty ? result.data.first.value : 0;
      });
    } on GoogleHealthTokenExpiredException {
      setState(() {
        _error = 'Session expired. Please log in again.';
        _credentials = null;
      });
      await _storage.delete(key: 'credentials');
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
    if (_credentials != null) {
      await GoogleHealthConnector.unauthorize(credentials: _credentials!);
    }
    await _storage.delete(key: 'credentials');
    setState(() {
      _credentials = null;
      _steps = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Health Example'),
        actions: [
          if (_credentials != null)
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
              if (_loading)
                const CircularProgressIndicator()
              else if (_credentials == null) ...[
                const Icon(Icons.health_and_safety, size: 64, color: Colors.blue),
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
                const Icon(Icons.directions_walk, size: 64, color: Colors.green),
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
