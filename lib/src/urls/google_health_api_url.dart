/// HTTP method used by a [GoogleHealthAPIURL].
///
/// The Google Health REST API uses GET for the `list` and `get` methods and
/// POST for the custom `rollUp`, `dailyRollUp`, and `batchDelete` methods.
enum GoogleHealthRequestMethod {
  /// Standard GET request — used for `list`, `get`, and resource reads.
  get,

  /// POST request — used for custom methods such as `dailyRollUp` and `rollUp`
  /// where the time range is sent in the request body.
  post,
}

/// Abstract base class for all Google Health API URL builders.
///
/// Each concrete subclass (e.g. [GoogleHealthStepsAPIURL]) provides factory
/// constructors that build the correct [Uri] for a given query pattern (single
/// day, date range, or intraday) along with the appropriate HTTP [method] and
/// optional request [body].
///
/// Pass an instance of a URL builder to the corresponding data manager's
/// `fetch()` method.
abstract class GoogleHealthAPIURL {
  /// The fully-qualified [Uri] for the API request.
  final Uri uri;

  /// HTTP method to use when sending the request.
  ///
  /// Defaults to [GoogleHealthRequestMethod.get]. The custom `dailyRollUp`
  /// and `rollUp` methods use [GoogleHealthRequestMethod.post] with the time
  /// range in the request body.
  final GoogleHealthRequestMethod method;

  /// Optional JSON-encodable body sent with POST requests.
  ///
  /// `null` for GET requests. For POST requests this is serialised as the
  /// request body with `Content-Type: application/json`.
  final Map<String, dynamic>? body;

  const GoogleHealthAPIURL({
    required this.uri,
    this.method = GoogleHealthRequestMethod.get,
    this.body,
  });
}
