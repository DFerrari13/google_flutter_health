import 'package:flutter/material.dart';
import 'package:google_flutter_health/google_flutter_health.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'google_sign_in_service.dart';

const _webClientID =
    'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
const _webClientSecret = 'YOUR_CLIENT_SECRET';

const _scopes = <String>[
  GoogleHealthScopes.activityAndFitnessReadonly,
  GoogleHealthScopes.healthMetricsReadonly,
  GoogleHealthScopes.sleepReadonly,
  GoogleHealthScopes.profileReadonly,
  GoogleHealthScopes.settingsReadonly,
];

void main() => runApp(const GoogleHealthExampleApp());

class GoogleHealthExampleApp extends StatelessWidget {
  const GoogleHealthExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Health Debug',
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

  bool _loading = false;
  bool _signInReady = false;
  String? _error;

  // Google account identity (from google_sign_in)
  String? _googleUserId;
  String? _googleDisplayName;
  String? _googleEmail;

  // Health data results
  GoogleHealthProfileData? _profile;
  int? _steps;
  double? _heartRateAvg;
  Duration? _totalSleepDuration;
  double? _distanceMeters;
  double? _calories;
  double? _azmTotalMinutes;
  double? _restingHeartRate;
  double? _spo2Avg;
  double? _hrvRmssd;
  double? _weightKg;
  String? _latestExerciseType;
  double? _breathingRateAvg;
  double? _skinTempRelative;

  @override
  void initState() {
    super.initState();
    _auth = GoogleSignInService(
      webClientID: _webClientID,
      webClientSecret: _webClientSecret,
      scopes: _scopes,
    );
    _auth.initialize().then((_) async {
      if (!mounted) return;
      _auth.session.addListener(_onSessionChanged);
      // Restore identity if a previous session was loaded from storage.
      if (_auth.session.isAuthenticated) {
        final account = await GoogleSignIn.instance
            .attemptLightweightAuthentication()
            ?.catchError((_) => null);
        if (mounted && account != null) {
          setState(() {
            _googleUserId = account.id;
            _googleDisplayName = account.displayName;
            _googleEmail = account.email;
          });
        }
      }
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
      final account = await _auth.login();
      debugPrint('[DEBUG] Google account id: ${account.id}');
      debugPrint('[DEBUG] Google display name: ${account.displayName}');
      debugPrint('[DEBUG] Google email: ${account.email}');
      if (mounted) {
        setState(() {
          _googleUserId = account.id;
          _googleDisplayName = account.displayName;
          _googleEmail = account.email;
        });
      }
    } on GoogleHealthAuthException catch (e, st) {
      debugPrint('[GoogleHealth] ERROR login AuthException: $e\n$st');
      setState(() => _error = 'Authorization failed: ${e.message}');
    } catch (e, st) {
      debugPrint('[GoogleHealth] ERROR login unexpected: $e\n$st');
      setState(() => _error = 'Unexpected error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    setState(() {
      _googleUserId = null;
      _googleDisplayName = null;
      _googleEmail = null;
      _profile = null;
      _steps = null;
      _heartRateAvg = null;
      _totalSleepDuration = null;
      _distanceMeters = null;
      _calories = null;
      _azmTotalMinutes = null;
      _restingHeartRate = null;
      _spo2Avg = null;
      _hrvRmssd = null;
      _weightKg = null;
      _latestExerciseType = null;
      _breathingRateAvg = null;
      _skinTempRelative = null;
      _error = null;
    });
    await _auth.logout();
  }

  Future<void> _fetchAll() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // ── Profile ────────────────────────────────────────────────────────
      final profileResult = await GoogleHealthProfileDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthProfileAPIURL.profile);
      _auth.session.updateCredentials(profileResult.credentials);
      final profile =
          profileResult.data.isNotEmpty ? profileResult.data.first : null;
      debugPrint('[DEBUG] profile: $profile');
      setState(() => _profile = profile);

      // ── Steps ──────────────────────────────────────────────────────────
      final stepsResult = await GoogleHealthStepsDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthStepsAPIURL.day(date: today));
      _auth.session.updateCredentials(stepsResult.credentials);
      final steps =
          stepsResult.data.isNotEmpty ? stepsResult.data.first.count : null;
      debugPrint('[DEBUG] steps: $steps');
      setState(() => _steps = steps);

      // ── Heart Rate ─────────────────────────────────────────────────────
      final hrResult = await GoogleHealthHeartRateDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthHeartRateAPIURL.day(date: today));
      _auth.session.updateCredentials(hrResult.credentials);
      final hrAvg = hrResult.data.isNotEmpty
          ? hrResult.data.first.beatsPerMinuteAvg
          : null;
      debugPrint('[DEBUG] heart rate avg bpm: $hrAvg');
      setState(() => _heartRateAvg = hrAvg);

      // ── Sleep ──────────────────────────────────────────────────────────
      final sleepResult = await GoogleHealthSleepDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthSleepAPIURL.dateRange(
        startDate: yesterday,
        endDate: today,
      ));
      _auth.session.updateCredentials(sleepResult.credentials);
      final totalSleep = sleepResult.data.fold<Duration>(
        Duration.zero,
        (acc, s) => acc + (s.duration ?? Duration.zero),
      );
      debugPrint('[DEBUG] sleep segments: ${sleepResult.data.length}, '
          'total: $totalSleep');
      for (final s in sleepResult.data) {
        debugPrint('[DEBUG]   sleep segment: $s');
      }
      setState(() => _totalSleepDuration = totalSleep);

      // ── Distance ───────────────────────────────────────────────────────
      final distResult = await GoogleHealthDistanceDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthDistanceAPIURL.day(date: today));
      _auth.session.updateCredentials(distResult.credentials);
      final dist = distResult.data.isNotEmpty
          ? distResult.data.first.distanceMeters
          : null;
      debugPrint('[DEBUG] distance meters: $dist');
      setState(() => _distanceMeters = dist);

      // ── Calories ───────────────────────────────────────────────────────
      final calResult = await GoogleHealthCaloriesDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthCaloriesAPIURL.day(date: today));
      _auth.session.updateCredentials(calResult.credentials);
      final cal =
          calResult.data.isNotEmpty ? calResult.data.first.calories : null;
      debugPrint('[DEBUG] calories kcal: $cal');
      setState(() => _calories = cal);

      // ── Active Zone Minutes ────────────────────────────────────────────
      final azmResult = await GoogleHealthActiveZoneMinutesDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthActiveZoneMinutesAPIURL.day(date: today));
      _auth.session.updateCredentials(azmResult.credentials);
      final azm =
          azmResult.data.isNotEmpty ? azmResult.data.first.totalMinutes : null;
      debugPrint('[DEBUG] AZM total minutes: $azm');
      setState(() => _azmTotalMinutes = azm);

      // ── Resting Heart Rate ─────────────────────────────────────────────
      final rhrResult = await GoogleHealthRestingHeartRateDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthRestingHeartRateAPIURL.day(date: today));
      _auth.session.updateCredentials(rhrResult.credentials);
      for (final d in rhrResult.data) {
        //debugPrint('[DEBUG] rhr point: start=${d.startTime} bpm=${d.beatsPerMinute}');
      }
      final rhr =
          _pickToday(rhrResult.data, today, (d) => d.startTime)?.beatsPerMinute;
      debugPrint('[DEBUG] resting heart rate bpm (today): $rhr');
      setState(() => _restingHeartRate = rhr);

      // ── SpO2 ───────────────────────────────────────────────────────────
      final spo2Result = await GoogleHealthOxygenSaturationDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthOxygenSaturationAPIURL.day(date: today));
      _auth.session.updateCredentials(spo2Result.credentials);
      for (final d in spo2Result.data) {
        //debugPrint('[DEBUG] spo2 point: start=${d.startTime} avg=${d.percentageAvg}');
      }
      final spo2 =
          _pickToday(spo2Result.data, today, (d) => d.startTime)?.percentageAvg;
      debugPrint('[DEBUG] SpO2 avg % (today): $spo2');
      setState(() => _spo2Avg = spo2);

      // ── HRV ───────────────────────────────────────────────────────────
      final hrvResult = await GoogleHealthHrvDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthHrvAPIURL.day(date: today));
      _auth.session.updateCredentials(hrvResult.credentials);
      for (final d in hrvResult.data) {
        //debugPrint('[DEBUG] hrv point: start=${d.startTime} rmssd=${d.rmssd}');
      }
      final hrv = _pickToday(hrvResult.data, today, (d) => d.startTime)?.rmssd;
      debugPrint('[DEBUG] HRV rmssd ms (today): $hrv');
      setState(() => _hrvRmssd = hrv);

      // ── Weight ────────────────────────────────────────────────────────
      final weightResult = await GoogleHealthWeightDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthWeightAPIURL.day(date: today));
      _auth.session.updateCredentials(weightResult.credentials);
      final wt = weightResult.data.isNotEmpty
          ? weightResult.data.first.weightKg
          : null;
      debugPrint('[DEBUG] weight kg: $wt');
      setState(() => _weightKg = wt);

      // ── Exercise ──────────────────────────────────────────────────────
      final exResult = await GoogleHealthExerciseDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthExerciseAPIURL.dateRange(
        startDate: today.subtract(const Duration(days: 7)),
        endDate: today,
      ));
      _auth.session.updateCredentials(exResult.credentials);
      final exType =
          exResult.data.isNotEmpty ? exResult.data.first.exerciseType : null;
      debugPrint('[DEBUG] exercise sessions: ${exResult.data.length}');
      for (final e in exResult.data) {
        debugPrint('[DEBUG]   exercise: $e');
      }
      setState(() => _latestExerciseType = exType);

      // ── Breathing Rate ────────────────────────────────────────────────
      final brResult = await GoogleHealthBreathingRateDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthBreathingRateAPIURL.day(date: today));
      _auth.session.updateCredentials(brResult.credentials);
      for (final d in brResult.data) {
        //debugPrint('[DEBUG] br point: start=${d.startTime} avg=${d.breathsPerMinuteAvg}');
      }
      final br = _pickToday(brResult.data, today, (d) => d.startTime)
          ?.breathsPerMinuteAvg;
      debugPrint('[DEBUG] breathing rate avg brpm (today): $br');
      setState(() => _breathingRateAvg = br);

      // ── Skin Temperature ──────────────────────────────────────────────
      final stResult = await GoogleHealthSkinTemperatureDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthSkinTemperatureAPIURL.day(date: today));
      _auth.session.updateCredentials(stResult.credentials);
      for (final d in stResult.data) {
        //debugPrint('[DEBUG] skin temp point: start=${d.startTime} val=${d.nightlyRelativeCelsius}');
      }
      final st = _pickToday(stResult.data, today, (d) => d.startTime)
          ?.nightlyRelativeCelsius;
      debugPrint('[DEBUG] skin temp relative °C (today): $st');
      setState(() => _skinTempRelative = st);
    } on GoogleHealthTokenExpiredException catch (e, st) {
      debugPrint('[GoogleHealth] ERROR TokenExpired: $e\n$st');
      await _auth.logout();
      setState(() => _error = 'Session expired. Please log in again.');
    } on GoogleHealthRateLimitException catch (e, st) {
      debugPrint('[GoogleHealth] ERROR RateLimit: $e\n$st');
      setState(() => _error = 'Rate limit hit. Wait and try again.');
    } on GoogleHealthException catch (e, st) {
      debugPrint('[GoogleHealth] ERROR GoogleHealthException: $e\n$st');
      setState(() => _error = e.message);
    } catch (e, st) {
      debugPrint('[GoogleHealth] ERROR unexpected: $e\n$st');
      setState(() => _error = 'Unexpected error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  T? _pickToday<T>(
    List<T> data,
    DateTime today,
    DateTime? Function(T) getDate,
  ) {
    final todayDate = DateTime(today.year, today.month, today.day);
    // Try exact date match first; fall back to most recent if none found.
    T? match;
    DateTime? bestDate;
    for (final item in data) {
      final d = getDate(item);
      if (d == null) continue;
      final date = DateTime(d.year, d.month, d.day);
      if (date == todayDate) return item;
      if (bestDate == null || date.isAfter(bestDate)) {
        bestDate = date;
        match = item;
      }
    }
    return match;
  }

  String _fmtDuration(Duration? d) {
    if (d == null || d == Duration.zero) return 'null';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = _auth.session.isAuthenticated;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Google Health Debug'),
        actions: [
          if (isSignedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: _logout,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_loading || !_signInReady)
                  const Center(child: CircularProgressIndicator())
                else if (!isSignedIn) ...[
                  const Icon(Icons.health_and_safety,
                      size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  const Text(
                    'Sign in to run the full plugin verification.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _login,
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                  ),
                ] else ...[
                  // ── Identity card ──────────────────────────────────────
                  _SectionCard(
                    title: 'Google Account Identity',
                    color: Colors.blue.shade50,
                    children: [
                      _Row('User ID', _googleUserId ?? 'null'),
                      _Row('Display name', _googleDisplayName ?? 'null'),
                      _Row('Email', _googleEmail ?? 'null'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Profile card ───────────────────────────────────────
                  _SectionCard(
                    title: 'Health Profile & Settings',
                    color: Colors.teal.shade50,
                    children: [
                      _Row('Age', _profile?.age?.toString() ?? 'null'),
                      _Row('Member since',
                          _profile?.membershipStartDate ?? 'null'),
                      _Row('Time zone', _profile?.timeZone ?? 'null'),
                      _Row('Locale', _profile?.languageLocale ?? 'null'),
                      _Row('Distance unit', _profile?.distanceUnit ?? 'null'),
                      _Row('Weight unit', _profile?.weightUnit ?? 'null'),
                      _Row('Temperature unit',
                          _profile?.temperatureUnit ?? 'null'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Activity card ──────────────────────────────────────
                  _SectionCard(
                    title: 'Today — Activity',
                    color: Colors.green.shade50,
                    children: [
                      _Row('Steps', _steps?.toString() ?? 'null'),
                      _Row(
                          'Distance',
                          _distanceMeters != null
                              ? '${_distanceMeters!.toStringAsFixed(0)} m'
                              : 'null'),
                      _Row(
                          'Calories',
                          _calories != null
                              ? '${_calories!.toStringAsFixed(1)} kcal'
                              : 'null'),
                      _Row(
                          'Active Zone Minutes',
                          _azmTotalMinutes != null
                              ? '${_azmTotalMinutes!.toStringAsFixed(1)} min'
                              : 'null'),
                      _Row('Latest exercise (7d)',
                          _latestExerciseType ?? 'null'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Heart card ─────────────────────────────────────────
                  _SectionCard(
                    title: 'Today — Heart',
                    color: Colors.red.shade50,
                    children: [
                      _Row(
                          'Heart rate (avg)',
                          _heartRateAvg != null
                              ? '${_heartRateAvg!.toStringAsFixed(1)} bpm'
                              : 'null'),
                      _Row(
                          'Resting heart rate',
                          _restingHeartRate != null
                              ? '${_restingHeartRate!.toStringAsFixed(1)} bpm'
                              : 'null'),
                      _Row(
                          'HRV (RMSSD)',
                          _hrvRmssd != null
                              ? '${_hrvRmssd!.toStringAsFixed(1)} ms'
                              : 'null'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Vitals card ────────────────────────────────────────
                  _SectionCard(
                    title: 'Today — Vitals',
                    color: Colors.purple.shade50,
                    children: [
                      _Row(
                          'SpO2 (avg)',
                          _spo2Avg != null
                              ? '${_spo2Avg!.toStringAsFixed(1)} %'
                              : 'null'),
                      _Row(
                          'Breathing rate (avg)',
                          _breathingRateAvg != null
                              ? '${_breathingRateAvg!.toStringAsFixed(1)} brpm'
                              : 'null'),
                      _Row(
                          'Skin temp variation',
                          _skinTempRelative != null
                              ? '${_skinTempRelative! >= 0 ? '+' : ''}'
                                  '${_skinTempRelative!.toStringAsFixed(2)} °C'
                              : 'null'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Body / Sleep card ──────────────────────────────────
                  _SectionCard(
                    title: 'Body & Sleep',
                    color: Colors.orange.shade50,
                    children: [
                      _Row(
                          'Weight',
                          _weightKg != null
                              ? '${_weightKg!.toStringAsFixed(1)} kg'
                              : 'null'),
                      _Row('Sleep last night',
                          _fmtDuration(_totalSleepDuration)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  FilledButton.icon(
                    onPressed: _loading ? null : _fetchAll,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Fetch all data'),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    required this.color,
  });

  final String title;
  final List<Widget> children;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}
