/// A single step count data point from the Google Health API.
///
/// When using the `dailyRollup` endpoint, each instance represents the total
/// step count for one calendar day. When using the `dataPoints` list endpoint,
/// each instance represents an individual step event.
class GoogleHealthStepsData {
  /// The Google Health user ID associated with this data point.
  final String? userId;

  /// The timestamp of this data point in local time.
  ///
  /// For daily rollup results this is the start of the calendar day.
  /// For intraday results this is the start of the step event.
  final DateTime? dateTime;

  /// The step count for this data point.
  final int? value;

  const GoogleHealthStepsData({
    this.userId,
    this.dateTime,
    this.value,
  });

  /// Creates a [GoogleHealthStepsData] from a raw API JSON map.
  factory GoogleHealthStepsData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthStepsData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      value: (json['value'] as num?)?.toInt(),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': value,
      };

  @override
  String toString() =>
      'GoogleHealthStepsData(userId: $userId, dateTime: $dateTime, value: $value)';
}
