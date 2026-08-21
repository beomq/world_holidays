# Migration Guide

## 2.0.1 to 2.1.2

Version 2.1.2 keeps the main 2.0.1 method signatures, but 2.1.0 introduced
stricter parsing, immutable package results, structured update outcomes, and
cache-aware asynchronous queries. Review the behavioral changes below before
upgrading.

### Upgrade the dependency

```yaml
dependencies:
  world_holidays: ^2.1.2
```

```bash
fvm flutter pub upgrade world_holidays
```

The following 2.0.1 calls remain source-compatible:

```dart
await worldHolidays.getHolidays('KR');
await worldHolidays.updateHolidays(countryCode: 'KR');
worldHolidays.isHoliday('KR', date);
worldHolidays.isTodayHoliday('KR');
worldHolidays.getNextHoliday('KR');
await worldHolidays.clearCache();
```

`Holiday.description` was already `Map<String, String>?` in 2.0.1. Its type
has not changed.

### Stop mutating package results

Lists returned by the package and description maps decoded by the package are
immutable in 2.1.2. Copy them before making changes:

```dart
final mutableHolidays = [
  ...await worldHolidays.getHolidays('KR'),
];
final mutableDescription = {
  ...?holiday.description,
};
```

Code that only reads these values needs no change.

### Handle unknown holiday types

`HolidayType.fromString()` and `Holiday.fromJson()` now throw
`FormatException` for an unknown wire value. In 2.0.1, an unknown value was
silently decoded as `HolidayType.national`.

```dart
try {
  final holiday = Holiday.fromJson(untrustedJson);
} on FormatException catch (error) {
  // Reject or report the invalid external payload.
}
```

Package cache and hosted-update reads catch invalid payloads and fall back to
bundled data. This change mainly affects callers that decode external JSON
directly.

### Choose how holiday data stays current

For most apps, use offline-first stale-while-revalidate:

1. Render `getHolidays()` output immediately; it reads cache or bundle data.
2. At app startup or resume, refresh only when the previous attempt is old.
3. Replace application state only when `outcome.succeeded` is true.
4. On failure, keep the local list already displayed.

A 24-hour interval is the recommended default. Persist the last attempt time in
application storage and let a manual refresh bypass the interval.

```dart
final worldHolidays = WorldHolidays();

try {
  var visible = await worldHolidays.getHolidays('KR');
  final outcome = await worldHolidays.updateCountryHolidays('KR');
  if (outcome.succeeded) {
    visible = outcome.holidays;
  }
  // Keep `visible` unchanged when the update fails.
} finally {
  worldHolidays.dispose();
}
```

Do not replace existing cached data with `outcome.holidays` after a failed
update because the failure outcome contains bundled fallback data, which can be
older than the cache already displayed. Do not query GitHub Pages per date or
calendar cell; keep the successful list in application state and index it by
`dateString`.

Neither `getHolidays()` nor cache expiry starts a network request. An older
package can consume a compatible data-only hosted update, while new Dart APIs
or wire-format changes still require a package upgrade.

Apps that must remain fully offline should upgrade the package and use
`isHoliday()`, `isTodayHoliday()`, and `getNextHoliday()`, which always read the
bundled snapshot.

### Roll out the corrected Korean data

The SharedPreferences key, payload shape, and seven-day expiry are compatible
with 2.0.1. Therefore, a previously cached Korean payload can remain visible
after the package upgrade.

- `isHoliday()` and `getNextHoliday()` use the corrected 2.1.2 bundle
  immediately.
- A successful `updateCountryHolidays('KR')` replaces the existing cache.
- To guarantee bundled data without relying on the network, clear the old
  cache before calling `getHolidays()`:

```dart
final worldHolidays = WorldHolidays();

try {
  await worldHolidays.clearCache();
  final holidays = await worldHolidays.getHolidays('KR');
} finally {
  worldHolidays.dispose();
}
```

The corrected Korean data includes:

- 2024-09-19: removed false Chuseok substitute holiday
- 2025-01-27: Temporary Public Holiday
- 2025-01-31: removed false Lunar New Year substitute holiday
- 2026-05-01: Labor Day
- 2026-06-03: Local Election
- 2026-07-17: Constitution Day
- 2027-07-19: Alternative holiday for Constitution Day

### Prefer structured update outcomes

`updateHolidays()` remains available as a compatibility adapter returning
`List<Holiday>`. New code can use structured outcomes to distinguish a remote
success from bundled fallback:

```dart
final country = await worldHolidays.updateCountryHolidays('KR');
print(country.source);
print(country.error);

final bulk = await worldHolidays.updateAllHolidays();
print(bulk.successfulCountries);
print(bulk.failedCountries);
```

Bulk updates now attempt every supported country. A failure for one country no
longer prevents later countries from updating.

### Dispose the service

`WorldHolidays` now owns an HTTP client by default. Dispose long-lived service
instances when their owner is destroyed:

```dart
final worldHolidays = WorldHolidays();

try {
  // Use the service.
} finally {
  worldHolidays.dispose();
}
```

When an HTTP client is injected through the constructor, the caller retains
ownership of that client.

### Other additions

- Bundled coverage expands from 2024-2026 to 2024-2028.
- `getHolidaysInRange()` provides an inclusive cache-aware range query.
- `CountryUpdateOutcome` and `BulkUpdateOutcome` expose update source and
  failure details.
