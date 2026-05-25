import '_parsing_helpers.dart';

/// A single nightly skin temperature variation data point from the Google
/// Health API.
///
/// Skin temperature is reported as a relative variation in °C from the user's
/// personal baseline computed from prior nights. Positive values mean the
/// skin was warmer than baseline during the sleep window; negative values
/// mean cooler. Not an absolute body-temperature reading.
class GoogleHealthSkinTemperatureData {
  final String? name;
  final DateTime? startTime;
  final DateTime? endTime;
  final double? nightlyRelativeCelsius;

  const GoogleHealthSkinTemperatureData({
    this.name,
    this.startTime,
    this.endTime,
    this.nightlyRelativeCelsius,
  });

  factory GoogleHealthSkinTemperatureData.fromJson(Map<String, dynamic> json) {
    final field = json['dailySleepTemperatureDerivations'] ??
        json['dailySkinTemperatureVariation'] ??
        json['dailySkinTemperature'] ??
        json['nightlySkinTemperature'];
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
    return GoogleHealthSkinTemperatureData(
      name: json['name'] as String?,
      startTime: start ?? parseCivilDateTime(json['civilStartTime']),
      endTime: end ?? parseCivilDateTime(json['civilEndTime']),
      nightlyRelativeCelsius: parseNumber(
        o['nightlyRelativeCelsius'] ??
            o['nightlyRelative'] ??
            o['variationCelsius'] ??
            o['value'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'nightlyRelativeCelsius': nightlyRelativeCelsius,
      };

  @override
  String toString() => 'GoogleHealthSkinTemperatureData(name: $name, '
      'startTime: $startTime, endTime: $endTime, '
      'nightlyRelativeCelsius: $nightlyRelativeCelsius)';
}
