class GoogleHealthHeartRateData {
  final String? userId;
  final DateTime? dateTime;
  final double? bpm;

  const GoogleHealthHeartRateData({
    this.userId,
    this.dateTime,
    this.bpm,
  });

  factory GoogleHealthHeartRateData.fromJson(Map<String, dynamic> json) {
    return GoogleHealthHeartRateData(
      userId: json['userId'] as String?,
      dateTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String).toLocal()
          : null,
      bpm: (json['value'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'startTime': dateTime?.toUtc().toIso8601String(),
        'value': bpm,
      };

  @override
  String toString() =>
      'GoogleHealthHeartRateData(userId: $userId, dateTime: $dateTime, bpm: $bpm)';
}
