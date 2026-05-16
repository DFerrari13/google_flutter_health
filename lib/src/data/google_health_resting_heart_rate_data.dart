/// A single daily resting heart rate data point from the Google Health API.
///
/// Resting heart rate is a daily-only metric — each instance represents the
/// computed resting heart rate for one calendar day.
class GoogleHealthRestingHeartRateData {
  /// The Google Health user ID associated with this data point.
  final String? userId;

  /// The timestamp of this data point in local time (start of the calendar day).
  final DateTime? dateTime;

  /// Resting heart rate in beats per minute (bpm).
  final double? beatsPerMinute;

  const GoogleHealthRestingHeartRateData({
    this.userId,
    this.dateTime,
    this.beatsPerMinute,
  });

  /// Creates a [GoogleHealthRestingHeartRateData] from a raw API JSON map.
  factory GoogleHealthRestingHeartRateData.fromJson(
    Map<String, dynamic> json,
  ) {
    return GoogleHealthRestingHeartRateData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      beatsPerMinute: (json['value'] as num?)?.toDouble(),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': beatsPerMinute,
      };

  @override
  String toString() => 'GoogleHealthRestingHeartRateData('
      'userId: $userId, dateTime: $dateTime, beatsPerMinute: $beatsPerMinute)';
}
