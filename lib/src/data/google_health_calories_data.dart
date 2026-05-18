import '_parsing_helpers.dart';

/// A single calories data point from the Google Health API
/// (`total-calories` data type).
///
/// `total-calories` only supports rollup endpoints. For `dailyRollUp`
/// responses, [calories] holds the daily sum (`energyKilocaloriesSum`).
class GoogleHealthCaloriesData {
  final String? name;
  final DateTime? startTime;
  final DateTime? endTime;

  /// Energy expenditure in kilocalories.
  final double? calories;

  const GoogleHealthCaloriesData({
    this.name,
    this.startTime,
    this.endTime,
    this.calories,
  });

  factory GoogleHealthCaloriesData.fromJson(Map<String, dynamic> json) {
    final field = json['totalCalories'];
    final t = field is Map<String, dynamic> ? field : const <String, dynamic>{};

    if (json.containsKey('civilStartTime')) {
      return GoogleHealthCaloriesData(
        name: json['name'] as String?,
        startTime: parseCivilDateTime(json['civilStartTime']),
        endTime: parseCivilDateTime(json['civilEndTime']),
        calories: parseNumber(t['energyKilocaloriesSum'] ??
            t['caloriesSum'] ??
            t['energyKilocalories'] ??
            t['calories']),
      );
    }

    return GoogleHealthCaloriesData(
      name: json['name'] as String?,
      startTime: parsePhysicalTime((json['interval'] as Map?)?['startTime']),
      endTime: parsePhysicalTime((json['interval'] as Map?)?['endTime']),
      calories: parseNumber(t['energyKilocalories'] ?? t['calories']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'calories': calories,
      };

  @override
  String toString() => 'GoogleHealthCaloriesData(name: $name, '
      'startTime: $startTime, endTime: $endTime, calories: $calories)';
}
