/// A single heart rate data point from the Google Health API.
///
/// When using the `dailyRollup` endpoint, each instance represents the resting
/// heart rate for one calendar day. When using the `dataPoints` list endpoint,
/// each instance represents an individual heart rate measurement.
class GoogleHealthHeartRateData {
  /// The Google Health user ID associated with this data point.
  final String? userId;

  /// The timestamp of this data point in local time.
  final DateTime? dateTime;

  /// Heart rate in beats per minute (bpm).
  final double? bpm;

  const GoogleHealthHeartRateData({
    this.userId,
    this.dateTime,
    this.bpm,
  });

  /// Creates a [GoogleHealthHeartRateData] from a raw API JSON map.
  factory GoogleHealthHeartRateData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthHeartRateData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      bpm: (json['value'] as num?)?.toDouble(),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': bpm,
      };

  @override
  String toString() =>
      'GoogleHealthHeartRateData(userId: $userId, dateTime: $dateTime, bpm: $bpm)';
}
