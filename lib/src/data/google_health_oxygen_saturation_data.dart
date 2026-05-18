import '_parsing_helpers.dart';

/// A single daily oxygen saturation (SpO2) data point from the Google Health
/// API.
///
/// SpO2 is a Daily-aggregated metric. Each instance represents the average,
/// minimum, and maximum SpO2 for one civil day.
class GoogleHealthOxygenSaturationData {
  final String? name;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? percentageAvg;
  final double? percentageMin;
  final double? percentageMax;

  const GoogleHealthOxygenSaturationData({
    this.name,
    this.startTime,
    this.endTime,
    this.percentageAvg,
    this.percentageMin,
    this.percentageMax,
  });

  factory GoogleHealthOxygenSaturationData.fromJson(
      Map<String, dynamic> json) {
    final field = json['dailyOxygenSaturation'];
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
    return GoogleHealthOxygenSaturationData(
      name: json['name'] as String?,
      startTime: start ?? parseCivilDateTime(json['civilStartTime']),
      endTime: end ?? parseCivilDateTime(json['civilEndTime']),
      percentageAvg: parseNumber(
        o['percentageAvg'] ?? o['spo2PercentageAvg'] ?? o['percentage'],
      ),
      percentageMin:
          parseNumber(o['percentageMin'] ?? o['spo2PercentageMin']),
      percentageMax:
          parseNumber(o['percentageMax'] ?? o['spo2PercentageMax']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'percentageAvg': percentageAvg,
        'percentageMin': percentageMin,
        'percentageMax': percentageMax,
      };

  @override
  String toString() => 'GoogleHealthOxygenSaturationData(name: $name, '
      'startTime: $startTime, endTime: $endTime, '
      'percentageAvg: $percentageAvg, percentageMin: $percentageMin, '
      'percentageMax: $percentageMax)';
}
