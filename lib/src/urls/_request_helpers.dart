/// Internal helpers shared by URL builders for the Google Health REST API.
///
/// Not exported from the library. Kept private so the public API surface
/// stays small and we can evolve helpers without breaking callers.
library;

/// Builds the `range` object for a `dailyRollUp` request body using
/// CivilDateTime values (date-only, no time zone).
///
/// `start` is inclusive, `end` is exclusive — to query a single day, pass
/// `endDate` as the day after the day you want.
Map<String, dynamic> buildCivilRange({
  required DateTime startDate,
  required DateTime endDate,
}) {
  return {
    'range': {
      'start': {
        'date': {
          'year': startDate.year,
          'month': startDate.month,
          'day': startDate.day,
        },
      },
      'end': {
        'date': {
          'year': endDate.year,
          'month': endDate.month,
          'day': endDate.day,
        },
      },
    },
  };
}

/// Builds the `range` object for a `rollUp` request body using
/// RFC 3339 timestamps (UTC).
Map<String, dynamic> buildPhysicalRange({
  required DateTime startTime,
  required DateTime endTime,
}) {
  return {
    'range': {
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
    },
  };
}

/// Builds a filter expression suitable for the `list` endpoint's `filter`
/// query parameter.
///
/// The expression compares an interval or sample time field against an
/// inclusive lower bound and exclusive upper bound (RFC 3339 UTC).
///
/// Example output:
/// ```
/// steps.interval.start_time >= "2024-01-01T00:00:00.000Z" AND \
/// steps.interval.start_time < "2024-01-02T00:00:00.000Z"
/// ```
String buildTimeFilter({
  required String fieldPath,
  required DateTime startTime,
  required DateTime endTime,
}) {
  final start = startTime.toUtc().toIso8601String();
  final end = endTime.toUtc().toIso8601String();
  return '$fieldPath >= "$start" AND $fieldPath < "$end"';
}

/// Adds one day to [date], used to convert an inclusive end date to the
/// exclusive end date expected by `dailyRollUp`.
DateTime exclusiveDayAfter(DateTime date) =>
    DateTime(date.year, date.month, date.day).add(const Duration(days: 1));
