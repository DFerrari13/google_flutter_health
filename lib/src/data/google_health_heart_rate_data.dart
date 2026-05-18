import '_parsing_helpers.dart';

/// A single heart rate data point from the Google Health API.
///
/// For `list` (intraday) requests, each instance represents one raw heart
/// rate sample with [beatsPerMinute] set. For `dailyRollUp` requests, each
/// instance represents the daily aggregate with
/// [beatsPerMinuteAvg], [beatsPerMinuteMin], and [beatsPerMinuteMax] set.
class GoogleHealthHeartRateData {
  /// Resource name (only set on `list` responses).
  final String? name;

  /// Sample timestamp in local time (raw `list` responses).
  ///
  /// Maps from `heart_rate.sample_time.physical_time`.
  final DateTime? sampleTime;

  /// Start of the civil-day bucket for `dailyRollUp` responses.
  final DateTime? civilStartTime;

  /// End of the civil-day bucket for `dailyRollUp` responses.
  final DateTime? civilEndTime;

  /// Beats per minute for a single sample (`list` responses).
  final int? beatsPerMinute;

  /// Average beats per minute over the civil-day bucket
  /// (`dailyRollUp` responses).
  final double? beatsPerMinuteAvg;

  /// Minimum beats per minute over the civil-day bucket
  /// (`dailyRollUp` responses).
  final double? beatsPerMinuteMin;

  /// Maximum beats per minute over the civil-day bucket
  /// (`dailyRollUp` responses).
  final double? beatsPerMinuteMax;

  const GoogleHealthHeartRateData({
    this.name,
    this.sampleTime,
    this.civilStartTime,
    this.civilEndTime,
    this.beatsPerMinute,
    this.beatsPerMinuteAvg,
    this.beatsPerMinuteMin,
    this.beatsPerMinuteMax,
  });

  /// Creates a [GoogleHealthHeartRateData] from a raw API JSON map.
  ///
  /// Auto-detects whether the JSON is a `dailyRollUp` data point (has
  /// `civilStartTime`) or a raw `list` data point.
  factory GoogleHealthHeartRateData.fromJson(Map<String, dynamic> json) {
    final hrField = json['heartRate'];
    final hr =
        hrField is Map<String, dynamic> ? hrField : const <String, dynamic>{};

    if (json.containsKey('civilStartTime')) {
      return GoogleHealthHeartRateData(
        name: json['name'] as String?,
        civilStartTime: parseCivilDateTime(json['civilStartTime']),
        civilEndTime: parseCivilDateTime(json['civilEndTime']),
        beatsPerMinuteAvg: parseNumber(hr['beatsPerMinuteAvg']),
        beatsPerMinuteMin: parseNumber(hr['beatsPerMinuteMin']),
        beatsPerMinuteMax: parseNumber(hr['beatsPerMinuteMax']),
      );
    }

    final sampleField = hr['sampleTime'];
    final sample = sampleField is Map<String, dynamic>
        ? sampleField
        : const <String, dynamic>{};
    return GoogleHealthHeartRateData(
      name: json['name'] as String?,
      sampleTime: parsePhysicalTime(sample['physicalTime']),
      beatsPerMinute: parseInt64(hr['beatsPerMinute']),
    );
  }

  /// Serialises this data point to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'name': name,
        'sampleTime': sampleTime?.toUtc().toIso8601String(),
        'civilStartTime': civilStartTime?.toUtc().toIso8601String(),
        'civilEndTime': civilEndTime?.toUtc().toIso8601String(),
        'beatsPerMinute': beatsPerMinute,
        'beatsPerMinuteAvg': beatsPerMinuteAvg,
        'beatsPerMinuteMin': beatsPerMinuteMin,
        'beatsPerMinuteMax': beatsPerMinuteMax,
      };

  @override
  String toString() => 'GoogleHealthHeartRateData('
      'name: $name, sampleTime: $sampleTime, '
      'civilStartTime: $civilStartTime, civilEndTime: $civilEndTime, '
      'beatsPerMinute: $beatsPerMinute, '
      'beatsPerMinuteAvg: $beatsPerMinuteAvg, '
      'beatsPerMinuteMin: $beatsPerMinuteMin, '
      'beatsPerMinuteMax: $beatsPerMinuteMax)';
}
