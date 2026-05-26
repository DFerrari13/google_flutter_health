import '_parsing_helpers.dart';

/// A single daily step-count rollup from the Google Health `steps:rollUp` API.
///
/// Each instance represents one UTC calendar-day window. [countSum] is the
/// total step count for that day — equivalent to the sum of every intraday
/// interval returned by the `steps/dataPoints` list endpoint.
///
/// The [startTime] and [endTime] mark the UTC midnight boundaries of the
/// rollup window (e.g. 2024-12-28T00:00:00Z → 2024-12-29T00:00:00Z).
class GoogleHealthStepsData {
  final DateTime? startTime;
  final DateTime? endTime;

  /// Total step count for the rollup window (int64-encoded string in the API).
  final int? countSum;

  const GoogleHealthStepsData({
    this.startTime,
    this.endTime,
    this.countSum,
  });

  factory GoogleHealthStepsData.fromJson(Map<String, dynamic> json) {
    final stepsField = json['steps'];
    final steps = stepsField is Map<String, dynamic>
        ? stepsField
        : const <String, dynamic>{};
    return GoogleHealthStepsData(
      startTime: parsePhysicalTime(json['startTime']),
      endTime: parsePhysicalTime(json['endTime']),
      countSum: parseInt64(steps['countSum']),
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'countSum': countSum,
      };

  @override
  String toString() =>
      'GoogleHealthStepsData(startTime: $startTime, endTime: $endTime, '
      'countSum: $countSum)';
}
