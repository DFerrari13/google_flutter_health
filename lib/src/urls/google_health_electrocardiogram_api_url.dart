import '_request_helpers.dart';
import 'google_health_api_url.dart';

/// URL builder for the Google Health `electrocardiogram` data type.
///
/// All factories produce GET requests filtered on
/// `electrocardiogram.interval.start_time` (UTC physical time).
///
/// Requires the `googlehealth.health_metrics_and_measurements.readonly` scope.
class GoogleHealthElectrocardiogramAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthElectrocardiogramAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  static const String dataType = 'electrocardiogram';

  /// Readings whose start_time falls on [date] (UTC midnight–midnight).
  factory GoogleHealthElectrocardiogramAPIURL.day({required DateTime date}) {
    final start = DateTime.utc(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return GoogleHealthElectrocardiogramAPIURL._build(
      startTime: start,
      endTime: end,
    );
  }

  /// Readings whose start_time falls in the given UTC date range (inclusive).
  factory GoogleHealthElectrocardiogramAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    final end = DateTime.utc(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));
    return GoogleHealthElectrocardiogramAPIURL._build(
      startTime: start,
      endTime: end,
    );
  }

  /// Readings overlapping the given arbitrary UTC time window.
  factory GoogleHealthElectrocardiogramAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return GoogleHealthElectrocardiogramAPIURL._build(
      startTime: startTime,
      endTime: endTime,
    );
  }

  static GoogleHealthElectrocardiogramAPIURL _build({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final filter = buildTimeFilter(
      fieldPath: 'electrocardiogram.interval.start_time',
      startTime: startTime,
      endTime: endTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthElectrocardiogramAPIURL._(uri: uri);
  }
}
