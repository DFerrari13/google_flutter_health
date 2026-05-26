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

enum _QueryMode { day, dateRange }

// Top-level so both state and dialogs can share it.
String _fmtDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

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

  // ── Google account identity (from google_sign_in) ──────────────────────
  String? _googleUserId;
  String? _googleDisplayName;
  String? _googleEmail;

  // ── Profile ────────────────────────────────────────────────────────────
  GoogleHealthProfileData? _profile;
  bool _profileLoading = false;
  String? _profileError;

  // ── Sleep ──────────────────────────────────────────────────────────────
  _QueryMode _sleepMode = _QueryMode.day;
  DateTime _sleepDay = DateTime(2024, 12, 28);
  DateTime _sleepStart = DateTime(2024, 12, 22);
  DateTime _sleepEnd = DateTime(2024, 12, 28);
  bool _sleepLoading = false;
  String? _sleepError;

  // ── Breathing Rate ─────────────────────────────────────────────────────
  _QueryMode _brMode = _QueryMode.day;
  DateTime _brDay = DateTime(2024, 12, 28);
  DateTime _brStart = DateTime(2024, 12, 22);
  DateTime _brEnd = DateTime(2024, 12, 28);
  bool _brLoading = false;
  String? _brError;

  // ── Activity Level ─────────────────────────────────────────────────────
  _QueryMode _actMode = _QueryMode.day;
  DateTime _actDay = DateTime(2024, 12, 28);
  DateTime _actStart = DateTime(2024, 12, 22);
  DateTime _actEnd = DateTime(2024, 12, 28);
  bool _actLoading = false;
  String? _actError;

  // ── Steps ──────────────────────────────────────────────────────────────
  _QueryMode _stepsMode = _QueryMode.day;
  DateTime _stepsDay = DateTime(2024, 12, 28);
  DateTime _stepsStart = DateTime(2024, 12, 22);
  DateTime _stepsEnd = DateTime(2024, 12, 28);
  bool _stepsLoading = false;
  String? _stepsError;

  // ── SpO2 ───────────────────────────────────────────────────────────────
  _QueryMode _spo2Mode = _QueryMode.day;
  DateTime _spo2Day = DateTime(2024, 12, 28);
  DateTime _spo2Start = DateTime(2024, 12, 22);
  DateTime _spo2End = DateTime(2024, 12, 28);
  bool _spo2Loading = false;
  String? _spo2Error;

  // ── HRV ────────────────────────────────────────────────────────────────
  _QueryMode _hrvMode = _QueryMode.day;
  DateTime _hrvDay = DateTime(2024, 12, 28);
  DateTime _hrvStart = DateTime(2024, 12, 22);
  DateTime _hrvEnd = DateTime(2024, 12, 28);
  bool _hrvLoading = false;
  String? _hrvError;

  // ── Resting HR ─────────────────────────────────────────────────────────
  _QueryMode _rhrMode = _QueryMode.day;
  DateTime _rhrDay = DateTime(2024, 12, 28);
  DateTime _rhrStart = DateTime(2024, 12, 22);
  DateTime _rhrEnd = DateTime(2024, 12, 28);
  bool _rhrLoading = false;
  String? _rhrError;

  // ── Skin Temp ──────────────────────────────────────────────────────────
  _QueryMode _tempMode = _QueryMode.day;
  DateTime _tempDay = DateTime(2024, 12, 28);
  DateTime _tempStart = DateTime(2024, 12, 22);
  DateTime _tempEnd = DateTime(2024, 12, 28);
  bool _tempLoading = false;
  String? _tempError;

  // ── Lifecycle ──────────────────────────────────────────────────────────

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

  // ── Auth ───────────────────────────────────────────────────────────────

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
      _profileError = null;
      _error = null;
    });
    await _auth.logout();
  }

  // ── Date helpers ───────────────────────────────────────────────────────

  String _queryLabel(
    _QueryMode mode,
    DateTime day,
    DateTime start,
    DateTime end,
  ) =>
      mode == _QueryMode.day
          ? _fmtDate(day)
          : '${_fmtDate(start)} → ${_fmtDate(end)}';

  Future<DateTime?> _pickDate(DateTime initial) => showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );

  // ── Query-mode UI helper ───────────────────────────────────────────────

  Widget _buildQueryControls({
    required _QueryMode mode,
    required DateTime day,
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required void Function(_QueryMode) onModeChanged,
    required void Function(DateTime) onDayChanged,
    required void Function(DateTime) onStartChanged,
    required void Function(DateTime) onEndChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<_QueryMode>(
          segments: const [
            ButtonSegment(
              value: _QueryMode.day,
              label: Text('Single day'),
              icon: Icon(Icons.calendar_today, size: 14),
            ),
            ButtonSegment(
              value: _QueryMode.dateRange,
              label: Text('Date range'),
              icon: Icon(Icons.date_range, size: 14),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (s) => onModeChanged(s.first),
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(height: 8),
        if (mode == _QueryMode.day)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date: ${_fmtDate(day)}',
                  style: const TextStyle(fontSize: 13)),
              TextButton(
                onPressed: () async {
                  final p = await _pickDate(day);
                  if (p != null && mounted) onDayChanged(p);
                },
                child: const Text('Change'),
              ),
            ],
          )
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('From: ${_fmtDate(rangeStart)}',
                  style: const TextStyle(fontSize: 13)),
              TextButton(
                onPressed: () async {
                  final p = await _pickDate(rangeStart);
                  if (p != null && mounted) onStartChanged(p);
                },
                child: const Text('Change'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('To:   ${_fmtDate(rangeEnd)}',
                  style: const TextStyle(fontSize: 13)),
              TextButton(
                onPressed: () async {
                  final p = await _pickDate(rangeEnd);
                  if (p != null && mounted) onEndChanged(p);
                },
                child: const Text('Change'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ── Fetch functions ────────────────────────────────────────────────────

  Future<void> _fetchProfile() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _profileLoading = true;
      _profileError = null;
    });
    try {
      final result = await GoogleHealthProfileDataManager(
        credentials: credentials,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(GoogleHealthProfileAPIURL.profile);
      _auth.session.updateCredentials(result.credentials);
      setState(() {
        _profile = result.data.isNotEmpty ? result.data.first : null;
        if (_profile == null) _profileError = 'No profile data returned';
      });
      debugPrint('[Profile DEBUG] $_profile');
    } on GoogleHealthException catch (e) {
      setState(() => _profileError = e.message);
    } catch (e) {
      setState(() => _profileError = 'Unexpected error: $e');
    } finally {
      setState(() => _profileLoading = false);
    }
  }

  Future<void> _fetchSleep() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _sleepLoading = true;
      _sleepError = null;
    });
    try {
      final url = _sleepMode == _QueryMode.day
          ? GoogleHealthSleepAPIURL.day(date: _sleepDay)
          : GoogleHealthSleepAPIURL.dateRange(
              startDate: _sleepStart, endDate: _sleepEnd);
      debugPrint('[Sleep DEBUG] URL: ${url.uri}');
      final result = await GoogleHealthSleepDataManager(
        credentials: credentials,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(url);
      _auth.session.updateCredentials(result.credentials);
      for (final s in result.data) {
        debugPrint('[Sleep DEBUG] session: $s');
      }
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => _SleepResultDialog(
          label: _queryLabel(_sleepMode, _sleepDay, _sleepStart, _sleepEnd),
          url: url.uri.toString(),
          sessions: result.data,
        ),
      );
    } on GoogleHealthException catch (e) {
      setState(() => _sleepError = e.message);
    } catch (e) {
      setState(() => _sleepError = 'Unexpected error: $e');
    } finally {
      setState(() => _sleepLoading = false);
    }
  }

  Future<void> _fetchBreathing() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _brLoading = true;
      _brError = null;
    });
    try {
      final url = _brMode == _QueryMode.day
          ? GoogleHealthBreathingRateAPIURL.day(date: _brDay)
          : GoogleHealthBreathingRateAPIURL.dateRange(
              startDate: _brStart, endDate: _brEnd);
      debugPrint('[Breathing DEBUG] URL: ${url.uri}');
      final result = await GoogleHealthBreathingRateDataManager(
        credentials: credentials,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(url);
      _auth.session.updateCredentials(result.credentials);
      for (final d in result.data) {
        debugPrint('[Breathing DEBUG] point: $d');
      }
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => _BreathingResultDialog(
          label: _queryLabel(_brMode, _brDay, _brStart, _brEnd),
          url: url.uri.toString(),
          points: result.data,
        ),
      );
    } on GoogleHealthException catch (e) {
      setState(() => _brError = e.message);
    } catch (e) {
      setState(() => _brError = 'Unexpected error: $e');
    } finally {
      setState(() => _brLoading = false);
    }
  }

  Future<void> _fetchActivity() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _actLoading = true;
      _actError = null;
    });
    try {
      final amUrl = _actMode == _QueryMode.day
          ? GoogleHealthActiveMinutesAPIURL.day(date: _actDay)
          : GoogleHealthActiveMinutesAPIURL.dateRange(
              startDate: _actStart, endDate: _actEnd);
      final spUrl = _actMode == _QueryMode.day
          ? GoogleHealthSedentaryPeriodAPIURL.day(date: _actDay)
          : GoogleHealthSedentaryPeriodAPIURL.dateRange(
              startDate: _actStart, endDate: _actEnd);
      debugPrint('[Activity DEBUG] AM URL: ${amUrl.uri}');
      debugPrint('[Activity DEBUG] SP URL: ${spUrl.uri}');

      final amResult = await GoogleHealthActiveMinutesDataManager(
        credentials: credentials,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(amUrl);
      _auth.session.updateCredentials(amResult.credentials);
      for (final d in amResult.data) {
        debugPrint('[Activity DEBUG] active point: $d');
      }

      final spResult = await GoogleHealthSedentaryPeriodDataManager(
        credentials: _auth.session.credentials!,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(spUrl);
      _auth.session.updateCredentials(spResult.credentials);
      for (final d in spResult.data) {
        debugPrint('[Activity DEBUG] sedentary point: $d');
      }

      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => _ActivityLevelResultDialog(
          label: _queryLabel(_actMode, _actDay, _actStart, _actEnd),
          amUrl: amUrl.uri.toString(),
          spUrl: spUrl.uri.toString(),
          activePoints: amResult.data,
          sedentaryPoints: spResult.data,
        ),
      );
    } on GoogleHealthException catch (e) {
      setState(() => _actError = e.message);
    } catch (e) {
      setState(() => _actError = 'Unexpected error: $e');
    } finally {
      setState(() => _actLoading = false);
    }
  }

  Future<void> _fetchSteps() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _stepsLoading = true;
      _stepsError = null;
    });
    try {
      final url = _stepsMode == _QueryMode.day
          ? GoogleHealthStepsAPIURL.day(date: _stepsDay)
          : GoogleHealthStepsAPIURL.dateRange(
              startDate: _stepsStart, endDate: _stepsEnd);
      debugPrint('[Steps DEBUG] URL: ${url.uri}');
      final result = await GoogleHealthStepsDataManager(
        credentials: credentials,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(url);
      _auth.session.updateCredentials(result.credentials);
      for (final d in result.data) {
        debugPrint('[Steps DEBUG] point: $d');
      }
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => _StepsResultDialog(
          label: _queryLabel(_stepsMode, _stepsDay, _stepsStart, _stepsEnd),
          url: url.uri.toString(),
          points: result.data,
        ),
      );
    } on GoogleHealthException catch (e) {
      setState(() => _stepsError = e.message);
    } catch (e) {
      setState(() => _stepsError = 'Unexpected error: $e');
    } finally {
      setState(() => _stepsLoading = false);
    }
  }

  Future<void> _fetchSpo2() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _spo2Loading = true;
      _spo2Error = null;
    });
    try {
      final url = _spo2Mode == _QueryMode.day
          ? GoogleHealthOxygenSaturationAPIURL.day(date: _spo2Day)
          : GoogleHealthOxygenSaturationAPIURL.dateRange(
              startDate: _spo2Start, endDate: _spo2End);
      debugPrint('[SpO2 DEBUG] URL: ${url.uri}');
      final result = await GoogleHealthOxygenSaturationDataManager(
        credentials: credentials,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(url);
      _auth.session.updateCredentials(result.credentials);
      for (final d in result.data) {
        debugPrint('[SpO2 DEBUG] point: $d');
      }
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => _Spo2ResultDialog(
          label: _queryLabel(_spo2Mode, _spo2Day, _spo2Start, _spo2End),
          url: url.uri.toString(),
          points: result.data,
        ),
      );
    } on GoogleHealthException catch (e) {
      setState(() => _spo2Error = e.message);
    } catch (e) {
      setState(() => _spo2Error = 'Unexpected error: $e');
    } finally {
      setState(() => _spo2Loading = false);
    }
  }

  Future<void> _fetchHrv() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _hrvLoading = true;
      _hrvError = null;
    });
    try {
      final url = _hrvMode == _QueryMode.day
          ? GoogleHealthHrvAPIURL.day(date: _hrvDay)
          : GoogleHealthHrvAPIURL.dateRange(
              startDate: _hrvStart, endDate: _hrvEnd);
      debugPrint('[HRV DEBUG] URL: ${url.uri}');
      final result = await GoogleHealthHrvDataManager(
        credentials: credentials,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(url);
      _auth.session.updateCredentials(result.credentials);
      for (final d in result.data) {
        debugPrint('[HRV DEBUG] point: $d');
      }
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => _HrvResultDialog(
          label: _queryLabel(_hrvMode, _hrvDay, _hrvStart, _hrvEnd),
          url: url.uri.toString(),
          points: result.data,
        ),
      );
    } on GoogleHealthException catch (e) {
      setState(() => _hrvError = e.message);
    } catch (e) {
      setState(() => _hrvError = 'Unexpected error: $e');
    } finally {
      setState(() => _hrvLoading = false);
    }
  }

  Future<void> _fetchRhr() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _rhrLoading = true;
      _rhrError = null;
    });
    try {
      final url = _rhrMode == _QueryMode.day
          ? GoogleHealthRestingHeartRateAPIURL.day(date: _rhrDay)
          : GoogleHealthRestingHeartRateAPIURL.dateRange(
              startDate: _rhrStart, endDate: _rhrEnd);
      debugPrint('[RHR DEBUG] URL: ${url.uri}');
      final result = await GoogleHealthRestingHeartRateDataManager(
        credentials: credentials,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(url);
      _auth.session.updateCredentials(result.credentials);
      for (final d in result.data) {
        debugPrint('[RHR DEBUG] point: $d');
      }
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => _RhrResultDialog(
          label: _queryLabel(_rhrMode, _rhrDay, _rhrStart, _rhrEnd),
          url: url.uri.toString(),
          points: result.data,
        ),
      );
    } on GoogleHealthException catch (e) {
      setState(() => _rhrError = e.message);
    } catch (e) {
      setState(() => _rhrError = 'Unexpected error: $e');
    } finally {
      setState(() => _rhrLoading = false);
    }
  }

  Future<void> _fetchTemp() async {
    final credentials = _auth.session.credentials;
    if (credentials == null) return;
    setState(() {
      _tempLoading = true;
      _tempError = null;
    });
    try {
      final url = _tempMode == _QueryMode.day
          ? GoogleHealthSkinTemperatureAPIURL.day(date: _tempDay)
          : GoogleHealthSkinTemperatureAPIURL.dateRange(
              startDate: _tempStart, endDate: _tempEnd);
      debugPrint('[Temp DEBUG] URL: ${url.uri}');
      final result = await GoogleHealthSkinTemperatureDataManager(
        credentials: credentials,
        clientID: _webClientID,
        clientSecret: _webClientSecret,
      ).fetch(url);
      _auth.session.updateCredentials(result.credentials);
      for (final d in result.data) {
        debugPrint('[Temp DEBUG] point: $d');
      }
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => _TempResultDialog(
          label: _queryLabel(_tempMode, _tempDay, _tempStart, _tempEnd),
          url: url.uri.toString(),
          points: result.data,
        ),
      );
    } on GoogleHealthException catch (e) {
      setState(() => _tempError = e.message);
    } catch (e) {
      setState(() => _tempError = 'Unexpected error: $e');
    } finally {
      setState(() => _tempLoading = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

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
                  // ── Identity card ────────────────────────────────────
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

                  // ── Profile & Settings card ──────────────────────────
                  _SectionCard(
                    title: 'Profile & Settings',
                    color: Colors.teal.shade50,
                    children: [
                      if (_profile != null) ...[
                        _Row('Age', _profile!.age?.toString() ?? 'null'),
                        _Row('Member since',
                            _profile!.membershipStartDate ?? 'null'),
                        _Row('Time zone', _profile!.timeZone ?? 'null'),
                        _Row('Locale', _profile!.languageLocale ?? 'null'),
                        _Row(
                            'Distance unit', _profile!.distanceUnit ?? 'null'),
                        _Row('Weight unit', _profile!.weightUnit ?? 'null'),
                        _Row('Temperature unit',
                            _profile!.temperatureUnit ?? 'null'),
                        const SizedBox(height: 4),
                      ],
                      if (_profileLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        FilledButton.icon(
                          onPressed: _fetchProfile,
                          icon: const Icon(Icons.person),
                          label: const Text('Fetch Profile & Settings'),
                        ),
                      if (_profileError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _profileError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Sleep ────────────────────────────────────────────
                  _SectionCard(
                    title: 'Sleep',
                    color: Colors.indigo.shade50,
                    children: [
                      _buildQueryControls(
                        mode: _sleepMode,
                        day: _sleepDay,
                        rangeStart: _sleepStart,
                        rangeEnd: _sleepEnd,
                        onModeChanged: (m) =>
                            setState(() => _sleepMode = m),
                        onDayChanged: (d) =>
                            setState(() => _sleepDay = d),
                        onStartChanged: (d) =>
                            setState(() => _sleepStart = d),
                        onEndChanged: (d) =>
                            setState(() => _sleepEnd = d),
                      ),
                      const SizedBox(height: 4),
                      if (_sleepLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        FilledButton.icon(
                          onPressed: _fetchSleep,
                          icon: const Icon(Icons.bedtime),
                          label: const Text('Fetch Sleep'),
                        ),
                      if (_sleepError != null) ...[
                        const SizedBox(height: 4),
                        Text(_sleepError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Breathing Rate ───────────────────────────────────
                  _SectionCard(
                    title: 'Breathing Rate',
                    color: Colors.teal.shade50,
                    children: [
                      _buildQueryControls(
                        mode: _brMode,
                        day: _brDay,
                        rangeStart: _brStart,
                        rangeEnd: _brEnd,
                        onModeChanged: (m) =>
                            setState(() => _brMode = m),
                        onDayChanged: (d) => setState(() => _brDay = d),
                        onStartChanged: (d) =>
                            setState(() => _brStart = d),
                        onEndChanged: (d) => setState(() => _brEnd = d),
                      ),
                      const SizedBox(height: 4),
                      if (_brLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        FilledButton.icon(
                          onPressed: _fetchBreathing,
                          icon: const Icon(Icons.air),
                          label: const Text('Fetch Breathing Rate'),
                        ),
                      if (_brError != null) ...[
                        const SizedBox(height: 4),
                        Text(_brError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Activity Level ───────────────────────────────────
                  _SectionCard(
                    title: 'Activity Level',
                    color: Colors.lime.shade50,
                    children: [
                      _buildQueryControls(
                        mode: _actMode,
                        day: _actDay,
                        rangeStart: _actStart,
                        rangeEnd: _actEnd,
                        onModeChanged: (m) =>
                            setState(() => _actMode = m),
                        onDayChanged: (d) =>
                            setState(() => _actDay = d),
                        onStartChanged: (d) =>
                            setState(() => _actStart = d),
                        onEndChanged: (d) =>
                            setState(() => _actEnd = d),
                      ),
                      const SizedBox(height: 4),
                      if (_actLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        FilledButton.icon(
                          onPressed: _fetchActivity,
                          icon: const Icon(Icons.directions_run),
                          label: const Text('Fetch Activity Level'),
                        ),
                      if (_actError != null) ...[
                        const SizedBox(height: 4),
                        Text(_actError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Steps ────────────────────────────────────────────
                  _SectionCard(
                    title: 'Steps',
                    color: Colors.green.shade50,
                    children: [
                      _buildQueryControls(
                        mode: _stepsMode,
                        day: _stepsDay,
                        rangeStart: _stepsStart,
                        rangeEnd: _stepsEnd,
                        onModeChanged: (m) =>
                            setState(() => _stepsMode = m),
                        onDayChanged: (d) =>
                            setState(() => _stepsDay = d),
                        onStartChanged: (d) =>
                            setState(() => _stepsStart = d),
                        onEndChanged: (d) =>
                            setState(() => _stepsEnd = d),
                      ),
                      const SizedBox(height: 4),
                      if (_stepsLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        FilledButton.icon(
                          onPressed: _fetchSteps,
                          icon: const Icon(Icons.directions_walk),
                          label: const Text('Fetch Steps'),
                        ),
                      if (_stepsError != null) ...[
                        const SizedBox(height: 4),
                        Text(_stepsError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── SpO2 ─────────────────────────────────────────────
                  _SectionCard(
                    title: 'SpO2',
                    color: Colors.cyan.shade50,
                    children: [
                      _buildQueryControls(
                        mode: _spo2Mode,
                        day: _spo2Day,
                        rangeStart: _spo2Start,
                        rangeEnd: _spo2End,
                        onModeChanged: (m) =>
                            setState(() => _spo2Mode = m),
                        onDayChanged: (d) =>
                            setState(() => _spo2Day = d),
                        onStartChanged: (d) =>
                            setState(() => _spo2Start = d),
                        onEndChanged: (d) =>
                            setState(() => _spo2End = d),
                      ),
                      const SizedBox(height: 4),
                      if (_spo2Loading)
                        const Center(child: CircularProgressIndicator())
                      else
                        FilledButton.icon(
                          onPressed: _fetchSpo2,
                          icon: const Icon(Icons.water_drop),
                          label: const Text('Fetch SpO2'),
                        ),
                      if (_spo2Error != null) ...[
                        const SizedBox(height: 4),
                        Text(_spo2Error!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── HRV ──────────────────────────────────────────────
                  _SectionCard(
                    title: 'HRV',
                    color: Colors.purple.shade50,
                    children: [
                      _buildQueryControls(
                        mode: _hrvMode,
                        day: _hrvDay,
                        rangeStart: _hrvStart,
                        rangeEnd: _hrvEnd,
                        onModeChanged: (m) =>
                            setState(() => _hrvMode = m),
                        onDayChanged: (d) =>
                            setState(() => _hrvDay = d),
                        onStartChanged: (d) =>
                            setState(() => _hrvStart = d),
                        onEndChanged: (d) =>
                            setState(() => _hrvEnd = d),
                      ),
                      const SizedBox(height: 4),
                      if (_hrvLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        FilledButton.icon(
                          onPressed: _fetchHrv,
                          icon: const Icon(Icons.favorite_border),
                          label: const Text('Fetch HRV'),
                        ),
                      if (_hrvError != null) ...[
                        const SizedBox(height: 4),
                        Text(_hrvError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Resting HR ───────────────────────────────────────
                  _SectionCard(
                    title: 'Resting Heart Rate',
                    color: Colors.red.shade50,
                    children: [
                      _buildQueryControls(
                        mode: _rhrMode,
                        day: _rhrDay,
                        rangeStart: _rhrStart,
                        rangeEnd: _rhrEnd,
                        onModeChanged: (m) =>
                            setState(() => _rhrMode = m),
                        onDayChanged: (d) =>
                            setState(() => _rhrDay = d),
                        onStartChanged: (d) =>
                            setState(() => _rhrStart = d),
                        onEndChanged: (d) =>
                            setState(() => _rhrEnd = d),
                      ),
                      const SizedBox(height: 4),
                      if (_rhrLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        FilledButton.icon(
                          onPressed: _fetchRhr,
                          icon: const Icon(Icons.monitor_heart),
                          label: const Text('Fetch Resting HR'),
                        ),
                      if (_rhrError != null) ...[
                        const SizedBox(height: 4),
                        Text(_rhrError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Skin Temperature ─────────────────────────────────
                  _SectionCard(
                    title: 'Sleep Temperature',
                    color: Colors.orange.shade50,
                    children: [
                      _buildQueryControls(
                        mode: _tempMode,
                        day: _tempDay,
                        rangeStart: _tempStart,
                        rangeEnd: _tempEnd,
                        onModeChanged: (m) =>
                            setState(() => _tempMode = m),
                        onDayChanged: (d) =>
                            setState(() => _tempDay = d),
                        onStartChanged: (d) =>
                            setState(() => _tempStart = d),
                        onEndChanged: (d) =>
                            setState(() => _tempEnd = d),
                      ),
                      const SizedBox(height: 4),
                      if (_tempLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        FilledButton.icon(
                          onPressed: _fetchTemp,
                          icon: const Icon(Icons.thermostat),
                          label: const Text('Fetch Sleep Temp'),
                        ),
                      if (_tempError != null) ...[
                        const SizedBox(height: 4),
                        Text(_tempError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12)),
                      ],
                    ],
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

// ── Shared widgets ─────────────────────────────────────────────────────────

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

// ── Result dialogs ─────────────────────────────────────────────────────────

class _RhrResultDialog extends StatelessWidget {
  const _RhrResultDialog({
    required this.label,
    required this.url,
    required this.points,
  });

  final String label;
  final String url;
  final List<GoogleHealthRestingHeartRateData> points;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('URL:\n$url\n');
    buffer.writeln('Data points: ${points.length}\n');
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      buffer.writeln('--- Point $i ---');
      buffer.writeln(
          '  date:              ${p.startTime != null ? _fmtDate(p.startTime!) : 'null'}');
      buffer.writeln('  beatsPerMinute:    ${p.beatsPerMinute}');
      buffer.writeln('  calculationMethod: ${p.calculationMethod}');
      buffer.writeln('  name: ${p.name}');
    }
    return AlertDialog(
      title: Text('Resting HR — $label'),
      content: SingleChildScrollView(
        child: SelectableText(
          buffer.toString(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _HrvResultDialog extends StatelessWidget {
  const _HrvResultDialog({
    required this.label,
    required this.url,
    required this.points,
  });

  final String label;
  final String url;
  final List<GoogleHealthHrvData> points;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('URL:\n$url\n');
    buffer.writeln('Data points: ${points.length}\n');
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      buffer.writeln('--- Point $i ---');
      buffer.writeln(
          '  date:            ${p.startTime != null ? _fmtDate(p.startTime!) : 'null'}');
      buffer.writeln('  rmssd (avg HRV): ${p.rmssd} ms');
      buffer.writeln('  nonRemBpm:       ${p.nonRemBpm}');
      buffer.writeln('  entropy:         ${p.entropy}');
      buffer.writeln('  deepSleepRmssd:  ${p.deepSleepRmssdMs} ms');
      buffer.writeln('  name: ${p.name}');
    }
    return AlertDialog(
      title: Text('HRV — $label'),
      content: SingleChildScrollView(
        child: SelectableText(
          buffer.toString(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SleepResultDialog extends StatelessWidget {
  const _SleepResultDialog({
    required this.label,
    required this.url,
    required this.sessions,
  });

  final String label;
  final String url;
  final List<GoogleHealthSleepData> sessions;

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('URL:\n$url\n');
    buffer.writeln('Sessions: ${sessions.length}\n');
    for (var i = 0; i < sessions.length; i++) {
      final s = sessions[i];
      final start =
          s.startTime != null ? _fmtTime(s.startTime!.toLocal()) : '?';
      final end = s.endTime != null ? _fmtTime(s.endTime!.toLocal()) : '?';
      buffer.writeln('--- Session $i ---');
      buffer.writeln('  type:          ${s.sleepType}');
      buffer.writeln('  interval:      $start → $end');
      buffer.writeln('  minutesAsleep: ${s.minutesAsleep}');
      buffer.writeln('  minutesAwake:  ${s.minutesAwake}');
      buffer.writeln('  inSleepPeriod: ${s.minutesInSleepPeriod}');
      buffer.writeln('  AWAKE:  ${s.awakeMinutes} min  (${s.awakeCount}x)');
      buffer.writeln('  LIGHT:  ${s.lightMinutes} min  (${s.lightCount}x)');
      buffer.writeln('  DEEP:   ${s.deepMinutes} min  (${s.deepCount}x)');
      buffer.writeln('  REM:    ${s.remMinutes} min  (${s.remCount}x)');
      buffer.writeln('  name: ${s.name}');
    }
    return AlertDialog(
      title: Text('Sleep — $label'),
      content: SingleChildScrollView(
        child: SelectableText(
          buffer.toString(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _BreathingResultDialog extends StatelessWidget {
  const _BreathingResultDialog({
    required this.label,
    required this.url,
    required this.points,
  });

  final String label;
  final String url;
  final List<GoogleHealthBreathingRateData> points;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('URL:\n$url\n');
    buffer.writeln('Data points: ${points.length}\n');
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      buffer.writeln('--- Point $i ---');
      buffer.writeln(
          '  date:             ${p.startTime != null ? _fmtDate(p.startTime!) : 'null'}');
      buffer.writeln('  breathsPerMinute: ${p.breathsPerMinute}');
      buffer.writeln('  name: ${p.name}');
    }
    return AlertDialog(
      title: Text('Breathing Rate — $label'),
      content: SingleChildScrollView(
        child: SelectableText(
          buffer.toString(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ActivityLevelResultDialog extends StatelessWidget {
  const _ActivityLevelResultDialog({
    required this.label,
    required this.amUrl,
    required this.spUrl,
    required this.activePoints,
    required this.sedentaryPoints,
  });

  final String label;
  final String amUrl;
  final String spUrl;
  final List<GoogleHealthActiveMinutesData> activePoints;
  final List<GoogleHealthSedentaryPeriodData> sedentaryPoints;

  String _fmtDuration(Duration? d) {
    if (d == null) return 'null';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('=== ACTIVE MINUTES ===');
    buffer.writeln('URL:\n$amUrl\n');
    buffer.writeln('Rollup points: ${activePoints.length}\n');
    for (var i = 0; i < activePoints.length; i++) {
      final p = activePoints[i];
      buffer.writeln('--- Day $i ---');
      buffer.writeln(
          '  date:     ${p.startTime != null ? _fmtDate(p.startTime!) : 'null'}');
      buffer.writeln('  LIGHT:    ${p.lightlyActiveMinutes ?? 0} min');
      buffer.writeln('  MODERATE: ${p.moderatelyActiveMinutes ?? 0} min');
      buffer.writeln('  VIGOROUS: ${p.veryActiveMinutes ?? 0} min');
      buffer.writeln('  total:    ${p.totalActiveMinutes ?? 0} min');
    }
    buffer.writeln('\n=== SEDENTARY PERIOD ===');
    buffer.writeln('URL:\n$spUrl\n');
    buffer.writeln('Rollup points: ${sedentaryPoints.length}\n');
    for (var i = 0; i < sedentaryPoints.length; i++) {
      final p = sedentaryPoints[i];
      buffer.writeln('--- Day $i ---');
      buffer.writeln(
          '  date:     ${p.startTime != null ? _fmtDate(p.startTime!) : 'null'}');
      buffer.writeln('  duration: ${_fmtDuration(p.duration)}');
    }
    return AlertDialog(
      title: Text('Activity — $label'),
      content: SingleChildScrollView(
        child: SelectableText(
          buffer.toString(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _StepsResultDialog extends StatelessWidget {
  const _StepsResultDialog({
    required this.label,
    required this.url,
    required this.points,
  });

  final String label;
  final String url;
  final List<GoogleHealthStepsData> points;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('URL:\n$url\n');
    buffer.writeln('Data points: ${points.length}\n');
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      buffer.writeln('--- Day $i ---');
      buffer.writeln(
          '  date:     ${p.startTime != null ? _fmtDate(p.startTime!) : 'null'}');
      buffer.writeln('  countSum: ${p.countSum}');
    }
    return AlertDialog(
      title: Text('Steps — $label'),
      content: SingleChildScrollView(
        child: SelectableText(
          buffer.toString(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _TempResultDialog extends StatelessWidget {
  const _TempResultDialog({
    required this.label,
    required this.url,
    required this.points,
  });

  final String label;
  final String url;
  final List<GoogleHealthSkinTemperatureData> points;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('URL:\n$url\n');
    buffer.writeln('Data points: ${points.length}\n');
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      buffer.writeln('--- Point $i ---');
      buffer.writeln(
          '  date:                ${p.startTime != null ? _fmtDate(p.startTime!) : 'null'}');
      buffer.writeln('  nightlyTemperature:  ${p.nightlyCelsius} °C');
      buffer.writeln('  baselineTemperature: ${p.baselineCelsius} °C');
      buffer.writeln('  relativeStddev30d:   ${p.relativeStddev30dCelsius} °C');
      buffer.writeln('  name: ${p.name}');
    }
    return AlertDialog(
      title: Text('Sleep Temp — $label'),
      content: SingleChildScrollView(
        child: SelectableText(
          buffer.toString(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _Spo2ResultDialog extends StatelessWidget {
  const _Spo2ResultDialog({
    required this.label,
    required this.url,
    required this.points,
  });

  final String label;
  final String url;
  final List<GoogleHealthOxygenSaturationData> points;

  @override
  Widget build(BuildContext context) {
    final buffer = StringBuffer();
    buffer.writeln('URL:\n$url\n');
    buffer.writeln('Data points: ${points.length}\n');
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      buffer.writeln('--- Point $i ---');
      buffer.writeln(
          '  date:                 ${p.startTime != null ? _fmtDate(p.startTime!) : 'null'}');
      buffer.writeln('  averagePercentage:    ${p.percentageAvg}');
      buffer.writeln('  lowerBoundPercentage: ${p.percentageMin}');
      buffer.writeln('  upperBoundPercentage: ${p.percentageMax}');
      buffer.writeln('  stdDev:               ${p.percentageStdDev}');
      buffer.writeln('  name: ${p.name}');
    }
    return AlertDialog(
      title: Text('SpO2 — $label'),
      content: SingleChildScrollView(
        child: SelectableText(
          buffer.toString(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
