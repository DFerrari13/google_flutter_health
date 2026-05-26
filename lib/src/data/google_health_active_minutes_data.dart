import '_parsing_helpers.dart';

/// A daily active-minutes rollup from the Google Health
/// `active-minutes:rollUp` API.
///
/// Each instance represents one UTC calendar-day window and contains the
/// active-minutes breakdown across the three non-sedentary activity levels:
/// LIGHT, MODERATE, VIGOROUS.
///
/// Sedentary time is reported separately via `GoogleHealthSedentaryPeriodData`
/// (the `sedentary-period:rollUp` endpoint).
class GoogleHealthActiveMinutesData {
  final DateTime? startTime;
  final DateTime? endTime;
  final int? lightlyActiveMinutes;
  final int? moderatelyActiveMinutes;
  final int? veryActiveMinutes;

  const GoogleHealthActiveMinutesData({
    this.startTime,
    this.endTime,
    this.lightlyActiveMinutes,
    this.moderatelyActiveMinutes,
    this.veryActiveMinutes,
  });

  /// Sum of the three active levels, or `null` if all three are null.
  int? get totalActiveMinutes {
    if (lightlyActiveMinutes == null &&
        moderatelyActiveMinutes == null &&
        veryActiveMinutes == null) {
      return null;
    }
    return (lightlyActiveMinutes ?? 0) +
        (moderatelyActiveMinutes ?? 0) +
        (veryActiveMinutes ?? 0);
  }

  factory GoogleHealthActiveMinutesData.fromJson(Map<String, dynamic> json) {
    final amField = json['activeMinutes'];
    final am =
        amField is Map<String, dynamic> ? amField : const <String, dynamic>{};
    final raw = am['activeMinutesRollupByActivityLevel'];
    int? lightly;
    int? moderately;
    int? very;
    if (raw is List) {
      for (final entry in raw) {
        if (entry is! Map<String, dynamic>) continue;
        final level = entry['activityLevel'] as String?;
        final sum = parseInt64(entry['activeMinutesSum']);
        switch (level) {
          case 'LIGHT':
            lightly = sum;
            break;
          case 'MODERATE':
            moderately = sum;
            break;
          case 'VIGOROUS':
            very = sum;
            break;
        }
      }
    }
    return GoogleHealthActiveMinutesData(
      startTime: parsePhysicalTime(json['startTime']),
      endTime: parsePhysicalTime(json['endTime']),
      lightlyActiveMinutes: lightly,
      moderatelyActiveMinutes: moderately,
      veryActiveMinutes: very,
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'lightlyActiveMinutes': lightlyActiveMinutes,
        'moderatelyActiveMinutes': moderatelyActiveMinutes,
        'veryActiveMinutes': veryActiveMinutes,
      };

  @override
  String toString() =>
      'GoogleHealthActiveMinutesData(startTime: $startTime, endTime: $endTime, '
      'lightly: $lightlyActiveMinutes, moderately: $moderatelyActiveMinutes, '
      'very: $veryActiveMinutes)';
}
