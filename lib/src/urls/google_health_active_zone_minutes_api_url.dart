import 'google_health_api_url.dart';
import '_request_helpers.dart';

/// URL builder for the Google Health `active-zone-minutes` data type.
class GoogleHealthActiveZoneMinutesAPIURL extends GoogleHealthAPIURL {
  const GoogleHealthActiveZoneMinutesAPIURL._({
    required super.uri,
    required super.method,
    super.body,
  });

  /// The data-type identifier used by the Google Health API.
  static const String dataType = 'active-zone-minutes';

  /// Builds a request for a single calendar day using `dailyRollUp`.
  factory GoogleHealthActiveZoneMinutesAPIURL.day({required DateTime date}) {
    return GoogleHealthActiveZoneMinutesAPIURL.dateRange(
      startDate: date,
      endDate: date,
    );
  }

  /// Builds a request for an inclusive date range using `dailyRollUp`.
  factory GoogleHealthActiveZoneMinutesAPIURL.dateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints:dailyRollUp',
    );
    return GoogleHealthActiveZoneMinutesAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.post,
      body: buildCivilRange(
        startDate: startDate,
        endDate: exclusiveDayAfter(endDate),
      ),
    );
  }

  /// Builds a request for raw intraday active-zone-minutes intervals using
  /// `list`.
  factory GoogleHealthActiveZoneMinutesAPIURL.intraday({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final filter = buildTimeFilter(
      fieldPath: 'active_zone_minutes.interval.start_time',
      startTime: startTime,
      endTime: endTime,
    );
    final uri = Uri.https(
      'health.googleapis.com',
      '/v4/users/me/dataTypes/$dataType/dataPoints',
      {'filter': filter},
    );
    return GoogleHealthActiveZoneMinutesAPIURL._(
      uri: uri,
      method: GoogleHealthRequestMethod.get,
    );
  }
}
