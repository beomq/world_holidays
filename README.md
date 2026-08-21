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

## Basic lookup

```dart
final worldHolidays = WorldHolidays();

// Fresh seven-day cache first, then bundled generated data.
final koreanHolidays = await worldHolidays.getHolidays('KR', year: 2027);

final newYear = worldHolidays.isHoliday('KR', DateTime(2027, 1, 1));
final nextBundled = worldHolidays.getNextHoliday('JP');
```

`getHolidays()` does not make a network request automatically. Networking is
always explicit through an update method.

## Explicit hosted updates

Use structured outcomes when the caller needs to distinguish remote success
from bundled fallback.

```dart
final outcome = await worldHolidays.updateCountryHolidays('KR');

if (outcome.succeeded) {
  print('Downloaded ${outcome.holidays.length} records');
} else {
  print('Using ${outcome.source}: ${outcome.error}');
}

final bulk = await worldHolidays.updateAllHolidays();
print('Updated: ${bulk.successfulCountries}');
print('Fallback: ${bulk.failedCountries}');
```

A bulk update attempts every supported country. One failed country no longer
aborts later updates. `updateHolidays()` remains as a compatibility adapter that
returns only the flattened holiday list.

## Cache-aware queries

The original synchronous query methods remain deterministic and use bundled
data. Use their asynchronous counterparts after an online update.

```dart
await worldHolidays.updateCountryHolidays('US');

final isHoliday = await worldHolidays.isHolidayAsync(
  'US',
  DateTime(2027, 7, 5),
);
final next = await worldHolidays.getNextHolidayAsync('US');
final today = await worldHolidays.isTodayHolidayAsync('US');
```

Inclusive date ranges are also cache-aware:

```dart
final holidays = await worldHolidays.getHolidaysInRange(
  'KR',
  DateTime(2027, 1, 1),
  DateTime(2027, 12, 31),
);
```

Passing an end date before the start date throws `ArgumentError`.

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
