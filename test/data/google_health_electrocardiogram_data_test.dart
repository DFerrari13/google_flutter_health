import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthEcgResultClassification', () {
    test('fromApi maps known strings', () {
      expect(
        GoogleHealthEcgResultClassification.fromApi('NORMAL_SINUS_RHYTHM'),
        GoogleHealthEcgResultClassification.normalSinusRhythm,
      );
      expect(
        GoogleHealthEcgResultClassification.fromApi('ATRIAL_FIBRILLATION'),
        GoogleHealthEcgResultClassification.atrialFibrillation,
      );
      expect(
        GoogleHealthEcgResultClassification.fromApi(
            'INCONCLUSIVE_HIGH_HEART_RATE'),
        GoogleHealthEcgResultClassification.inconclusiveHighHeartRate,
      );
      expect(
        GoogleHealthEcgResultClassification.fromApi(
            'INCONCLUSIVE_LOW_HEART_RATE'),
        GoogleHealthEcgResultClassification.inconclusiveLowHeartRate,
      );
      expect(
        GoogleHealthEcgResultClassification.fromApi('UNREADABLE'),
        GoogleHealthEcgResultClassification.unreadable,
      );
      expect(
        GoogleHealthEcgResultClassification.fromApi('NOT_ANALYZED'),
        GoogleHealthEcgResultClassification.notAnalyzed,
      );
    });

    test('fromApi maps unknown/null to unspecified', () {
      expect(
        GoogleHealthEcgResultClassification.fromApi(null),
        GoogleHealthEcgResultClassification.unspecified,
      );
      expect(
        GoogleHealthEcgResultClassification.fromApi('SOMETHING_NEW'),
        GoogleHealthEcgResultClassification.unspecified,
      );
    });

    test('apiValue roundtrips through fromApi', () {
      for (final c in GoogleHealthEcgResultClassification.values) {
        expect(
          GoogleHealthEcgResultClassification.fromApi(c.apiValue),
          c,
        );
      }
    });
  });

  group('GoogleHealthElectrocardiogramData', () {
    final fullJson = {
      'name': 'users/me/dataTypes/electrocardiogram/dataPoints/abc',
      'electrocardiogram': {
        'interval': {
          'startTime': '2025-05-31T10:00:00Z',
          'endTime': '2025-05-31T10:00:00Z',
        },
        'resultClassification': 'NORMAL_SINUS_RHYTHM',
        'waveformSamples': [0, 100, 200, -50, -100],
        'medicalDeviceInfo': {
          'firmwareVersion': '4.0.2',
          'featureVersion': '3.0',
          'deviceModel': 'Pixel Watch 2',
        },
        'beatsPerMinuteAvg': '68',
        'samplingFrequencyHertz': 500,
        'millivoltsScalingFactor': 200,
        'leadNumber': 1,
      },
    };

    test('fromJson parses all fields', () {
      final data = GoogleHealthElectrocardiogramData.fromJson(fullJson);
      expect(
        data.name,
        'users/me/dataTypes/electrocardiogram/dataPoints/abc',
      );
      expect(
        data.startTime,
        DateTime.parse('2025-05-31T10:00:00Z').toLocal(),
      );
      expect(data.startTime, data.endTime);
      expect(
        data.resultClassification,
        GoogleHealthEcgResultClassification.normalSinusRhythm,
      );
      expect(data.waveformSamples, [0, 100, 200, -50, -100]);
      expect(data.beatsPerMinuteAvg, 68);
      expect(data.samplingFrequencyHertz, 500);
      expect(data.millivoltsScalingFactor, 200);
      expect(data.leadNumber, 1);
      expect(data.medicalDeviceInfo!.deviceModel, 'Pixel Watch 2');
      expect(data.medicalDeviceInfo!.firmwareVersion, '4.0.2');
    });

    test('waveformMillivolts divides by scaling factor', () {
      final data = GoogleHealthElectrocardiogramData.fromJson(fullJson);
      expect(data.waveformMillivolts, [0.0, 0.5, 1.0, -0.25, -0.5]);
    });

    test('waveformMillivolts empty when scaling factor missing', () {
      final data = GoogleHealthElectrocardiogramData.fromJson({
        'electrocardiogram': {
          'waveformSamples': [1, 2, 3],
        },
      });
      expect(data.waveformMillivolts, isEmpty);
    });

    test('waveformMillivolts empty when scaling factor zero', () {
      final data = GoogleHealthElectrocardiogramData.fromJson({
        'electrocardiogram': {
          'waveformSamples': [1, 2, 3],
          'millivoltsScalingFactor': 0,
        },
      });
      expect(data.waveformMillivolts, isEmpty);
    });

    test('sampleDuration derived from count and frequency', () {
      final data = GoogleHealthElectrocardiogramData.fromJson({
        'electrocardiogram': {
          'waveformSamples': List<int>.filled(500, 0),
          'samplingFrequencyHertz': 500,
        },
      });
      expect(data.sampleDuration, const Duration(seconds: 1));
    });

    test('sampleDuration null when frequency missing', () {
      final data = GoogleHealthElectrocardiogramData.fromJson({
        'electrocardiogram': {
          'waveformSamples': [1, 2, 3],
        },
      });
      expect(data.sampleDuration, isNull);
    });

    test('fromJson handles missing electrocardiogram field', () {
      final data = GoogleHealthElectrocardiogramData.fromJson(
        const <String, dynamic>{},
      );
      expect(data.name, isNull);
      expect(data.startTime, isNull);
      expect(data.waveformSamples, isEmpty);
      expect(
        data.resultClassification,
        GoogleHealthEcgResultClassification.unspecified,
      );
      expect(data.medicalDeviceInfo, isNull);
    });

    test('fromJson handles string-encoded waveform samples', () {
      final data = GoogleHealthElectrocardiogramData.fromJson({
        'electrocardiogram': {
          'waveformSamples': ['10', '20', '30'],
          'millivoltsScalingFactor': 10,
        },
      });
      expect(data.waveformSamples, [10, 20, 30]);
      expect(data.waveformMillivolts, [1.0, 2.0, 3.0]);
    });

    test('toJson preserves fields for storage', () {
      final data = GoogleHealthElectrocardiogramData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['name'], data.name);
      expect(json['resultClassification'], 'NORMAL_SINUS_RHYTHM');
      expect(json['waveformSamples'], [0, 100, 200, -50, -100]);
      expect(json['beatsPerMinuteAvg'], 68);
      expect(json['samplingFrequencyHertz'], 500);
      expect(json['millivoltsScalingFactor'], 200);
      expect(json['leadNumber'], 1);
      expect(json['medicalDeviceInfo'], isNotNull);
    });
  });
}
