import '_request_helpers.dart';
import 'google_health_api_url.dart';

/// URL builder for the Google Health `irregular-rhythm-notification` data type.
///
/// All factories produce GET requests filtered on
/// `irregular_rhythm_notification.interval.start_time` (UTC physical time).
///
/// Requires the `googlehealth.health_metrics_and_measurements.readonly` scope.
class GoogleHealthIrregularRhythmNotificationAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthIrregularRhythmNotificationAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  static const String dataType = 'irregular-rhythm-notification';

  /// Sessions whose start_time falls on [date] (UTC midnight–midnight).
  factory GoogleHealthIrregularRhythmNotificationAPIURL.day({
    required DateTime date,
  }) {
    final start = DateTime.utc(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return GoogleHealthIrregularRhythmNotificationAPIURL._build(
      startTime: start,
      endTime: end,
    );
  }

  /// Sessions whose start_time falls in the given UTC date range (inclusive).
  factory GoogleHealthIrregularRhythmNotificationAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final end = DateTime.utc(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    return GoogleHealthIrregularRhythmNotificationAPIURL._build(
      startTime: start,
      endTime: end,
    );
  }

  /// Sessions overlapping the given arbitrary UTC time window.
  factory GoogleHealthIrregularRhythmNotificationAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return GoogleHealthIrregularRhythmNotificationAPIURL._build(
      startTime: startTime,
      endTime: endTime,
    );
  }

  static GoogleHealthIrregularRhythmNotificationAPIURL _build({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final filter = buildTimeFilter(
      fieldPath: 'irregular_rhythm_notification.interval.start_time',
      startTime: startTime,
      endTime: endTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthIrregularRhythmNotificationAPIURL._(uri: uri);
  }
}
