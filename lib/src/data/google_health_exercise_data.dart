import '_parsing_helpers.dart';

/// A single exercise session from the Google Health API.
///
/// Each instance represents one logged exercise event with start/end
/// timestamps, activity type, and the summary metrics available for that
/// session.
class GoogleHealthExerciseData {
  final String? name;

  /// Session start time in local time.
  final DateTime? startTime;

  /// Session end time in local time.
  final DateTime? endTime;

  /// Exercise type enum value (e.g. `RUNNING`, `WALKING`, `BIKING`).
  final String? exerciseType;

  /// Human-readable display name supplied by the recording device.
  final String? displayName;

  /// Energy expenditure for the session, in kilocalories.
  final double? calories;

  /// Distance covered during the session, in meters.
  final double? distanceMeters;

  /// Step count for the session.
  final int? steps;

  const GoogleHealthExerciseData({
    this.name,
    this.startTime,
    this.endTime,
    this.exerciseType,
    this.displayName,
    this.calories,
    this.distanceMeters,
    this.steps,
  });

  /// Session duration computed from [startTime] and [endTime].
  Duration? get duration => (startTime != null && endTime != null)
      ? endTime!.difference(startTime!)
      : null;

  factory GoogleHealthExerciseData.fromJson(Map<String, dynamic> json) {
    final exField = json['exercise'];
    final ex =
        exField is Map<String, dynamic> ? exField : const <String, dynamic>{};
    final interval = ex['interval'];
    final i = interval is Map<String, dynamic>
        ? interval
        : const <String, dynamic>{};
    final summary = ex['metricsSummary'];
    final s =
        summary is Map<String, dynamic> ? summary : const <String, dynamic>{};

    return GoogleHealthExerciseData(
      name: json['name'] as String?,
      startTime: parsePhysicalTime(i['startTime']),
      endTime: parsePhysicalTime(i['endTime']),
      exerciseType: ex['exerciseType'] as String?,
      displayName: ex['displayName'] as String?,
      calories: parseNumber(s['energyKilocalories'] ?? s['calories']),
      distanceMeters: parseNumber(s['distanceMeters'] ?? s['meters']),
      steps: parseInt64(s['steps']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'exerciseType': exerciseType,
        'displayName': displayName,
        'calories': calories,
        'distanceMeters': distanceMeters,
        'steps': steps,
      };

  @override
  String toString() => 'GoogleHealthExerciseData(name: $name, '
      'startTime: $startTime, endTime: $endTime, '
      'exerciseType: $exerciseType, displayName: $displayName, '
      'calories: $calories, distanceMeters: $distanceMeters, '
      'steps: $steps)';
}
