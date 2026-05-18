import '_parsing_helpers.dart';

/// A single step count data point from the Google Health API.
///
/// When using a `dailyRollUp` request, each instance represents the total
/// step count for one civil day. When using a `list` (intraday) request, each
/// instance represents an individual step event recorded by the device.
class GoogleHealthStepsData {
  /// Resource name of the data point, e.g.
  /// `users/me/dataTypes/steps/dataPoints/{id}`.
  ///
  /// Only present on responses from the `list` endpoint.
  final String? name;

  /// Start of this data point's interval in local time.
  ///
  /// For `dailyRollUp` results this is `civilStartTime`. For `list` results
  /// this is `steps.interval.startTime`.
  final DateTime? startTime;

  /// End of this data point's interval in local time.
  final DateTime? endTime;

  /// Step count for this data point.
  ///
  /// For `dailyRollUp` responses this is the daily `countSum` aggregate.
  /// For `list` responses this is the raw `count` for a single interval.
  final int? count;

  const GoogleHealthStepsData({
    this.name,
    this.startTime,
    this.endTime,
    this.count,
  });

  /// Creates a [GoogleHealthStepsData] from a raw API JSON map.
  ///
  /// Auto-detects whether the JSON is a `dailyRollUp` data point (has
  /// `civilStartTime`) or a raw `list` data point (has `steps.interval`).
  factory GoogleHealthStepsData.fromJson(Map<String, dynamic> json) {
    final stepsField = json['steps'];
    final steps = stepsField is Map<String, dynamic>
        ? stepsField
        : const <String, dynamic>{};

    final hasCivil = json.containsKey('civilStartTime');
    if (hasCivil) {
      return GoogleHealthStepsData(
        name: json['name'] as String?,
        startTime: parseCivilDateTime(json['civilStartTime']),
        endTime: parseCivilDateTime(json['civilEndTime']),
        count: parseInt64(steps['countSum'] ?? steps['count']),
      );
    }

    final interval = steps['interval'];
    final intervalMap =
        interval is Map<String, dynamic> ? interval : const <String, dynamic>{};
    return GoogleHealthStepsData(
      name: json['name'] as String?,
      startTime: parsePhysicalTime(intervalMap['startTime']),
      endTime: parsePhysicalTime(intervalMap['endTime']),
      count: parseInt64(steps['count']),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'count': count,
      };

  @override
  String toString() =>
      'GoogleHealthStepsData(name: $name, startTime: $startTime, '
      'endTime: $endTime, count: $count)';
}
