/// A single exercise session from the Google Health API.
///
/// Each instance represents one logged exercise event with start/end
/// timestamps, activity type, and the summary metrics available for that
/// session.
class GoogleHealthExerciseData {
  /// The Google Health user ID associated with this session.
  final String? userId;

  /// Session start time in local time.
  final DateTime? startTime;

  /// Session end time in local time.
  final DateTime? endTime;

  /// Activity type identifier (e.g. `running`, `cycling`).
  final String? activityType;

  /// Session duration in milliseconds.
  final double? durationMillis;

  /// Energy expenditure for the session, in kilocalories.
  final double? calories;

  /// Distance covered during the session, in meters.
  final double? distanceMeters;

  /// Step count for the session.
  final double? steps;

  const GoogleHealthExerciseData({
    this.userId,
    this.startTime,
    this.endTime,
    this.activityType,
    this.durationMillis,
    this.calories,
    this.distanceMeters,
    this.steps,
  });

  /// Creates a [GoogleHealthExerciseData] from a raw API JSON map.
  ///
  /// The Google Health API returns exercise metrics under a nested `value`
  /// object with keys `activityType`, `durationMillis`, `calories`,
  /// `distanceMeters`, and `steps`. Top-level keys are also accepted for
  /// convenience.
  factory GoogleHealthExerciseData.fromJson(Map<String, dynamic> json) {
    final value = json['value'];
    final inner =
        value is Map<String, dynamic> ? value : const <String, dynamic>{};

    double? readDouble(String key) {
      final v = inner[key] ?? json[key];
      return (v as num?)?.toDouble();
    }

    String? readString(String key) {
      final v = inner[key] ?? json[key];
      return v as String?;
    }

    return GoogleHealthExerciseData(
      userId: json['userId'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String).toLocal()
          : null,
      activityType: readString('activityType'),
      durationMillis: readDouble('durationMillis'),
      calories: readDouble('calories'),
      distanceMeters: readDouble('distanceMeters'),
      steps: readDouble('steps'),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'value': {
          'activityType': activityType,
          'durationMillis': durationMillis,
          'calories': calories,
          'distanceMeters': distanceMeters,
          'steps': steps,
        },
      };

  @override
  String toString() => 'GoogleHealthExerciseData('
      'userId: $userId, startTime: $startTime, endTime: $endTime, '
      'activityType: $activityType, durationMillis: $durationMillis, '
      'calories: $calories, distanceMeters: $distanceMeters, steps: $steps)';
}
