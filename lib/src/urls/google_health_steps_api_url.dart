import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health steps data type.
///
/// Use the factory constructors to build the appropriate request, then pass
/// the instance to `GoogleHealthStepsDataManager.fetch`.
///
/// The Google Health REST API uses three different methods for time-series
/// data:
///
///  * `dailyRollUp` (POST) — aggregates one civil-day bucket per day.
///  * `rollUp` (POST) — aggregates over fixed physical-time windows.
///  * `list` (GET) — returns raw data points within a time range.
///
/// ```dart
/// // Today's step count (daily roll-up).
/// final url = GoogleHealthStepsAPIURL.day(date: DateTime.now());
///
/// // Step count over a date range (daily roll-up).
/// final url = GoogleHealthStepsAPIURL.dateRange(
///   startDate: DateTime(2024, 1, 1),
///   endDate: DateTime(2024, 1, 31),
/// );
///
/// // Raw intraday step events (list).
/// final url = GoogleHealthStepsAPIURL.intraday(
///   startTime: DateTime.now().subtract(const Duration(hours: 1)),
///   endTime: DateTime.now(),
/// );
/// ```
class GoogleHealthStepsAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthStepsAPIURL._({
    required super.uri,
    required super.method,
    super.body,
  });

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'steps';

  /// Builds a request for a single calendar day using `dailyRollUp`.
  ///
  /// - [date]: The day to query. Time components are ignored.
  factory GoogleHealthStepsAPIURL.day({required DateTime date}) {
    return GoogleHealthStepsAPIURL.dateRange(startDate: date, endDate: date);
  }

  /// Builds a request for an inclusive date range using `dailyRollUp`.
  ///
  /// Returns one rolled-up data point per civil day.
  factory GoogleHealthStepsAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints:dailyRollUp',
    );
    final body = buildCivilRange(
      startDate: startDate,
      endDate: exclusiveDayAfter(endDate),
    );
    return GoogleHealthStepsAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.post,
      body: body,
    );
  }

  /// Builds a request for raw intraday step events using `list`.
  ///
  /// Returns individual step events within the given time window.
  factory GoogleHealthStepsAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final filter = buildTimeFilter(
      fieldPath: '$dataType.interval.start_time',
      startTime: startTime,
      endTime: endTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthStepsAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.get,
    );
  }
}
