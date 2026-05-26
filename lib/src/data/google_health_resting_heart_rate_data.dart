import '_parsing_helpers.dart';

/// A single daily resting heart rate data point from the Google Health API.
///
/// The `dailyRestingHeartRate` sub-object uses:
///   `date`                          → [startTime]
///   `beatsPerMinute`                → [beatsPerMinute]  (int64-as-string in API)
///   `dailyRestingHeartRateMetadata.calculationMethod` → [calculationMethod]
class GoogleHealthRestingHeartRateData {
  final String? name;
  final DateTime? startTime;

  /// Resting heart rate in beats per minute.
  final double? beatsPerMinute;

  /// How the resting HR was calculated.
  /// Known values: `WITH_SLEEP`, `ONLY_WITH_AWAKE_DATA`,
  /// `CALCULATION_METHOD_UNSPECIFIED`.
  final String? calculationMethod;

  const GoogleHealthRestingHeartRateData({
    this.name,
    this.startTime,
    this.beatsPerMinute,
    this.calculationMethod,
  });

  factory GoogleHealthRestingHeartRateData.fromJson(Map<String, dynamic> json) {
    final field = json['dailyRestingHeartRate'];
    final r = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    DateTime? date;
    final dateObj = r['date'];
    if (dateObj is Map) {
      final y = (dateObj['year'] as num?)?.toInt();
      final mo = (dateObj['month'] as num?)?.toInt();
      final d = (dateObj['day'] as num?)?.toInt();
      if (y != null && mo != null && d != null) date = DateTime(y, mo, d);
    }

    final meta = r['dailyRestingHeartRateMetadata'];
    final calcMethod =
        meta is Map ? meta['calculationMethod'] as String? : null;

    return GoogleHealthRestingHeartRateData(
      name: json['name'] as String?,
      startTime: date,
      beatsPerMinute: parseNumber(r['beatsPerMinute']),
      calculationMethod: calcMethod,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'date': startTime != null
            ? '${startTime!.year.toString().padLeft(4, '0')}-'
                '${startTime!.month.toString().padLeft(2, '0')}-'
                '${startTime!.day.toString().padLeft(2, '0')}'
            : null,
        'beatsPerMinute': beatsPerMinute,
        'calculationMethod': calculationMethod,
      };

  @override
  String toString() => 'GoogleHealthRestingHeartRateData(name: $name, '
      'date: $startTime, beatsPerMinute: $beatsPerMinute, '
      'calculationMethod: $calculationMethod)';
}
