/// A single daily oxygen saturation (SpO2) data point from the Google Health API.
///
/// SpO2 is a daily-only metric — each instance represents the average,
/// minimum, and maximum oxygen saturation for one calendar day.
class GoogleHealthOxygenSaturationData {
  /// The Google Health user ID associated with this data point.
  final String? userId;

  /// The timestamp of this data point in local time (start of the calendar day).
  final DateTime? dateTime;

  /// Average SpO2 for the day, as a percentage (0–100).
  final double? spo2Percentage;

  /// Minimum SpO2 observed during the day, as a percentage (0–100).
  final double? spo2Low;

  /// Maximum SpO2 observed during the day, as a percentage (0–100).
  final double? spo2High;

  const GoogleHealthOxygenSaturationData({
    this.userId,
    this.dateTime,
    this.spo2Percentage,
    this.spo2Low,
    this.spo2High,
  });

  /// Creates a [GoogleHealthOxygenSaturationData] from a raw API JSON map.
  ///
  /// The Google Health API returns SpO2 components under a nested `value`
  /// object with keys `spo2Percentage`, `spo2Low`, and `spo2High`. Top-level
  /// keys are also accepted for convenience.
  factory GoogleHealthOxygenSaturationData.fromJson(
    Map<String, dynamic> json,
  ) {
    final value = json['value'];
    final inner =
        value is Map<String, dynamic> ? value : const <String, dynamic>{};

    double? readDouble(String key) {
      final v = inner[key] ?? json[key];
      return (v as num?)?.toDouble();
    }

    return GoogleHealthOxygenSaturationData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      spo2Percentage: readDouble('spo2Percentage'),
      spo2Low: readDouble('spo2Low'),
      spo2High: readDouble('spo2High'),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': {
          'spo2Percentage': spo2Percentage,
          'spo2Low': spo2Low,
          'spo2High': spo2High,
        },
      };

  @override
  String toString() => 'GoogleHealthOxygenSaturationData('
      'userId: $userId, dateTime: $dateTime, '
      'spo2Percentage: $spo2Percentage, spo2Low: $spo2Low, '
      'spo2High: $spo2High)';
}
