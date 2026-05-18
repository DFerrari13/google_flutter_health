import '_parsing_helpers.dart';

/// A single daily heart rate variability (HRV) data point from the Google
/// Health API.
class GoogleHealthHrvData {
  final String? name;
  final DateTime? startTime;
  final DateTime? endTime;

  /// Root mean square of successive differences, in milliseconds.
  final double? rmssd;

  /// Fraction of the day with valid HRV data, between 0.0 and 1.0.
  final double? coverage;

  /// High-frequency band power, in ms^2.
  final double? hfPower;

  /// Low-frequency band power, in ms^2.
  final double? lfPower;

  const GoogleHealthHrvData({
    this.name,
    this.startTime,
    this.endTime,
    this.rmssd,
    this.coverage,
    this.hfPower,
    this.lfPower,
  });

  factory GoogleHealthHrvData.fromJson(Map<String, dynamic> json) {
    final field = json['dailyHeartRateVariability'];
    final h = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    DateTime? start;
    DateTime? end;
    final civilField = h['civilDateTime'] ?? h['interval'];
    if (civilField is Map<String, dynamic>) {
      start = parseCivilDateTime(civilField['startTime']) ??
          parsePhysicalTime(civilField['startTime']);
      end = parseCivilDateTime(civilField['endTime']) ??
          parsePhysicalTime(civilField['endTime']);
    }
    return GoogleHealthHrvData(
      name: json['name'] as String?,
      startTime: start ?? parseCivilDateTime(json['civilStartTime']),
      endTime: end ?? parseCivilDateTime(json['civilEndTime']),
      rmssd: parseNumber(h['rmssd']),
      coverage: parseNumber(h['coverage']),
      hfPower: parseNumber(h['hfPower'] ?? h['highFrequencyPower']),
      lfPower: parseNumber(h['lfPower'] ?? h['lowFrequencyPower']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'rmssd': rmssd,
        'coverage': coverage,
        'hfPower': hfPower,
        'lfPower': lfPower,
      };

  @override
  String toString() => 'GoogleHealthHrvData(name: $name, '
      'startTime: $startTime, endTime: $endTime, rmssd: $rmssd, '
      'coverage: $coverage, hfPower: $hfPower, lfPower: $lfPower)';
}
