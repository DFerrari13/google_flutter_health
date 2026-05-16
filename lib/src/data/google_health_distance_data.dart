/// A single distance data point from the Google Health API.
///
/// When using the `dailyRollup` endpoint, each instance represents the total
/// distance for one calendar day. When using the `dataPoints` list endpoint,
/// each instance represents an individual distance event.
class GoogleHealthDistanceData {
  /// The Google Health user ID associated with this data point.
  final String? userId;

  /// The timestamp of this data point in local time.
  ///
  /// For daily rollup results this is the start of the calendar day.
  /// For intraday results this is the start of the distance event.
  final DateTime? dateTime;

  /// The distance for this data point, in meters.
  final double? distanceMeters;

  const GoogleHealthDistanceData({
    this.userId,
    this.dateTime,
    this.distanceMeters,
  });

  /// Creates a [GoogleHealthDistanceData] from a raw API JSON map.
  factory GoogleHealthDistanceData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthDistanceData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      distanceMeters: (json['value'] as num?)?.toDouble(),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': distanceMeters,
      };

  @override
  String toString() =>
      'GoogleHealthDistanceData(userId: $userId, dateTime: $dateTime, '
      'distanceMeters: $distanceMeters)';
}
