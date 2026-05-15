/// A single sleep stage segment from the Google Health API.
///
/// A full night's sleep consists of multiple overlapping segments, each
/// representing a period in a particular sleep stage (light, deep, REM, awake).
/// Use [duration] to calculate how long the user spent in each stage.
class GoogleHealthSleepData {
  /// The Google Health user ID associated with this segment.
  final String? userId;

  /// The start time of this sleep segment in local time.
  final DateTime? startTime;

  /// The end time of this sleep segment in local time.
  final DateTime? endTime;

  /// The sleep stage for this segment.
  ///
  /// Typical values returned by the API: `"light"`, `"deep"`, `"rem"`, `"awake"`.
  /// May be `null` if the API does not provide stage information.
  final String? sleepStage;

  const GoogleHealthSleepData({
    this.userId,
    this.startTime,
    this.endTime,
    this.sleepStage,
  });

  /// Creates a [GoogleHealthSleepData] from a raw API JSON map.
  factory GoogleHealthSleepData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthSleepData(
      userId: json['userId'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String).toLocal()
          : null,
      sleepStage: json['sleepStage'] as String?,
    );
  }

  /// Serialises this segment to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'sleepStage': sleepStage,
      };

  /// The duration of this sleep segment.
  ///
  /// Returns `null` if either [startTime] or [endTime] is unavailable.
  Duration? get duration => (startTime != null && endTime != null)
      ? endTime!.difference(startTime!)
      : null;

  @override
  String toString() =>
      'GoogleHealthSleepData(userId: $userId, startTime: $startTime, '
      'endTime: $endTime, sleepStage: $sleepStage)';
}
