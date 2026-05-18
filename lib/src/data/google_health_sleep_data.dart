import '_parsing_helpers.dart';

/// A sleep segment from the Google Health API.
///
/// A sleep session may contain multiple stage segments (LIGHT, DEEP, REM,
/// AWAKE). When the manager flattens a session, each stage becomes a separate
/// [GoogleHealthSleepData] instance. If the session has no stage breakdown
/// (`type: CLASSIC`), a single instance representing the whole session is
/// returned.
class GoogleHealthSleepData {
  /// Resource name of the parent sleep session (only set on `list` responses).
  final String? name;

  /// Start of this segment in local time.
  final DateTime? startTime;

  /// End of this segment in local time.
  final DateTime? endTime;

  /// Sleep stage for this segment.
  ///
  /// Typical API values: `"AWAKE"`, `"LIGHT"`, `"DEEP"`, `"REM"`, `"ASLEEP"`,
  /// `"RESTLESS"`. May be `null` for sessions without a stage breakdown.
  final String? stage;

  /// Sleep session type (`"CLASSIC"` or `"STAGES"`), if known.
  final String? sessionType;

  const GoogleHealthSleepData({
    this.name,
    this.startTime,
    this.endTime,
    this.stage,
    this.sessionType,
  });

  /// Duration of this segment.
  Duration? get duration => (startTime != null && endTime != null)
      ? endTime!.difference(startTime!)
      : null;

  /// Creates a list of [GoogleHealthSleepData] from a single API data point.
  ///
  /// If the session has `stages`, returns one entry per stage. Otherwise
  /// returns a single entry covering the whole session.
  static List<GoogleHealthSleepData> listFromJson(Map<String, dynamic> json) {
    final sleepField = json['sleep'];
    final sleep = sleepField is Map<String, dynamic>
        ? sleepField
        : const <String, dynamic>{};
    final name = json['name'] as String?;
    final sessionType = sleep['type'] as String?;
    final intervalField = sleep['interval'];
    final interval = intervalField is Map<String, dynamic>
        ? intervalField
        : const <String, dynamic>{};
    final sessionStart = parsePhysicalTime(interval['startTime']);
    final sessionEnd = parsePhysicalTime(interval['endTime']);

    final stagesField = sleep['stages'];
    final stages = stagesField is List ? stagesField : const [];
    if (stages.isEmpty) {
      return [
        GoogleHealthSleepData(
          name: name,
          startTime: sessionStart,
          endTime: sessionEnd,
          sessionType: sessionType,
        ),
      ];
    }
    return stages.whereType<Map<String, dynamic>>().map((stage) {
      final stageInterval = stage['interval'];
      final si = stageInterval is Map<String, dynamic>
          ? stageInterval
          : const <String, dynamic>{};
      return GoogleHealthSleepData(
        name: name,
        startTime: parsePhysicalTime(si['startTime']),
        endTime: parsePhysicalTime(si['endTime']),
        stage: stage['type'] as String?,
        sessionType: sessionType,
      );
    }).toList(growable: false);
  }

  /// Creates a [GoogleHealthSleepData] from a single-segment JSON map.
  ///
  /// Used when the caller has already flattened a session.
  factory GoogleHealthSleepData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthSleepData(
      name: json['name'] as String?,
      startTime: parsePhysicalTime(json['startTime']),
      endTime: parsePhysicalTime(json['endTime']),
      stage: json['stage'] as String?,
      sessionType: json['sessionType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'stage': stage,
        'sessionType': sessionType,
      };

  @override
  String toString() => 'GoogleHealthSleepData(name: $name, '
      'startTime: $startTime, endTime: $endTime, stage: $stage, '
      'sessionType: $sessionType)';
}
