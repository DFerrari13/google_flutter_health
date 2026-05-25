import '_parsing_helpers.dart';

/// A single daily breathing rate (respiratory rate) data point from the
/// Google Health API.
///
/// Breathing rate is a Daily-aggregated metric. Each instance represents the
/// average, minimum, and maximum breaths per minute for one civil day.
class GoogleHealthBreathingRateData {
  final String? name;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? breathsPerMinuteAvg;
  final double? breathsPerMinuteMin;
  final double? breathsPerMinuteMax;

  const GoogleHealthBreathingRateData({
    this.name,
    this.startTime,
    this.endTime,
    this.breathsPerMinuteAvg,
    this.breathsPerMinuteMin,
    this.breathsPerMinuteMax,
  });

  factory GoogleHealthBreathingRateData.fromJson(Map<String, dynamic> json) {
    final field = json['dailyBreathingRate'] ?? json['dailyRespiratoryRate'];
    final o = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    DateTime? start;
    DateTime? end;
    final civilField = o['civilDateTime'] ?? o['interval'];
    if (civilField is Map<String, dynamic>) {
      start = parseCivilDateTime(civilField['startTime']) ??
          parsePhysicalTime(civilField['startTime']);
      end = parseCivilDateTime(civilField['endTime']) ??
          parsePhysicalTime(civilField['endTime']);
    }
    return GoogleHealthBreathingRateData(
      name: json['name'] as String?,
      startTime: start ?? parseCivilDateTime(json['civilStartTime']),
      endTime: end ?? parseCivilDateTime(json['civilEndTime']),
      breathsPerMinuteAvg: parseNumber(
        o['breathsPerMinuteAvg'] ?? o['rateAvg'] ?? o['breathsPerMinute'],
      ),
      breathsPerMinuteMin:
          parseNumber(o['breathsPerMinuteMin'] ?? o['rateMin']),
      breathsPerMinuteMax:
          parseNumber(o['breathsPerMinuteMax'] ?? o['rateMax']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'breathsPerMinuteAvg': breathsPerMinuteAvg,
        'breathsPerMinuteMin': breathsPerMinuteMin,
        'breathsPerMinuteMax': breathsPerMinuteMax,
      };

  @override
  String toString() => 'GoogleHealthBreathingRateData(name: $name, '
      'startTime: $startTime, endTime: $endTime, '
      'breathsPerMinuteAvg: $breathsPerMinuteAvg, '
      'breathsPerMinuteMin: $breathsPerMinuteMin, '
      'breathsPerMinuteMax: $breathsPerMinuteMax)';
}
