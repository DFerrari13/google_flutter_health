/// A single calories data point from the Google Health API.
///
/// When using the `dailyRollup` endpoint, each instance represents the total
/// energy expenditure for one calendar day. When using the `dataPoints` list
/// endpoint, each instance represents an individual calories event.
class GoogleHealthCaloriesData {
  /// The Google Health user ID associated with this data point.
  final String? userId;

  /// The timestamp of this data point in local time.
  ///
  /// For daily rollup results this is the start of the calendar day.
  /// For intraday results this is the start of the calories event.
  final DateTime? dateTime;

  /// The total energy expenditure for this data point, in kilocalories.
  final double? calories;

  const GoogleHealthCaloriesData({
    this.userId,
    this.dateTime,
    this.calories,
  });

  /// Creates a [GoogleHealthCaloriesData] from a raw API JSON map.
  factory GoogleHealthCaloriesData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthCaloriesData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      calories: (json['value'] as num?)?.toDouble(),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': calories,
      };

  @override
  String toString() =>
      'GoogleHealthCaloriesData(userId: $userId, dateTime: $dateTime, '
      'calories: $calories)';
}
