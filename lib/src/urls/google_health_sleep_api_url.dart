import 'google_health_api_url.dart';

class GoogleHealthSleepAPIURL extends GoogleHealthAPIURL {
  GoogleHealthSleepAPIURL._({required super.uri});

  factory GoogleHealthSleepAPIURL.day({required DateTime date}) {
    final start = DateTime.utc(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return GoogleHealthSleepAPIURL._(
      uri: Uri.https(
        'health.googleapis.com',
        '/v4/users/me/dataTypes/sleep/dataPoints',
        {
          'startTime': start.toIso8601String(),
          'endTime': end.toIso8601String(),
        },
      ),
    );
  }

  factory GoogleHealthSleepAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final end = DateTime.utc(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    return GoogleHealthSleepAPIURL._(
      uri: Uri.https(
        'health.googleapis.com',
        '/v4/users/me/dataTypes/sleep/dataPoints',
        {
          'startTime': start.toIso8601String(),
          'endTime': end.toIso8601String(),
        },
      ),
    );
  }

  factory GoogleHealthSleepAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return GoogleHealthSleepAPIURL._(
      uri: Uri.https(
        'health.googleapis.com',
        '/v4/users/me/dataTypes/sleep/dataPoints',
        {
          'startTime': startTime.toUtc().toIso8601String(),
          'endTime': endTime.toUtc().toIso8601String(),
        },
      ),
    );
  }
}
