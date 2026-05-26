import '_parsing_helpers.dart';

/// A single sleep session from the Google Health API.
///
/// Each instance represents one sleep session (not a per-stage segment).
/// Non-nap filtering is performed by [GoogleHealthSleepDataManager].
///
/// Stage summary fields ([awakeMinutes], [deepMinutes], [remMinutes],
/// [lightMinutes]) come from `sleep.summary.stagesSummary`. They are `null`
/// when the API does not include a summary (older sessions or devices that do
/// not report stage data).
class GoogleHealthSleepData {
  final String? name;

  /// Session start time.
  final DateTime? startTime;

  /// Session end time.
  final DateTime? endTime;

  /// Session type: `"MAIN_SLEEP"`, `"NAP"`, or `"SLEEP_TYPE_UNSPECIFIED"`.
  final String? sleepType;

  // ── Summary totals ──────────────────────────────────────────────────────────

  /// Minutes actually asleep (excludes awake time within the session).
  final int? minutesAsleep;

  /// Minutes awake within the sleep session.
  final int? minutesAwake;

  /// Total minutes in the sleep period (in bed, including awake segments).
  final int? minutesInSleepPeriod;

  // ── Stage summary minutes ───────────────────────────────────────────────────

  final int? awakeMinutes;
  final int? deepMinutes;
  final int? remMinutes;
  final int? lightMinutes;

  // ── Stage summary counts (number of transitions into each stage) ────────────

  final int? awakeCount;
  final int? deepCount;
  final int? remCount;
  final int? lightCount;

  const GoogleHealthSleepData({
    this.name,
    this.startTime,
    this.endTime,
    this.sleepType,
    this.minutesAsleep,
    this.minutesAwake,
    this.minutesInSleepPeriod,
    this.awakeMinutes,
    this.deepMinutes,
    this.remMinutes,
    this.lightMinutes,
    this.awakeCount,
    this.deepCount,
    this.remCount,
    this.lightCount,
  });

  /// Total time in bed (session end − session start).
  Duration? get duration => (startTime != null && endTime != null)
      ? endTime!.difference(startTime!)
      : null;

  factory GoogleHealthSleepData.fromJson(Map<String, dynamic> json) {
    final sleepField = json['sleep'];
    final s = sleepField is Map<String, dynamic>
        ? sleepField
        : const <String, dynamic>{};

    // Session interval
    final intervalField = s['interval'];
    final interval = intervalField is Map<String, dynamic>
        ? intervalField
        : const <String, dynamic>{};

    // Summary
    final summaryField = s['summary'];
    final summary = summaryField is Map<String, dynamic>
        ? summaryField
        : const <String, dynamic>{};

    // Stage summaries
    int? awakeMin, deepMin, remMin, lightMin;
    int? awakeCnt, deepCnt, remCnt, lightCnt;
    final stagesField = summary['stagesSummary'];
    if (stagesField is List) {
      for (final entry in stagesField) {
        if (entry is! Map<String, dynamic>) continue;
        final type = entry['type'] as String?;
        final minutes = parseInt64(entry['minutes']);
        final count = parseInt64(entry['count']);
        switch (type) {
          case 'AWAKE':
            awakeMin = minutes;
            awakeCnt = count;
          case 'DEEP':
            deepMin = minutes;
            deepCnt = count;
          case 'REM':
            remMin = minutes;
            remCnt = count;
          case 'LIGHT':
            lightMin = minutes;
            lightCnt = count;
        }
      }
    }

    return GoogleHealthSleepData(
      name: json['name'] as String?,
      startTime: parsePhysicalTime(interval['startTime']),
      endTime: parsePhysicalTime(interval['endTime']),
      sleepType: s['type'] as String?,
      minutesAsleep: parseInt64(summary['minutesAsleep']),
      minutesAwake: parseInt64(summary['minutesAwake']),
      minutesInSleepPeriod: parseInt64(summary['minutesInSleepPeriod']),
      awakeMinutes: awakeMin,
      deepMinutes: deepMin,
      remMinutes: remMin,
      lightMinutes: lightMin,
      awakeCount: awakeCnt,
      deepCount: deepCnt,
      remCount: remCnt,
      lightCount: lightCnt,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'sleepType': sleepType,
        'minutesAsleep': minutesAsleep,
        'minutesAwake': minutesAwake,
        'minutesInSleepPeriod': minutesInSleepPeriod,
        'awakeMinutes': awakeMinutes,
        'deepMinutes': deepMinutes,
        'remMinutes': remMinutes,
        'lightMinutes': lightMinutes,
      };

  @override
  String toString() => 'GoogleHealthSleepData(name: $name, '
      'startTime: $startTime, endTime: $endTime, sleepType: $sleepType, '
      'minutesAsleep: $minutesAsleep, deep: $deepMinutes, '
      'rem: $remMinutes, light: $lightMinutes)';
}
