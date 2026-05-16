/// A single Active Zone Minutes (AZM) data point from the Google Health API.
///
/// When using the `dailyRollup` endpoint, each instance represents the total
/// minutes spent in each heart rate zone for one calendar day. When using the
/// `dataPoints` list endpoint, each instance represents an individual AZM
/// event.
class GoogleHealthActiveZoneMinutesData {
  /// The Google Health user ID associated with this data point.
  final String? userId;

  /// The timestamp of this data point in local time.
  final DateTime? dateTime;

  /// Minutes spent in the fat-burn heart rate zone.
  final double? fatBurnMinutes;

  /// Minutes spent in the cardio heart rate zone.
  final double? cardioMinutes;

  /// Minutes spent in the peak heart rate zone.
  final double? peakMinutes;

  /// Total active zone minutes across all zones.
  final double? totalMinutes;

  const GoogleHealthActiveZoneMinutesData({
    this.userId,
    this.dateTime,
    this.fatBurnMinutes,
    this.cardioMinutes,
    this.peakMinutes,
    this.totalMinutes,
  });

  /// Creates a [GoogleHealthActiveZoneMinutesData] from a raw API JSON map.
  ///
  /// The Google Health API returns AZM components under a nested `value`
  /// object with keys `fatBurnMinutes`, `cardioMinutes`, `peakMinutes`, and
  /// `totalMinutes`. Top-level keys are also accepted for convenience.
  factory GoogleHealthActiveZoneMinutesData.fromJson(
    Map<String, dynamic> json,
  ) {
    final value = json['value'];
    final inner =
        value is Map<String, dynamic> ? value : const <String, dynamic>{};

    double? readDouble(String key) {
      final v = inner[key] ?? json[key];
      return (v as num?)?.toDouble();
    }

    return GoogleHealthActiveZoneMinutesData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      fatBurnMinutes: readDouble('fatBurnMinutes'),
      cardioMinutes: readDouble('cardioMinutes'),
      peakMinutes: readDouble('peakMinutes'),
      totalMinutes: readDouble('totalMinutes'),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  ///
  /// AZM components are nested under `value` to match the API response shape.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': {
          'fatBurnMinutes': fatBurnMinutes,
          'cardioMinutes': cardioMinutes,
          'peakMinutes': peakMinutes,
          'totalMinutes': totalMinutes,
        },
      };

  @override
  String toString() => 'GoogleHealthActiveZoneMinutesData('
      'userId: $userId, dateTime: $dateTime, '
      'fatBurnMinutes: $fatBurnMinutes, cardioMinutes: $cardioMinutes, '
      'peakMinutes: $peakMinutes, totalMinutes: $totalMinutes)';
}
