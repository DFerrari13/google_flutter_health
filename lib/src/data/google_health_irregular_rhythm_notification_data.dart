import '_parsing_helpers.dart';

/// Software as Medical Device (SaMD) metadata embedded in an
/// [GoogleHealthIrregularRhythmNotificationData] record.
class GoogleHealthMedicalDeviceInfo {
  final String? algorithmVersion;
  final String? serviceVersion;
  final String? firmwareVersion;
  final String? featureVersion;
  final String? deviceModel;

  const GoogleHealthMedicalDeviceInfo({
    this.algorithmVersion,
    this.serviceVersion,
    this.firmwareVersion,
    this.featureVersion,
    this.deviceModel,
  });

  factory GoogleHealthMedicalDeviceInfo.fromJson(Map<String, dynamic> json) {
    return GoogleHealthMedicalDeviceInfo(
      algorithmVersion: json['algorithmVersion'] as String?,
      serviceVersion: json['serviceVersion'] as String?,
      firmwareVersion: json['firmwareVersion'] as String?,
      featureVersion: json['featureVersion'] as String?,
      deviceModel: json['deviceModel'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'algorithmVersion': algorithmVersion,
        'serviceVersion': serviceVersion,
        'firmwareVersion': firmwareVersion,
        'featureVersion': featureVersion,
        'deviceModel': deviceModel,
      };

  @override
  String toString() => 'GoogleHealthMedicalDeviceInfo('
      'algorithmVersion: $algorithmVersion, deviceModel: $deviceModel)';
}

/// A single heart beat sample within an AFib analysis window.
class GoogleHealthIrregularRhythmHeartBeat {
  /// RFC 3339 physical timestamp of the beat.
  final DateTime? physicalTime;

  /// UTC offset string (e.g. `+02:00`).
  final String? utcOffset;

  /// Civil (local) time of the beat.
  final DateTime? civilTime;

  /// Heart rate at this beat in bpm.
  final int? beatsPerMinute;

  const GoogleHealthIrregularRhythmHeartBeat({
    this.physicalTime,
    this.utcOffset,
    this.civilTime,
    this.beatsPerMinute,
  });

  factory GoogleHealthIrregularRhythmHeartBeat.fromJson(
    Map<String, dynamic> json,
  ) {
    return GoogleHealthIrregularRhythmHeartBeat(
      physicalTime: parsePhysicalTime(json['physicalTime']),
      utcOffset: json['utcOffset'] as String?,
      civilTime: parseCivilDateTime(json['civilTime']),
      beatsPerMinute: parseInt64(json['beatsPerMinute']),
    );
  }

  Map<String, dynamic> toJson() => {
        'physicalTime': physicalTime?.toUtc().toIso8601String(),
        'utcOffset': utcOffset,
        'civilTime': civilTime != null ? civilDateTimeToJson(civilTime!) : null,
        'beatsPerMinute': beatsPerMinute,
      };

  @override
  String toString() => 'GoogleHealthIrregularRhythmHeartBeat('
      'physicalTime: $physicalTime, beatsPerMinute: $beatsPerMinute)';
}

/// An analysis window evaluated for AFib within an IRN session.
///
/// [positive] is always `true` in data returned by the API — the algorithm
/// only stores windows that triggered an alert.
class GoogleHealthIrregularRhythmAlertWindow {
  /// Physical start time of the window (RFC 3339).
  final DateTime? startTime;
  final String? startUtcOffset;

  /// Physical end time of the window (RFC 3339).
  final DateTime? endTime;
  final String? endUtcOffset;

  /// Civil (local) start time.
  final DateTime? civilStartTime;

  /// Civil (local) end time.
  final DateTime? civilEndTime;

  /// Whether this window tested positive for AFib. Always `true` in API data.
  final bool? positive;

  /// Heart beat samples recorded during this window.
  final List<GoogleHealthIrregularRhythmHeartBeat> heartBeats;

  const GoogleHealthIrregularRhythmAlertWindow({
    this.startTime,
    this.startUtcOffset,
    this.endTime,
    this.endUtcOffset,
    this.civilStartTime,
    this.civilEndTime,
    this.positive,
    this.heartBeats = const [],
  });

  factory GoogleHealthIrregularRhythmAlertWindow.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawBeats = json['heartBeats'];
    final heartBeats = rawBeats is List
        ? rawBeats
            .whereType<Map<String, dynamic>>()
            .map(GoogleHealthIrregularRhythmHeartBeat.fromJson)
            .toList(growable: false)
        : const <GoogleHealthIrregularRhythmHeartBeat>[];

    return GoogleHealthIrregularRhythmAlertWindow(
      startTime: parsePhysicalTime(json['startTime']),
      startUtcOffset: json['startUtcOffset'] as String?,
      endTime: parsePhysicalTime(json['endTime']),
      endUtcOffset: json['endUtcOffset'] as String?,
      civilStartTime: parseCivilDateTime(json['civilStartTime']),
      civilEndTime: parseCivilDateTime(json['civilEndTime']),
      positive: json['positive'] as bool?,
      heartBeats: heartBeats,
    );
  }

  Map<String, dynamic> toJson() => {
        'startTime': startTime?.toUtc().toIso8601String(),
        'startUtcOffset': startUtcOffset,
        'endTime': endTime?.toUtc().toIso8601String(),
        'endUtcOffset': endUtcOffset,
        'civilStartTime': civilStartTime != null
            ? civilDateTimeToJson(civilStartTime!)
            : null,
        'civilEndTime':
            civilEndTime != null ? civilDateTimeToJson(civilEndTime!) : null,
        'positive': positive,
        'heartBeats': heartBeats.map((b) => b.toJson()).toList(),
      };

  @override
  String toString() => 'GoogleHealthIrregularRhythmAlertWindow('
      'startTime: $startTime, endTime: $endTime, '
      'positive: $positive, heartBeats: ${heartBeats.length})';
}

/// A single Irregular Rhythm Notification (IRN) data point from the Google
/// Health API (`irregular-rhythm-notification` data type).
///
/// An IRN indicates a potential sign of atrial fibrillation (AFib) detected
/// by a wearable SaMD algorithm.
///
/// Requires the `googlehealth.irn.readonly` scope
/// ([GoogleHealthScopes.irnReadonly]).
class GoogleHealthIrregularRhythmNotificationData {
  /// Resource name of the data point.
  final String? name;

  /// Session start time (from `irregularRhythmNotification.interval.startTime`).
  final DateTime? startTime;

  /// Session end time (from `irregularRhythmNotification.interval.endTime`).
  final DateTime? endTime;

  /// Analysis windows evaluated during the session.
  final List<GoogleHealthIrregularRhythmAlertWindow> alertWindows;

  /// SaMD metadata for the algorithm and device that produced this alert.
  final GoogleHealthMedicalDeviceInfo? medicalDeviceInfo;

  const GoogleHealthIrregularRhythmNotificationData({
    this.name,
    this.startTime,
    this.endTime,
    this.alertWindows = const [],
    this.medicalDeviceInfo,
  });

  factory GoogleHealthIrregularRhythmNotificationData.fromJson(
    Map<String, dynamic> json,
  ) {
    final irnField = json['irregularRhythmNotification'];
    final irn =
        irnField is Map<String, dynamic> ? irnField : const <String, dynamic>{};

    final intervalField = irn['interval'];
    final interval = intervalField is Map<String, dynamic>
        ? intervalField
        : const <String, dynamic>{};

    final rawWindows = irn['alertWindows'];
    final alertWindows = rawWindows is List
        ? rawWindows
            .whereType<Map<String, dynamic>>()
            .map(GoogleHealthIrregularRhythmAlertWindow.fromJson)
            .toList(growable: false)
        : const <GoogleHealthIrregularRhythmAlertWindow>[];

    final mdiField = irn['medicalDeviceInfo'];
    final medicalDeviceInfo = mdiField is Map<String, dynamic>
        ? GoogleHealthMedicalDeviceInfo.fromJson(mdiField)
        : null;

    return GoogleHealthIrregularRhythmNotificationData(
      name: json['name'] as String?,
      startTime: parsePhysicalTime(interval['startTime']),
      endTime: parsePhysicalTime(interval['endTime']),
      alertWindows: alertWindows,
      medicalDeviceInfo: medicalDeviceInfo,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'alertWindows': alertWindows.map((w) => w.toJson()).toList(),
        'medicalDeviceInfo': medicalDeviceInfo?.toJson(),
      };

  @override
  String toString() => 'GoogleHealthIrregularRhythmNotificationData('
      'name: $name, startTime: $startTime, endTime: $endTime, '
      'alertWindows: ${alertWindows.length})';
}
