import '_parsing_helpers.dart';

/// A single Active Zone Minutes data point from the Google Health API.
///
/// AZM is split into three intensity zones (fat-burn, cardio, peak). For
/// `dailyRollUp` responses each field holds the daily aggregate
/// (`...MinutesSum`). For raw `list` responses the fields hold the interval
/// values (`...Minutes`).
class GoogleHealthActiveZoneMinutesData {
  final String? name;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? fatBurnMinutes;
  final double? cardioMinutes;
  final double? peakMinutes;
  final double? totalMinutes;

  const GoogleHealthActiveZoneMinutesData({
    this.name,
    this.startTime,
    this.endTime,
    this.fatBurnMinutes,
    this.cardioMinutes,
    this.peakMinutes,
    this.totalMinutes,
  });

  factory GoogleHealthActiveZoneMinutesData.fromJson(
      Map<String, dynamic> json) {
    final field = json['activeZoneMinutes'];
    final a = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    double? pick(List<String> keys) {
      for (final key in keys) {
        final v = parseNumber(a[key]);
        if (v != null) return v;
      }
      return null;
    }

    if (json.containsKey('civilStartTime')) {
      return GoogleHealthActiveZoneMinutesData(
        name: json['name'] as String?,
        startTime: parseCivilDateTime(json['civilStartTime']),
        endTime: parseCivilDateTime(json['civilEndTime']),
        fatBurnMinutes: pick(['fatBurnMinutesSum', 'fatBurnMinutes']),
        cardioMinutes: pick(['cardioMinutesSum', 'cardioMinutes']),
        peakMinutes: pick(['peakMinutesSum', 'peakMinutes']),
        totalMinutes: pick(['totalMinutesSum', 'totalMinutes']),
      );
    }

    final intervalField = a['interval'];
    final interval = intervalField is Map<String, dynamic>
        ? intervalField
        : const <String, dynamic>{};
    return GoogleHealthActiveZoneMinutesData(
      name: json['name'] as String?,
      startTime: parsePhysicalTime(interval['startTime']),
      endTime: parsePhysicalTime(interval['endTime']),
      fatBurnMinutes: pick(['fatBurnMinutes']),
      cardioMinutes: pick(['cardioMinutes']),
      peakMinutes: pick(['peakMinutes']),
      totalMinutes: pick(['totalMinutes']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'fatBurnMinutes': fatBurnMinutes,
        'cardioMinutes': cardioMinutes,
        'peakMinutes': peakMinutes,
        'totalMinutes': totalMinutes,
      };

  @override
  String toString() => 'GoogleHealthActiveZoneMinutesData(name: $name, '
      'startTime: $startTime, endTime: $endTime, '
      'fatBurnMinutes: $fatBurnMinutes, cardioMinutes: $cardioMinutes, '
      'peakMinutes: $peakMinutes, totalMinutes: $totalMinutes)';
}
