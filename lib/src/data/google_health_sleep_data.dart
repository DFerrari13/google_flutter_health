class GoogleHealthSleepData {
  final String? userId;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? sleepStage;

  const GoogleHealthSleepData({
    this.userId,
    this.startTime,
    this.endTime,
    this.sleepStage,
  });

  factory GoogleHealthSleepData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthSleepData(
      userId: json['userId'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String).toLocal()
          : null,
      sleepStage: json['sleepStage'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'sleepStage': sleepStage,
      };

  Duration? get duration => (startTime != null && endTime != null)
      ? endTime!.difference(startTime!)
      : null;

  @override
  String toString() =>
      'GoogleHealthSleepData(userId: $userId, startTime: $startTime, '
      'endTime: $endTime, sleepStage: $sleepStage)';
}
