import 'holiday.dart';

/// Identifies which data source produced an update outcome.
enum HolidayDataSource {
  /// Bundled generated data used as a fallback.
  bundled,

  /// A fresh SharedPreferences cache entry.
  cache,

  /// A successful hosted API response.
  remote,
}

/// Result of updating one country.
class CountryUpdateOutcome {
  /// Country code represented by this outcome.
  final String countryCode;

  /// Source that supplied [holidays].
  final HolidayDataSource source;

  /// Immutable holiday result.
  final List<Holiday> holidays;

  /// Failure description when bundled fallback was required.
  final String? error;

  /// Creates an immutable country update result.
  CountryUpdateOutcome({
    required this.countryCode,
    required this.source,
    required List<Holiday> holidays,
    this.error,
  }) : holidays = List.unmodifiable(holidays);

  /// Whether the hosted update succeeded.
  bool get succeeded => source == HolidayDataSource.remote;
}

/// Result of attempting to update every supported country.
class BulkUpdateOutcome {
  /// Immutable results in supported-country order.
  final List<CountryUpdateOutcome> results;

  /// Creates an immutable bulk update result.
  BulkUpdateOutcome(List<CountryUpdateOutcome> results)
      : results = List.unmodifiable(results);

  /// Country codes updated from the hosted API.
  List<String> get successfulCountries => List.unmodifiable(
        results
            .where((result) => result.succeeded)
            .map((result) => result.countryCode),
      );

  /// Country codes that required bundled fallback.
  List<String> get failedCountries => List.unmodifiable(
        results
            .where((result) => !result.succeeded)
            .map((result) => result.countryCode),
      );

  /// Whether every country update succeeded.
  bool get allSucceeded => results.every((result) => result.succeeded);

  /// Immutable flattened holiday results.
  List<Holiday> get holidays =>
      List.unmodifiable(results.expand((result) => result.holidays));
}
