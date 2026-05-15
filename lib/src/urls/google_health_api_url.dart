/// Abstract base class for all Google Health API URL builders.
///
/// Each concrete subclass (e.g. [GoogleHealthStepsAPIURL]) provides
/// factory constructors that build the correct [Uri] for a given query
/// pattern (single day, date range, or intraday).
///
/// Pass an instance of a URL builder to the corresponding data manager's
/// `fetch()` method.
abstract class GoogleHealthAPIURL {
  /// The fully-qualified [Uri] for the API request.
  final Uri uri;

  const GoogleHealthAPIURL({required this.uri});
}
