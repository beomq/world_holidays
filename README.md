# World Holidays

Generated holiday data for Flutter applications, with bundled offline lookup and
optional hosted updates.

[![pub package](https://img.shields.io/pub/v/world_holidays.svg)](https://pub.dev/packages/world_holidays)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[Live calendar and hosted API](https://beomq.github.io/world_holidays/) ·
[API metadata](https://beomq.github.io/world_holidays/api/countries.json) ·
[Issue tracker](https://github.com/beomq/world_holidays/issues)

## Coverage

Version 2.1.2 contains 842 records for 2024-2028.

| Country | Code | Records |
| --- | --- | ---: |
| South Korea | `KR` | 99 |
| United States | `US` | 62 |
| Japan | `JP` | 90 |
| China | `CN` | 120 |
| Vietnam | `VN` | 73 |
| Malaysia | `MY` | 73 |
| Thailand | `TH` | 111 |
| Canada | `CA` | 45 |
| Brazil | `BR` | 71 |
| Taiwan | `TW` | 98 |

Future dates can change after government announcements. Treat generated future
records as planning data and apply reviewed overrides for temporary or substitute
holidays.

## Hosted API

The same generated records are published through GitHub Pages:

```text
https://beomq.github.io/world_holidays/api/countries.json
https://beomq.github.io/world_holidays/api/holidays/kr.json
```

Country metadata includes the canonical `dataUrl` for every supported payload.
The [live calendar](https://beomq.github.io/world_holidays/) consumes these
files directly.

## Installation

```yaml
dependencies:
  world_holidays: ^2.1.2
```

```dart
import 'package:world_holidays/world_holidays.dart';
```

## Keeping holiday data current

For most apps, use an offline-first, stale-while-revalidate flow:

1. Read cache or bundled data and render it immediately.
2. At app startup or resume, refresh only when the last attempt is stale.
3. Replace visible data only when the hosted update succeeds.
4. Keep the existing local data when the network request fails.

GitHub Pages is a static distribution source, not a per-query backend. Do not
request it for every date or every calendar cell. A 24-hour refresh interval is
the recommended default, with a manual refresh action when users need it.

```dart
const holidayRefreshInterval = Duration(hours: 24);

Future<List<Holiday>> loadCurrentHolidays({
  required WorldHolidays worldHolidays,
  required String countryCode,
  required DateTime? lastRefreshAttempt,
  required void Function(DateTime value) recordRefreshAttempt,
  required void Function(List<Holiday> holidays) publish,
  DateTime Function()? now,
}) async {
  // Fast local path: fresh cache first, otherwise the bundled snapshot.
  final local = await worldHolidays.getHolidays(countryCode);
  publish(local);

  final checkedAt = (now ?? DateTime.now)();
  final recentlyAttempted = lastRefreshAttempt != null &&
      checkedAt.difference(lastRefreshAttempt) < holidayRefreshInterval;
  if (recentlyAttempted) {
    return local;
  }

  // Record the attempt in app storage so startup/resume cannot hammer Pages.
  recordRefreshAttempt(checkedAt);
  final outcome = await worldHolidays.updateCountryHolidays(countryCode);

  if (!outcome.succeeded) {
    // Keep the cache or bundle already shown. The fallback in outcome.holidays
    // may be older than a previously cached payload.
    return local;
  }

  // Use the exact payload downloaded by this call, even if cache persistence
  // later becomes unavailable.
  publish(outcome.holidays);
  return outcome.holidays;
}
```

Persist `lastRefreshAttempt` with the application's existing settings or state
storage. Call this loader at cold start and when the app returns to the
foreground. Pass `null` for `lastRefreshAttempt` to implement a user-initiated
"Refresh now" action.

The library already supports every operation used by this flow:

- `getHolidays()` reads a valid seven-day cache or the bundled snapshot.
- `updateCountryHolidays()` explicitly downloads and caches hosted JSON.
- `CountryUpdateOutcome.succeeded` distinguishes remote success from fallback.
- `CountryUpdateOutcome.holidays` provides the exact downloaded list on success.

`getHolidays()` never starts a network request, and cache expiry falls back to
the bundle instead of downloading. A compatible data-only hosted update can
reach an older installed package; new Dart APIs or wire-format changes still
require a package upgrade.

For a calendar, keep the returned list in application state and index it once
instead of calling an asynchronous query for every cell:

```dart
final holidaysByDate = {
  for (final holiday in visibleHolidays) holiday.dateString: holiday,
};
final holiday = holidaysByDate['2025-01-27'];
```

### Fully offline alternative

If the app must never access the network, upgrade the package and use the
synchronous bundled queries:

```bash
fvm flutter pub upgrade world_holidays
```

```dart
final worldHolidays = WorldHolidays();

try {
  final isHoliday = worldHolidays.isHoliday(
    'KR',
    DateTime(2025, 1, 27),
  );
  final nextHoliday = worldHolidays.getNextHoliday('KR');
} finally {
  worldHolidays.dispose();
}
```

The synchronous methods always use the installed package snapshot. After a
package upgrade, call `clearCache()` only when `getHolidays()` must ignore an
older cached payload and use the new bundle immediately.

## Cache-aware query helpers

After a successful hosted refresh has populated the cache, one-off queries can
use the asynchronous helpers:

```dart
final isHoliday = await worldHolidays.isHolidayAsync(
  'KR',
  DateTime(2025, 1, 27),
);
final today = await worldHolidays.isTodayHolidayAsync('KR');
final next = await worldHolidays.getNextHolidayAsync('KR');
final range = await worldHolidays.getHolidaysInRange(
  'KR',
  DateTime(2025, 1, 1),
  DateTime(2025, 12, 31),
);
```

For a full calendar, indexing the successful `outcome.holidays` list once is
more efficient than calling an asynchronous helper for every cell. Range query
boundaries are inclusive; an end date before the start date throws
`ArgumentError`.

## Holiday model

Descriptions use an English/Korean map:

```dart
final holiday = koreanHolidays.first;
print(holiday.descriptionEn);
print(holiday.descriptionKo);
print(holiday.getDescription('ko'));
```

Legacy JSON string descriptions still decode as English. Unknown holiday type
wire values throw `FormatException` instead of silently becoming national
holidays. Returned lists and descriptions decoded by the package are immutable.

## Cache behavior

- SharedPreferences key: `world_holidays_<lowercase-country-code>`
- Expiry: seven days
- Cached payload: complete country response; year/range filtering happens when read
- Cache expiry causes bundled fallback; it does not trigger a network request
- Expired, malformed, or invalid-type cache entries fall back to bundled data
- `clearCache()` removes all package cache entries

## Data generation

The project does not scrape or republish a third-party holiday portal. It runs
the MIT-licensed [python-holidays](https://github.com/vacanza/holidays/) library
locally and combines calculated years with reviewed project data.

- `api/holidays/*.json`: hosted payloads and reviewed curated years
- `data/overrides.json`: curated-year ownership, corrections, removals, upserts
- `lib/src/generated/holiday_data.g.dart`: generated bundled lookup data
- `api/countries.json`: generated counts and supported years

```bash
# Generate previous year, current year, and the following two years.
uv run --no-project tool/sync_holidays.py

# Verify checked-in outputs without changing the repository.
uv run --no-project tool/sync_holidays.py --check

# Reproduce a specific horizon.
uv run --no-project tool/sync_holidays.py --current-year 2026
```

Existing curated historical years are retained. Non-curated years are rebuilt
from the installed `python-holidays` version on every synchronization.

Recommended operation:

- Weekly synchronization throughout the year
- Review `data/curated-drift.json` for calculated dates missing from curated years
- Manual workflow dispatch after temporary-holiday announcements
- Review every generated pull request before publishing

## Development

```bash
fvm flutter pub get
fvm dart format --output=none --set-exit-if-changed \
  lib/world_holidays.dart lib/src/models lib/src/world_holidays.dart test example
fvm flutter analyze --no-pub
fvm flutter test --no-pub
uv run --no-project tool/sync_holidays.py --check
fvm flutter pub publish --dry-run
```

## Upgrading from 2.1.1

Version 2.1.2 changes holiday data only. No Dart API migration is required.

```bash
fvm flutter pub upgrade world_holidays
```

- Synchronous `isHoliday()` and `getNextHoliday()` calls use corrected bundled
  data after the package upgrade.
- Cache-aware callers can apply the hosted correction immediately with
  `await worldHolidays.updateCountryHolidays('KR')`.
- `getHolidays()` still does not access the network automatically. Without an
  explicit update, an existing cached payload remains valid for up to seven
  days before bundled data is used. Call `clearCache()` when corrected bundled
  data must be used immediately without relying on the network.

The Korean corrections remove the false 2024-09-19 and 2025-01-31 substitute
holidays and add the official 2025-01-27 temporary public holiday.

## Migrating from 2.0.x

See the [2.0.1 to 2.1.2 migration guide](MIGRATION.md) for the complete
compatibility and rollout checklist.

The main 2.0.1 lookup and update signatures remain source-compatible. Review
immutable package results, strict unknown-type parsing, cache rollout, and
service disposal before upgrading.

## License

This package is released under the MIT License. Generated baseline dates use the
MIT-licensed `python-holidays` project; reviewed corrections remain in this
repository.
