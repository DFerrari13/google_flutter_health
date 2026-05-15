class GoogleHealthStepsData {
  final String? userId;
  final DateTime? dateTime;
  final int? value;

  const GoogleHealthStepsData({
    this.userId,
    this.dateTime,
    this.value,
  });

  factory GoogleHealthStepsData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthStepsData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      value: (json['value'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': value,
      };

  @override
  String toString() =>
      'GoogleHealthStepsData(userId: $userId, dateTime: $dateTime, value: $value)';
}
