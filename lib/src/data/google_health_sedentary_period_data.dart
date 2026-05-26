import '_parsing_helpers.dart';

/// A daily sedentary-period rollup from the Google Health
/// `sedentary-period:rollUp` API.
///
/// Each instance represents one UTC calendar-day window. [duration] is the
/// total time the user spent sedentary during that window.
///
/// The API serialises the duration as a string with a trailing `s`
/// (e.g. `"3600s"` for one hour, or `"3.5s"` for fractional seconds).
class GoogleHealthSedentaryPeriodData {
  final DateTime? startTime;
  final DateTime? endTime;

  /// Total sedentary time in the rollup window.
  final Duration? duration;

  const GoogleHealthSedentaryPeriodData({
    this.startTime,
    this.endTime,
    this.duration,
  });

  factory GoogleHealthSedentaryPeriodData.fromJson(Map<String, dynamic> json) {
    final spField = json['sedentaryPeriod'];
    final sp =
        spField is Map<String, dynamic> ? spField : const <String, dynamic>{};
    return GoogleHealthSedentaryPeriodData(
      startTime: parsePhysicalTime(json['startTime']),
      endTime: parsePhysicalTime(json['endTime']),
      duration: _parseDurationString(sp['durationSum']),
    );
  }

  /// Parses a Google Health `Duration` string ("3600s" or "3.5s") into a
  /// Dart [Duration]. Returns `null` for malformed or absent input.
  static Duration? _parseDurationString(dynamic v) {
    if (v is! String) return null;
    if (!v.endsWith('s')) return null;
    final number = double.tryParse(v.substring(0, v.length - 1));
    if (number == null) return null;
    return Duration(
      microseconds: (number * Duration.microsecondsPerSecond).round(),
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'durationSeconds': duration?.inSeconds,
      };

  @override
  String toString() => 'GoogleHealthSedentaryPeriodData(startTime: $startTime, '
      'endTime: $endTime, duration: $duration)';
}
