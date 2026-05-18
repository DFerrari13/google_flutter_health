import '_parsing_helpers.dart';

/// A single distance data point from the Google Health API.
///
/// For raw `list` responses [distanceMeters] holds the interval distance.
/// For `dailyRollUp` responses [distanceMeters] holds the daily sum
/// (`distanceMetersSum`).
class GoogleHealthDistanceData {
  /// Resource name (only set on `list` responses).
  final String? name;

  /// Start of this data point's interval in local time.
  final DateTime? startTime;

  /// End of this data point's interval in local time.
  final DateTime? endTime;

  /// Distance in meters.
  ///
  /// Populated from `distance.distanceMeters` (raw) or
  /// `distance.distanceMetersSum` (dailyRollUp). The parser also accepts
  /// `meters` / `metersSum` as fallback keys.
  final double? distanceMeters;

  const GoogleHealthDistanceData({
    this.name,
    this.startTime,
    this.endTime,
    this.distanceMeters,
  });

  factory GoogleHealthDistanceData.fromJson(Map<String, dynamic> json) {
    final field = json['distance'];
    final d = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    if (json.containsKey('civilStartTime')) {
      return GoogleHealthDistanceData(
        name: json['name'] as String?,
        startTime: parseCivilDateTime(json['civilStartTime']),
        endTime: parseCivilDateTime(json['civilEndTime']),
        distanceMeters: parseNumber(d['distanceMetersSum'] ??
            d['metersSum'] ??
            d['distanceMeters'] ??
            d['meters']),
      );
    }

    final intervalField = d['interval'];
    final interval = intervalField is Map<String, dynamic>
        ? intervalField
        : const <String, dynamic>{};
    return GoogleHealthDistanceData(
      name: json['name'] as String?,
      startTime: parsePhysicalTime(interval['startTime']),
      endTime: parsePhysicalTime(interval['endTime']),
      distanceMeters: parseNumber(d['distanceMeters'] ?? d['meters']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'distanceMeters': distanceMeters,
      };

  @override
  String toString() => 'GoogleHealthDistanceData(name: $name, '
      'startTime: $startTime, endTime: $endTime, '
      'distanceMeters: $distanceMeters)';
}
