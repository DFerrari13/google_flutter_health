import '_parsing_helpers.dart';
import 'google_health_irregular_rhythm_notification_data.dart'
    show GoogleHealthMedicalDeviceInfo;

/// Classification of an ECG reading's rhythm
/// (`Electrocardiogram.ResultClassification`).
enum GoogleHealthEcgResultClassification {
  /// Unspecified result classification.
  unspecified,

  /// Heart rhythm appears normal ("Normal Sinus Rhythm").
  normalSinusRhythm,

  /// Signs of Atrial Fibrillation detected.
  atrialFibrillation,

  /// Reading could not be classified.
  inconclusive,

  /// Inconclusive because heart rate is high (>120 bpm).
  inconclusiveHighHeartRate,

  /// Inconclusive because heart rate is low (<50 bpm).
  inconclusiveLowHeartRate,

  /// Reading is unreadable.
  unreadable,

  /// Reading was not analyzed.
  notAnalyzed;

  /// Maps the API enum string to a [GoogleHealthEcgResultClassification].
  ///
  /// Unknown / null values map to [unspecified].
  static GoogleHealthEcgResultClassification fromApi(dynamic value) {
    switch (value) {
      case 'NORMAL_SINUS_RHYTHM':
        return GoogleHealthEcgResultClassification.normalSinusRhythm;
      case 'ATRIAL_FIBRILLATION':
        return GoogleHealthEcgResultClassification.atrialFibrillation;
      case 'INCONCLUSIVE':
        return GoogleHealthEcgResultClassification.inconclusive;
      case 'INCONCLUSIVE_HIGH_HEART_RATE':
        return GoogleHealthEcgResultClassification.inconclusiveHighHeartRate;
      case 'INCONCLUSIVE_LOW_HEART_RATE':
        return GoogleHealthEcgResultClassification.inconclusiveLowHeartRate;
      case 'UNREADABLE':
        return GoogleHealthEcgResultClassification.unreadable;
      case 'NOT_ANALYZED':
        return GoogleHealthEcgResultClassification.notAnalyzed;
      default:
        return GoogleHealthEcgResultClassification.unspecified;
    }
  }

  /// The raw API enum string for this classification.
  String get apiValue {
    switch (this) {
      case GoogleHealthEcgResultClassification.normalSinusRhythm:
        return 'NORMAL_SINUS_RHYTHM';
      case GoogleHealthEcgResultClassification.atrialFibrillation:
        return 'ATRIAL_FIBRILLATION';
      case GoogleHealthEcgResultClassification.inconclusive:
        return 'INCONCLUSIVE';
      case GoogleHealthEcgResultClassification.inconclusiveHighHeartRate:
        return 'INCONCLUSIVE_HIGH_HEART_RATE';
      case GoogleHealthEcgResultClassification.inconclusiveLowHeartRate:
        return 'INCONCLUSIVE_LOW_HEART_RATE';
      case GoogleHealthEcgResultClassification.unreadable:
        return 'UNREADABLE';
      case GoogleHealthEcgResultClassification.notAnalyzed:
        return 'NOT_ANALYZED';
      case GoogleHealthEcgResultClassification.unspecified:
        return 'RESULT_CLASSIFICATION_UNSPECIFIED';
    }
  }
}

/// A single Electrocardiogram (ECG) measurement session from the Google Health
/// API (`electrocardiogram` data type).
///
/// Each session is a single reading: [startTime] equals [endTime]. Use
/// [waveformSamples] together with [millivoltsScalingFactor] (or the
/// convenience getter [waveformMillivolts]) to plot the lead I waveform.
///
/// Requires the `googlehealth.ecg.readonly` scope
/// ([GoogleHealthScopes.ecgReadonly]).
class GoogleHealthElectrocardiogramData {
  /// Resource name of the data point.
  final String? name;

  /// Reading time (interval start). Equal to [endTime].
  final DateTime? startTime;

  /// Reading time (interval end). Equal to [startTime].
  final DateTime? endTime;

  /// Rhythm classification of the reading.
  final GoogleHealthEcgResultClassification resultClassification;

  /// Raw lead I voltage samples. Divide each by [millivoltsScalingFactor] to
  /// get millivolts. The first sample corresponds to the start of the reading.
  final List<int> waveformSamples;

  /// SaMD metadata for the device that produced the reading.
  final GoogleHealthMedicalDeviceInfo? medicalDeviceInfo;

  /// Average heart rate during the reading, in bpm.
  final int? beatsPerMinuteAvg;

  /// Sampling frequency of [waveformSamples] in hertz.
  final int? samplingFrequencyHertz;

  /// Factor to divide each waveform sample by to obtain millivolts:
  /// `millivolts = sample / millivoltsScalingFactor`.
  final int? millivoltsScalingFactor;

  /// Number of leads used for the reading.
  final int? leadNumber;

  const GoogleHealthElectrocardiogramData({
    this.name,
    this.startTime,
    this.endTime,
    this.resultClassification = GoogleHealthEcgResultClassification.unspecified,
    this.waveformSamples = const [],
    this.medicalDeviceInfo,
    this.beatsPerMinuteAvg,
    this.samplingFrequencyHertz,
    this.millivoltsScalingFactor,
    this.leadNumber,
  });

  /// Waveform samples converted to millivolts using [millivoltsScalingFactor].
  ///
  /// Returns an empty list when no scaling factor is available (cannot safely
  /// convert raw samples without it).
  List<double> get waveformMillivolts {
    final factor = millivoltsScalingFactor;
    if (factor == null || factor == 0) return const [];
    return waveformSamples.map((s) => s / factor).toList(growable: false);
  }

  /// Total reading duration derived from sample count and sampling frequency.
  Duration? get sampleDuration {
    final hz = samplingFrequencyHertz;
    if (hz == null || hz == 0 || waveformSamples.isEmpty) return null;
    final micros = (waveformSamples.length / hz * 1e6).round();
    return Duration(microseconds: micros);
  }

  factory GoogleHealthElectrocardiogramData.fromJson(
    Map<String, dynamic> json,
  ) {
    final ecgField = json['electrocardiogram'];
    final ecg =
        ecgField is Map<String, dynamic> ? ecgField : const <String, dynamic>{};

    final intervalField = ecg['interval'];
    final interval = intervalField is Map<String, dynamic>
        ? intervalField
        : const <String, dynamic>{};

    final rawSamples = ecg['waveformSamples'];
    final waveformSamples = rawSamples is List
        ? rawSamples.map(parseInt64).whereType<int>().toList(growable: false)
        : const <int>[];

    final mdiField = ecg['medicalDeviceInfo'];
    final medicalDeviceInfo = mdiField is Map<String, dynamic>
        ? GoogleHealthMedicalDeviceInfo.fromJson(mdiField)
        : null;

    return GoogleHealthElectrocardiogramData(
      name: json['name'] as String?,
      startTime: parsePhysicalTime(interval['startTime']),
      endTime: parsePhysicalTime(interval['endTime']),
      resultClassification: GoogleHealthEcgResultClassification.fromApi(
        ecg['resultClassification'],
      ),
      waveformSamples: waveformSamples,
      medicalDeviceInfo: medicalDeviceInfo,
      beatsPerMinuteAvg: parseInt64(ecg['beatsPerMinuteAvg']),
      samplingFrequencyHertz: parseInt64(ecg['samplingFrequencyHertz']),
      millivoltsScalingFactor: parseInt64(ecg['millivoltsScalingFactor']),
      leadNumber: parseInt64(ecg['leadNumber']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'resultClassification': resultClassification.apiValue,
        'waveformSamples': waveformSamples,
        'medicalDeviceInfo': medicalDeviceInfo?.toJson(),
        'beatsPerMinuteAvg': beatsPerMinuteAvg,
        'samplingFrequencyHertz': samplingFrequencyHertz,
        'millivoltsScalingFactor': millivoltsScalingFactor,
        'leadNumber': leadNumber,
      };

  @override
  String toString() => 'GoogleHealthElectrocardiogramData('
      'name: $name, startTime: $startTime, '
      'resultClassification: ${resultClassification.apiValue}, '
      'beatsPerMinuteAvg: $beatsPerMinuteAvg, '
      'samples: ${waveformSamples.length}, '
      'samplingFrequencyHertz: $samplingFrequencyHertz)';
}
