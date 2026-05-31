import 'package:flutter_test/flutter_test.dart';
import 'package:google_flutter_health/google_flutter_health.dart';

void main() {
  group('GoogleHealthIrregularRhythmNotificationData', () {
    final fullJson = {
      'name': 'users/me/dataTypes/irregular-rhythm-notification/dataPoints/abc',
      'irregularRhythmNotification': {
        'interval': {
          'startTime': '2025-05-31T02:10:00Z',
          'endTime': '2025-05-31T02:25:00Z',
        },
        'alertWindows': [
          {
            'startTime': '2025-05-31T02:10:00Z',
            'startUtcOffset': '+02:00',
            'endTime': '2025-05-31T02:15:00Z',
            'endUtcOffset': '+02:00',
            'civilStartTime': {
              'date': {'year': 2025, 'month': 5, 'day': 31},
              'time': {'hours': 4, 'minutes': 10, 'seconds': 0, 'nanos': 0},
            },
            'civilEndTime': {
              'date': {'year': 2025, 'month': 5, 'day': 31},
              'time': {'hours': 4, 'minutes': 15, 'seconds': 0, 'nanos': 0},
            },
            'positive': true,
            'heartBeats': [
              {
                'physicalTime': '2025-05-31T02:11:00Z',
                'utcOffset': '+02:00',
                'civilTime': {
                  'date': {'year': 2025, 'month': 5, 'day': 31},
                  'time': {'hours': 4, 'minutes': 11, 'seconds': 0, 'nanos': 0},
                },
                'beatsPerMinute': 112,
              },
            ],
          },
        ],
        'medicalDeviceInfo': {
          'algorithmVersion': '2.1.0',
          'serviceVersion': '1.0',
          'firmwareVersion': '4.0.2',
          'featureVersion': '3.0',
          'deviceModel': 'Pixel Watch 2',
        },
      },
    };

    test('fromJson parses top-level fields', () {
      final data =
          GoogleHealthIrregularRhythmNotificationData.fromJson(fullJson);
      expect(
        data.name,
        'users/me/dataTypes/irregular-rhythm-notification/dataPoints/abc',
      );
      expect(data.startTime, DateTime.parse('2025-05-31T02:10:00Z').toLocal());
      expect(data.endTime, DateTime.parse('2025-05-31T02:25:00Z').toLocal());
    });

    test('fromJson parses alertWindows', () {
      final data =
          GoogleHealthIrregularRhythmNotificationData.fromJson(fullJson);
      expect(data.alertWindows, hasLength(1));
      final w = data.alertWindows.first;
      expect(w.positive, isTrue);
      expect(w.startUtcOffset, '+02:00');
      expect(
        w.startTime,
        DateTime.parse('2025-05-31T02:10:00Z').toLocal(),
      );
      expect(w.civilStartTime, DateTime(2025, 5, 31, 4, 10));
      expect(w.civilEndTime, DateTime(2025, 5, 31, 4, 15));
    });

    test('fromJson parses heartBeats inside alertWindow', () {
      final data =
          GoogleHealthIrregularRhythmNotificationData.fromJson(fullJson);
      final beats = data.alertWindows.first.heartBeats;
      expect(beats, hasLength(1));
      expect(beats.first.beatsPerMinute, 112);
      expect(
        beats.first.physicalTime,
        DateTime.parse('2025-05-31T02:11:00Z').toLocal(),
      );
      expect(beats.first.utcOffset, '+02:00');
      expect(beats.first.civilTime, DateTime(2025, 5, 31, 4, 11));
    });

    test('fromJson parses medicalDeviceInfo', () {
      final data =
          GoogleHealthIrregularRhythmNotificationData.fromJson(fullJson);
      expect(data.medicalDeviceInfo, isNotNull);
      expect(data.medicalDeviceInfo!.algorithmVersion, '2.1.0');
      expect(data.medicalDeviceInfo!.deviceModel, 'Pixel Watch 2');
      expect(data.medicalDeviceInfo!.firmwareVersion, '4.0.2');
    });

    test('fromJson handles missing irregularRhythmNotification field', () {
      final data = GoogleHealthIrregularRhythmNotificationData.fromJson(
        const <String, dynamic>{},
      );
      expect(data.name, isNull);
      expect(data.startTime, isNull);
      expect(data.alertWindows, isEmpty);
      expect(data.medicalDeviceInfo, isNull);
    });

    test('fromJson handles empty alertWindows list', () {
      final data = GoogleHealthIrregularRhythmNotificationData.fromJson({
        'name': 'users/me/dataTypes/irregular-rhythm-notification/dataPoints/x',
        'irregularRhythmNotification': {
          'interval': {
            'startTime': '2025-05-31T02:10:00Z',
            'endTime': '2025-05-31T02:25:00Z',
          },
          'alertWindows': <dynamic>[],
        },
      });
      expect(data.alertWindows, isEmpty);
    });

    test('toJson preserves scalar fields for storage', () {
      final data =
          GoogleHealthIrregularRhythmNotificationData.fromJson(fullJson);
      final json = data.toJson();
      expect(json['name'], data.name);
      expect(json['startTime'], data.startTime!.toUtc().toIso8601String());
      expect(json['endTime'], data.endTime!.toUtc().toIso8601String());
      expect(json['alertWindows'], hasLength(1));
      expect(json['medicalDeviceInfo'], isNotNull);
    });

    test('AlertWindow toJson/fromJson roundtrip', () {
      final original = GoogleHealthIrregularRhythmAlertWindow.fromJson({
        'startTime': '2025-05-31T02:10:00Z',
        'startUtcOffset': '+02:00',
        'endTime': '2025-05-31T02:15:00Z',
        'endUtcOffset': '+02:00',
        'civilStartTime': {
          'date': {'year': 2025, 'month': 5, 'day': 31},
          'time': {'hours': 4, 'minutes': 10, 'seconds': 0, 'nanos': 0},
        },
        'civilEndTime': {
          'date': {'year': 2025, 'month': 5, 'day': 31},
          'time': {'hours': 4, 'minutes': 15, 'seconds': 0, 'nanos': 0},
        },
        'positive': true,
        'heartBeats': [
          {
            'physicalTime': '2025-05-31T02:11:00Z',
            'utcOffset': '+02:00',
            'beatsPerMinute': 112,
          },
        ],
      });
      final restored =
          GoogleHealthIrregularRhythmAlertWindow.fromJson(original.toJson());
      expect(restored.startTime, original.startTime);
      expect(restored.endTime, original.endTime);
      expect(restored.startUtcOffset, original.startUtcOffset);
      expect(restored.positive, original.positive);
      expect(restored.civilStartTime, original.civilStartTime);
      expect(restored.civilEndTime, original.civilEndTime);
      expect(
        restored.heartBeats.first.beatsPerMinute,
        original.heartBeats.first.beatsPerMinute,
      );
    });

    test('HeartBeat toJson/fromJson roundtrip', () {
      final original = GoogleHealthIrregularRhythmHeartBeat.fromJson({
        'physicalTime': '2025-05-31T02:11:00Z',
        'utcOffset': '+02:00',
        'civilTime': {
          'date': {'year': 2025, 'month': 5, 'day': 31},
          'time': {'hours': 4, 'minutes': 11, 'seconds': 0, 'nanos': 0},
        },
        'beatsPerMinute': 112,
      });
      final restored =
          GoogleHealthIrregularRhythmHeartBeat.fromJson(original.toJson());
      expect(restored.physicalTime, original.physicalTime);
      expect(restored.utcOffset, original.utcOffset);
      expect(restored.civilTime, original.civilTime);
      expect(restored.beatsPerMinute, original.beatsPerMinute);
    });
  });

  group('GoogleHealthMedicalDeviceInfo', () {
    test('fromJson parses all fields', () {
      final info = GoogleHealthMedicalDeviceInfo.fromJson({
        'algorithmVersion': '1.0',
        'serviceVersion': '2.0',
        'firmwareVersion': '3.0',
        'featureVersion': '4.0',
        'deviceModel': 'Watch X',
      });
      expect(info.algorithmVersion, '1.0');
      expect(info.serviceVersion, '2.0');
      expect(info.firmwareVersion, '3.0');
      expect(info.featureVersion, '4.0');
      expect(info.deviceModel, 'Watch X');
    });

    test('fromJson handles missing fields', () {
      final info = GoogleHealthMedicalDeviceInfo.fromJson(
        const <String, dynamic>{},
      );
      expect(info.algorithmVersion, isNull);
      expect(info.deviceModel, isNull);
    });
  });
}
