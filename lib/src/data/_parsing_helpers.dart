/// Internal helpers shared by data model `fromJson` factories.
///
/// Not exported from the library.
library;

/// Parses an int64 value from the API response.
///
/// The Google Health API encodes `int64` fields as JSON strings (e.g. `"5000"`)
/// to avoid precision loss in JavaScript clients. This helper handles both
/// string-encoded and numeric inputs and returns `null` for anything else.
int? parseInt64(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Parses a numeric value (double or int) from the API response, accepting
/// JSON numbers and stringified numbers.
double? parseNumber(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

/// Parses an RFC 3339 timestamp string into a [DateTime] in local time.
///
/// Returns `null` if [value] is null or cannot be parsed.
DateTime? parsePhysicalTime(dynamic value) {
  if (value is! String) return null;
  return DateTime.tryParse(value)?.toLocal();
}

/// Parses a `CivilDateTime` object (used by `dailyRollUp` responses) into a
/// local-time [DateTime].
///
/// The CivilDateTime shape is:
/// ```json
/// {"date": {"year": 2024, "month": 1, "day": 15},
///  "time": {"hours": 0, "minutes": 0, "seconds": 0, "nanos": 0}}
/// ```
///
/// Returns `null` if [value] is null or missing the `date` field.
DateTime? parseCivilDateTime(dynamic value) {
  if (value is! Map) return null;
  final date = value['date'];
  if (date is! Map) return null;
  final year = (date['year'] as num?)?.toInt();
  final month = (date['month'] as num?)?.toInt();
  final day = (date['day'] as num?)?.toInt();
  if (year == null || month == null || day == null) return null;
  final time = value['time'];
  final hours = time is Map ? (time['hours'] as num?)?.toInt() ?? 0 : 0;
  final minutes = time is Map ? (time['minutes'] as num?)?.toInt() ?? 0 : 0;
  final seconds = time is Map ? (time['seconds'] as num?)?.toInt() ?? 0 : 0;
  return DateTime(year, month, day, hours, minutes, seconds);
}

/// Serialises a [DateTime] into the `CivilDateTime` JSON shape used by
/// `dailyRollUp` requests and responses.
Map<String, dynamic> civilDateTimeToJson(DateTime dt) => {
      'date': {'year': dt.year, 'month': dt.month, 'day': dt.day},
      'time': {
        'hours': dt.hour,
        'minutes': dt.minute,
        'seconds': dt.second,
        'nanos': 0,
      },
    };
