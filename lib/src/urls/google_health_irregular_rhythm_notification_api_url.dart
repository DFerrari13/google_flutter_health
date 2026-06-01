import '_request_helpers.dart';
import 'google_health_api_url.dart';

/// URL builder for the Google Health `irregular-rhythm-notification` data type.
///
/// All factories produce GET requests filtered on
/// `irregular_rhythm_notification.interval.start_time` (UTC physical time).
///
/// Like the ECG endpoint, IRN only supports the `>=` operator on `start_time`;
/// an upper bound (`< end`) returns HTTP 400 "filtering by time is not
/// supported". Every factory therefore filters on a lower bound only —
/// results include all sessions at or after the start time.
///
/// Requires the `googlehealth.irn.readonly` scope
/// ([GoogleHealthScopes.irnReadonly]).
class GoogleHealthIrregularRhythmNotificationAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthIrregularRhythmNotificationAPIURL._({required super.uri})
      : super(method: GoogleHealthRequestMethod.get);

  static const String dataType = 'irregular-rhythm-notification';

  /// Sessions whose start_time is at or after [date] (UTC midnight).
  ///
  /// The API ignores any upper bound, so this returns all sessions from
  /// midnight of [date] onward, not just that calendar day.
  factory GoogleHealthIrregularRhythmNotificationAPIURL.day({
    required DateTime date,
  }) {
    final start = DateTime.utc(date.year, date.month, date.day);
    return GoogleHealthIrregularRhythmNotificationAPIURL._build(
      startTime: start,
    );
  }

  /// Sessions whose start_time is at or after [startDate] (UTC midnight).
  ///
  /// [endDate] is accepted for API symmetry but ignored — the IRN endpoint
  /// does not support an upper time bound.
  factory GoogleHealthIrregularRhythmNotificationAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime.utc(startDate.year, startDate.month, startDate.day);
    return GoogleHealthIrregularRhythmNotificationAPIURL._build(
      startTime: start,
    );
  }

  /// Sessions whose start_time is at or after [startTime].
  factory GoogleHealthIrregularRhythmNotificationAPIURL.intraday({
    required DateTime startTime,
  }) {
    return GoogleHealthIrregularRhythmNotificationAPIURL._build(
      startTime: startTime,
    );
  }

  static GoogleHealthIrregularRhythmNotificationAPIURL _build({
    required DateTime startTime,
  }) {
    final filter = buildStartTimeFilter(
      fieldPath: 'irregular_rhythm_notification.interval.start_time',
      startTime: startTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthIrregularRhythmNotificationAPIURL._(uri: uri);
  }
}
