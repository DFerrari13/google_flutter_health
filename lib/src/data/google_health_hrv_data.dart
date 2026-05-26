import '_parsing_helpers.dart';

/// A single daily heart rate variability (HRV) data point from the Google
/// Health API.
///
/// The `dailyHeartRateVariability` sub-object uses:
///   `date`                                                    → [startTime]
///   `averageHeartRateVariabilityMilliseconds`                 → [rmssd]
///   `nonRemHeartRateBeatsPerMinute`                           → [nonRemBpm]
///   `entropy`                                                 → [entropy]
///   `deepSleepRootMeanSquareOfSuccessiveDifferencesMilliseconds` → [deepSleepRmssdMs]
class GoogleHealthHrvData {
  final String? name;
  final DateTime? startTime;

  /// Average HRV during sleep, in milliseconds (RMSSD proxy).
  final double? rmssd;

  /// Average heart rate during non-REM sleep, in beats per minute.
  final int? nonRemBpm;

  /// Entropy of the HRV signal.
  final double? entropy;

  /// RMSSD computed only during deep sleep, in milliseconds.
  final double? deepSleepRmssdMs;

  const GoogleHealthHrvData({
    this.name,
    this.startTime,
    this.rmssd,
    this.nonRemBpm,
    this.entropy,
    this.deepSleepRmssdMs,
  });

  factory GoogleHealthHrvData.fromJson(Map<String, dynamic> json) {
    final field = json['dailyHeartRateVariability'];
    final h = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    DateTime? date;
    final dateObj = h['date'];
    if (dateObj is Map) {
      final y = (dateObj['year'] as num?)?.toInt();
      final mo = (dateObj['month'] as num?)?.toInt();
      final d = (dateObj['day'] as num?)?.toInt();
      if (y != null && mo != null && d != null) date = DateTime(y, mo, d);
    }

    return GoogleHealthHrvData(
      name: json['name'] as String?,
      startTime: date,
      rmssd: parseNumber(h['averageHeartRateVariabilityMilliseconds']),
      nonRemBpm: parseInt64(h['nonRemHeartRateBeatsPerMinute']),
      entropy: parseNumber(h['entropy']),
      deepSleepRmssdMs: parseNumber(
        h['deepSleepRootMeanSquareOfSuccessiveDifferencesMilliseconds'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'date': startTime != null
            ? '${startTime!.year.toString().padLeft(4, '0')}-'
                '${startTime!.month.toString().padLeft(2, '0')}-'
                '${startTime!.day.toString().padLeft(2, '0')}'
            : null,
        'rmssd': rmssd,
        'nonRemBpm': nonRemBpm,
        'entropy': entropy,
        'deepSleepRmssdMs': deepSleepRmssdMs,
      };

  @override
  String toString() => 'GoogleHealthHrvData(name: $name, date: $startTime, '
      'rmssd: $rmssd, nonRemBpm: $nonRemBpm, entropy: $entropy, '
      'deepSleepRmssdMs: $deepSleepRmssdMs)';
}
