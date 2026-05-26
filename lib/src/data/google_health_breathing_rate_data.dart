import '_parsing_helpers.dart';

/// A single daily respiratory rate data point from the Google Health API
/// (`daily-respiratory-rate`).
class GoogleHealthBreathingRateData {
  final String? name;
  final DateTime? startTime;

  /// Average breaths per minute for the night (`breathsPerMinute`).
  final double? breathsPerMinute;

  const GoogleHealthBreathingRateData({
    this.name,
    this.startTime,
    this.breathsPerMinute,
  });

  factory GoogleHealthBreathingRateData.fromJson(Map<String, dynamic> json) {
    final field = json['dailyRespiratoryRate'];
    final o = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    DateTime? date;
    final dateObj = o['date'];
    if (dateObj is Map) {
      final y = (dateObj['year'] as num?)?.toInt();
      final mo = (dateObj['month'] as num?)?.toInt();
      final d = (dateObj['day'] as num?)?.toInt();
      if (y != null && mo != null && d != null) date = DateTime(y, mo, d);
    }

    return GoogleHealthBreathingRateData(
      name: json['name'] as String?,
      startTime: date,
      breathsPerMinute: parseNumber(o['breathsPerMinute']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toIso8601String(),
        'breathsPerMinute': breathsPerMinute,
      };

  @override
  String toString() => 'GoogleHealthBreathingRateData(name: $name, '
      'startTime: $startTime, breathsPerMinute: $breathsPerMinute)';
}
