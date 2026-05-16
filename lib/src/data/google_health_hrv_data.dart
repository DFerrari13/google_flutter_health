/// A single daily heart rate variability (HRV) data point from the Google Health API.
///
/// HRV is a daily-only metric — each instance represents the computed HRV
/// measures for one calendar day.
class GoogleHealthHrvData {
  /// The Google Health user ID associated with this data point.
  final String? userId;

  /// The timestamp of this data point in local time (start of the calendar day).
  final DateTime? dateTime;

  /// Root mean square of successive differences in milliseconds (ms).
  final double? rmssd;

  /// Fraction of the day with valid HRV measurements (0.0–1.0).
  final double? coverage;

  /// High-frequency power band (ms²).
  final double? hfPower;

  /// Low-frequency power band (ms²).
  final double? lfPower;

  const GoogleHealthHrvData({
    this.userId,
    this.dateTime,
    this.rmssd,
    this.coverage,
    this.hfPower,
    this.lfPower,
  });

  /// Creates a [GoogleHealthHrvData] from a raw API JSON map.
  ///
  /// The Google Health API returns HRV components under a nested `value`
  /// object with keys `rmssd`, `coverage`, `hfPower`, and `lfPower`.
  /// Top-level keys are also accepted for convenience.
  factory GoogleHealthHrvData.fromJson(Map<String, dynamic> json) {
    final value = json['value'];
    final inner =
        value is Map<String, dynamic> ? value : const <String, dynamic>{};

    double? readDouble(String key) {
      final v = inner[key] ?? json[key];
      return (v as num?)?.toDouble();
    }

    return GoogleHealthHrvData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      rmssd: readDouble('rmssd'),
      coverage: readDouble('coverage'),
      hfPower: readDouble('hfPower'),
      lfPower: readDouble('lfPower'),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': {
          'rmssd': rmssd,
          'coverage': coverage,
          'hfPower': hfPower,
          'lfPower': lfPower,
        },
      };

  @override
  String toString() => 'GoogleHealthHrvData('
      'userId: $userId, dateTime: $dateTime, '
      'rmssd: $rmssd, coverage: $coverage, '
      'hfPower: $hfPower, lfPower: $lfPower)';
}
