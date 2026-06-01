import '_request_helpers.dart';
import 'google_health_api_url.dart';

/// URL builder for the Google Health `electrocardiogram` data type.
///
/// All factories produce GET requests filtered on
/// `electrocardiogram.interval.start_time` (UTC physical time).
///
/// The ECG endpoint only supports the `>=` operator on `start_time`; an upper
/// bound (`< end`) returns HTTP 400 "filtering by time is not supported". So
/// every factory filters on a lower bound only — results include all readings
/// at or after the start time. [day] and [dateRange] derive their start from
/// the given date(s); the end date is ignored by the API.
///
/// Requires the `googlehealth.ecg.readonly` scope
/// ([GoogleHealthScopes.ecgReadonly]).
class GoogleHealthElectrocardiogramAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthElectrocardiogramAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  static const String dataType = 'electrocardiogram';

  /// Readings whose start_time is at or after [date] (UTC midnight).
  ///
  /// The API ignores any upper bound, so this returns all readings from
  /// midnight of [date] onward, not just that calendar day.
  factory GoogleHealthElectrocardiogramAPIURL.day({required DateTime date}) {
    final start = DateTime.utc(date.year, date.month, date.day);
    return GoogleHealthElectrocardiogramAPIURL._build(startTime: start);
  }

  /// Readings whose start_time is at or after [startDate] (UTC midnight).
  ///
  /// [endDate] is accepted for API symmetry but ignored — the ECG endpoint
  /// does not support an upper time bound.
  factory GoogleHealthElectrocardiogramAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    return GoogleHealthElectrocardiogramAPIURL._build(startTime: start);
  }

  /// Readings whose start_time is at or after [startTime].
  factory GoogleHealthElectrocardiogramAPIURL.intraday({
    required DateTime startTime,
  }) {
    return GoogleHealthElectrocardiogramAPIURL._build(startTime: startTime);
  }

  static GoogleHealthElectrocardiogramAPIURL _build({
    required DateTime startTime,
  }) {
    final filter = buildStartTimeFilter(
      fieldPath: 'electrocardiogram.interval.start_time',
      startTime: startTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthElectrocardiogramAPIURL._(uri: uri);
  }
}
