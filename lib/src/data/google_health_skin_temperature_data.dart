import '_parsing_helpers.dart';

/// A single nightly sleep temperature derivation data point from the Google
/// Health API (`daily-sleep-temperature-derivations`).
class GoogleHealthSkinTemperatureData {
  final String? name;
  final DateTime? startTime;

  /// Nightly temperature in °C (`nightlyTemperatureCelsius`).
  final double? nightlyCelsius;

  /// Personal baseline temperature in °C (`baselineTemperatureCelsius`).
  final double? baselineCelsius;

  /// 30-day relative nightly std-dev in °C
  /// (`relativeNightlyStddev30dCelsius`).
  final double? relativeStddev30dCelsius;

  const GoogleHealthSkinTemperatureData({
    this.name,
    this.startTime,
    this.nightlyCelsius,
    this.baselineCelsius,
    this.relativeStddev30dCelsius,
  });

  factory GoogleHealthSkinTemperatureData.fromJson(Map<String, dynamic> json) {
    final field = json['dailySleepTemperatureDerivations'];
    final o = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    DateTime? date;
    final dateObj = o['date'];
    if (dateObj is Map) {
      final y = (dateObj['year'] as num?)?.toInt();
      final mo = (dateObj['month'] as num?)?.toInt();
      final d = (dateObj['day'] as num?)?.toInt();
      if (y != null && mo != null && d != null) date = DateTime(y, mo, d);
    }

    return GoogleHealthSkinTemperatureData(
      name: json['name'] as String?,
      startTime: date,
      nightlyCelsius: parseNumber(o['nightlyTemperatureCelsius']),
      baselineCelsius: parseNumber(o['baselineTemperatureCelsius']),
      relativeStddev30dCelsius:
          parseNumber(o['relativeNightlyStddev30dCelsius']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toIso8601String(),
        'nightlyCelsius': nightlyCelsius,
        'baselineCelsius': baselineCelsius,
        'relativeStddev30dCelsius': relativeStddev30dCelsius,
      };

  @override
  String toString() => 'GoogleHealthSkinTemperatureData('
      'name: $name, startTime: $startTime, '
      'nightlyCelsius: $nightlyCelsius, baselineCelsius: $baselineCelsius, '
      'relativeStddev30dCelsius: $relativeStddev30dCelsius)';
}
