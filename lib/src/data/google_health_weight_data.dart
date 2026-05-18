import '_parsing_helpers.dart';

/// A single weight measurement from the Google Health API.
///
/// For raw `list` responses each instance represents a single weigh-in.
/// For `dailyRollUp` responses each instance represents a daily aggregate
/// (avg, min, max).
class GoogleHealthWeightData {
  final String? name;

  /// Sample timestamp (raw list responses).
  final DateTime? sampleTime;

  /// Civil-day bucket start (dailyRollUp responses).
  final DateTime? civilStartTime;

  /// Civil-day bucket end (dailyRollUp responses).
  final DateTime? civilEndTime;

  /// Weight in kilograms (raw sample) or average kilograms (rollup).
  final double? weightKg;

  /// Minimum weight observed in the rollup window.
  final double? weightKgMin;

  /// Maximum weight observed in the rollup window.
  final double? weightKgMax;

  const GoogleHealthWeightData({
    this.name,
    this.sampleTime,
    this.civilStartTime,
    this.civilEndTime,
    this.weightKg,
    this.weightKgMin,
    this.weightKgMax,
  });

  factory GoogleHealthWeightData.fromJson(Map<String, dynamic> json) {
    final field = json['weight'];
    final w = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    if (json.containsKey('civilStartTime')) {
      return GoogleHealthWeightData(
        name: json['name'] as String?,
        civilStartTime: parseCivilDateTime(json['civilStartTime']),
        civilEndTime: parseCivilDateTime(json['civilEndTime']),
        weightKg: parseNumber(
          w['weightKilogramsAvg'] ?? w['weightKgAvg'] ?? w['weightKilograms'],
        ),
        weightKgMin: parseNumber(w['weightKilogramsMin'] ?? w['weightKgMin']),
        weightKgMax: parseNumber(w['weightKilogramsMax'] ?? w['weightKgMax']),
      );
    }

    final sampleField = w['sampleTime'];
    final sample = sampleField is Map<String, dynamic>
        ? sampleField
        : const <String, dynamic>{};
    return GoogleHealthWeightData(
      name: json['name'] as String?,
      sampleTime: parsePhysicalTime(sample['physicalTime']),
      weightKg: parseNumber(w['weightKilograms'] ?? w['weightKg']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sampleTime': sampleTime?.toUtc().toIso8601String(),
        'civilStartTime': civilStartTime?.toUtc().toIso8601String(),
        'civilEndTime': civilEndTime?.toUtc().toIso8601String(),
        'weightKg': weightKg,
        'weightKgMin': weightKgMin,
        'weightKgMax': weightKgMax,
      };

  @override
  String toString() => 'GoogleHealthWeightData(name: $name, '
      'sampleTime: $sampleTime, civilStartTime: $civilStartTime, '
      'civilEndTime: $civilEndTime, weightKg: $weightKg, '
      'weightKgMin: $weightKgMin, weightKgMax: $weightKgMax)';
}
