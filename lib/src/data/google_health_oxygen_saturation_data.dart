import '_parsing_helpers.dart';

/// A single daily oxygen saturation (SpO2) data point from the Google Health
/// API.
///
/// The `dailyOxygenSaturation` sub-object uses:
///   `date`                       → [startTime]
///   `averagePercentage`          → [percentageAvg]
///   `lowerBoundPercentage`       → [percentageMin]
///   `upperBoundPercentage`       → [percentageMax]
///   `standardDeviationPercentage`→ [percentageStdDev] (optional)
class GoogleHealthOxygenSaturationData {
  final String? name;
  final DateTime? startTime;
  final double? percentageAvg;
  final double? percentageMin;
  final double? percentageMax;
  final double? percentageStdDev;

  const GoogleHealthOxygenSaturationData({
    this.name,
    this.startTime,
    this.percentageAvg,
    this.percentageMin,
    this.percentageMax,
    this.percentageStdDev,
  });

  factory GoogleHealthOxygenSaturationData.fromJson(Map<String, dynamic> json) {
    final field = json['dailyOxygenSaturation'];
    final o = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    DateTime? date;
    final dateObj = o['date'];
    if (dateObj is Map) {
      final y = (dateObj['year'] as num?)?.toInt();
      final mo = (dateObj['month'] as num?)?.toInt();
      final d = (dateObj['day'] as num?)?.toInt();
      if (y != null && mo != null && d != null) {
        date = DateTime(y, mo, d);
      }
    }

    return GoogleHealthOxygenSaturationData(
      name: json['name'] as String?,
      startTime: date,
      percentageAvg: parseNumber(o['averagePercentage']),
      percentageMin: parseNumber(o['lowerBoundPercentage']),
      percentageMax: parseNumber(o['upperBoundPercentage']),
      percentageStdDev: parseNumber(o['standardDeviationPercentage']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'date': startTime != null
            ? '${startTime!.year.toString().padLeft(4, '0')}-'
                '${startTime!.month.toString().padLeft(2, '0')}-'
                '${startTime!.day.toString().padLeft(2, '0')}'
            : null,
        'percentageAvg': percentageAvg,
        'percentageMin': percentageMin,
        'percentageMax': percentageMax,
        'percentageStdDev': percentageStdDev,
      };

  @override
  String toString() => 'GoogleHealthOxygenSaturationData('
      'name: $name, date: $startTime, '
      'percentageAvg: $percentageAvg, percentageMin: $percentageMin, '
      'percentageMax: $percentageMax, percentageStdDev: $percentageStdDev)';
}
