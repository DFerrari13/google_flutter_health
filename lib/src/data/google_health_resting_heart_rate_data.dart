import '_parsing_helpers.dart';

/// A single daily resting heart rate data point from the Google Health API.
///
/// Resting heart rate is a Daily-aggregated metric. Each instance represents
/// the resting heart rate for one civil day in [beatsPerMinute].
class GoogleHealthRestingHeartRateData {
  final String? name;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? beatsPerMinute;

  const GoogleHealthRestingHeartRateData({
    this.name,
    this.startTime,
    this.endTime,
    this.beatsPerMinute,
  });

  factory GoogleHealthRestingHeartRateData.fromJson(Map<String, dynamic> json) {
    final field = json['dailyRestingHeartRate'];
    final r = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    final civilField = r['civilDateTime'] ?? r['interval'];

    DateTime? start;
    DateTime? end;
    if (civilField is Map<String, dynamic>) {
      start = parseCivilDateTime(civilField['startTime']) ??
          parsePhysicalTime(civilField['startTime']);
      end = parseCivilDateTime(civilField['endTime']) ??
          parsePhysicalTime(civilField['endTime']);
    }
    return GoogleHealthRestingHeartRateData(
      name: json['name'] as String?,
      startTime: start ??
          parseCivilDateTime(json['civilStartTime']) ??
          parsePhysicalTime(json['startTime']),
      endTime: end ??
          parseCivilDateTime(json['civilEndTime']) ??
          parsePhysicalTime(json['endTime']),
      beatsPerMinute: parseNumber(r['beatsPerMinute']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'beatsPerMinute': beatsPerMinute,
      };

  @override
  String toString() => 'GoogleHealthRestingHeartRateData(name: $name, '
      'startTime: $startTime, endTime: $endTime, '
      'beatsPerMinute: $beatsPerMinute)';
}
