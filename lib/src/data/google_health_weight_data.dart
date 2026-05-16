/// A single weight measurement from the Google Health API.
///
/// Weight is logged sporadically — each instance represents one weigh-in
/// event with the body composition fields available at that time.
class GoogleHealthWeightData {
  /// The Google Health user ID associated with this data point.
  final String? userId;

  /// The timestamp of this measurement in local time.
  final DateTime? dateTime;

  /// Body weight in kilograms.
  final double? weightKg;

  /// Body Mass Index (BMI).
  final double? bmi;

  /// Body fat percentage (0–100).
  final double? bodyFatPercentage;

  const GoogleHealthWeightData({
    this.userId,
    this.dateTime,
    this.weightKg,
    this.bmi,
    this.bodyFatPercentage,
  });

  /// Creates a [GoogleHealthWeightData] from a raw API JSON map.
  ///
  /// The Google Health API returns weight components under a nested `value`
  /// object with keys `weightKg`, `bmi`, and `bodyFatPercentage`. Top-level
  /// keys are also accepted for convenience.
  factory GoogleHealthWeightData.fromJson(Map<String, dynamic> json) {
    final value = json['value'];
    final inner =
        value is Map<String, dynamic> ? value : const <String, dynamic>{};

    double? readDouble(String key) {
      final v = inner[key] ?? json[key];
      return (v as num?)?.toDouble();
    }

    return GoogleHealthWeightData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      weightKg: readDouble('weightKg'),
      bmi: readDouble('bmi'),
      bodyFatPercentage: readDouble('bodyFatPercentage'),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': {
          'weightKg': weightKg,
          'bmi': bmi,
          'bodyFatPercentage': bodyFatPercentage,
        },
      };

  @override
  String toString() => 'GoogleHealthWeightData('
      'userId: $userId, dateTime: $dateTime, '
      'weightKg: $weightKg, bmi: $bmi, '
      'bodyFatPercentage: $bodyFatPercentage)';
}
