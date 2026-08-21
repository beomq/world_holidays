# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Require official source metadata for reviewed holiday removals.

### Fixed

- Removed South Korea's incorrect 2024-09-19 Chuseok substitute holiday.
- Added South Korea's 2025-01-27 temporary public holiday.
- Removed South Korea's incorrect 2025-01-31 Lunar New Year substitute holiday.

## [2.1.1] - 2026-08-21

### Added

- Added official source metadata for every reviewed holiday upsert.
- Added a generated curated-year drift report so newly calculated public
  holiday dates trigger review instead of being hidden by authoritative data.
- Added a dedicated holiday-correction issue form.

### Changed

- Run the current holiday synchronization workflow weekly throughout the year.

### Fixed

- Added South Korea's 2026 Labor Day on May 1.
- Added South Korea's 2026 Constitution Day on July 17 following its
  reinstatement as a public holiday.
- Preserved the 2026 local election and the existing 2027 Constitution Day
  substitute holiday.

### Migration

- No API migration is required from 2.1.0.
- For 2.0.1 users, follow the
  [2.0.1 to 2.1.1 migration guide](MIGRATION.md).
- Upgrade the package for corrected synchronous bundled queries.
- Call `updateCountryHolidays('KR')` to replace a cached Korean payload
  immediately after the hosted API is deployed.

## [2.1.0] - 2026-08-21

### Added

- Generated 2027-2028 public holidays, extending bundled coverage to
  2024-2028 with 841 records across 10 countries.
- Added the local `python-holidays` synchronization pipeline, reviewed
  overrides, deterministic tests, and synchronized hosted/Dart outputs.
- Added `updateCountryHolidays()` and `updateAllHolidays()` with structured
  source, success, fallback, and error results.
- Added cache-aware `isHolidayAsync()`, `isTodayHolidayAsync()`, and
  `getNextHolidayAsync()` methods.
- Added the inclusive `getHolidaysInRange()` query.

### Changed

- Unknown holiday type values now throw `FormatException` instead of silently
  decoding as `NATIONAL`.
- Package-produced lists and decoded description maps are immutable.
- `updateHolidays()` now delegates to structured update methods and preserves
  successful countries when another country fails.
- Documentation now distinguishes bundled synchronous queries from
  cache-aware asynchronous queries and explicit networking.

### Fixed

- Recomputed all hosted payload, country, and aggregate holiday counts.
- Made hosted JSON and bundled Dart data deterministic generated outputs.
- Updated GitHub Pages metadata, examples, and year labels for 2024-2028.
- Updated stale country tests, multilingual description tests, and the Flutter
  example to compile against the 2.x description model.

### Migration

- Use `descriptionEn`, `descriptionKo`, or `getDescription()` instead of
  treating `Holiday.description` as a string.
- Catch `FormatException` when decoding untrusted type values.
- Prefer structured update methods when callers need partial-failure details.

## [2.0.1] - 2025-12-05

### Fixed

- 🇰🇷 **Updated KR Holidays**: Added missing 2026 holidays (삼일절 대체휴일, 대체휴일, 지방선거, 광복절 대체휴일, 개천절 대체휴일)
- 📅 **Data Sync**: Synchronized KR holidays data with kr.json API

## [2.0.0] - 2025-09-12

### Added

- 🌍 **6 New Countries**: China (CN), Vietnam (VN), Malaysia (MY), Thailand (TH), Canada (CA), Brazil (BR), Taiwan (TW)
- 🌐 **Multilingual Support**: English and Korean descriptions for all holidays
- 📊 **Expanded Coverage**: 508 total holidays across 10 countries
- 🔄 **Enhanced Data Structure**: Multilingual description objects with `en` and `ko` fields
- 🛠️ **Auto-Generation**: Python script for automatic Dart code generation from JSON data

### Changed

- 📈 **Increased Scale**: From 4 countries to 10 countries
- 📅 **More Holidays**: From 178 to 508 total holidays
- 🔧 **Improved API**: Enhanced Holiday model with multilingual description support
- 📖 **Updated Documentation**: All examples and documentation reflect new countries and features

### Technical Improvements

- 🐍 **Python Automation**: JSON to Dart code generation script
- 🔄 **Data Consistency**: Unified data structure across all countries
- 🌐 **Web Interface**: Updated HTML interface with new countries and multilingual support
- 📊 **Better Statistics**: Real-time country and holiday counts

### Data Coverage

- 🇨🇳 China: 72 holidays (includes Lunar holidays and Golden Week)
- 🇻🇳 Vietnam: 44 holidays (includes Lunar holidays and national observances)
- 🇲🇾 Malaysia: 44 holidays (includes multi-cultural and religious holidays)
- 🇹🇭 Thailand: 61 holidays (includes Buddhist and royal holidays)
- 🇨🇦 Canada: 33 holidays (includes federal and provincial holidays)
- 🇧🇷 Brazil: 51 holidays (includes Carnival and national observances)
- 🇹🇼 Taiwan: 57 holidays (includes Lunar holidays and national observances)

## [1.0.0] - 2025-09-09

### Added

- 🎉 Initial release of World Holidays package
- 🏳️ Support for 4 countries: South Korea (KR), United States (US), Japan (JP), Germany (DE)
- 📅 Complete holiday data for 2024-2026 (178 holidays total)
- 🆓 Offline-first approach with local fallback data
- 🔄 Optional online updates from GitHub Pages API
- ⚡ Efficient caching with SharedPreferences (7-day expiry)
- 🔍 Holiday lookup and filtering capabilities
- 📊 Comprehensive test coverage
- 📖 Detailed documentation and examples

### Features

- `getHolidays()` - Get holidays for specific country/year
- `updateHolidays()` - Update data from online source
- `isHoliday()` - Check if specific date is holiday
- `isTodayHoliday()` - Check if today is holiday
- `getNextHoliday()` - Find next upcoming holiday
- `getSupportedCountries()` - List supported countries
- `getSupportedYears()` - List supported years (2024-2026)
- `clearCache()` - Clear cached data

### Data Coverage

- 🇰🇷 South Korea: 48 holidays (includes Lunar holidays and substitutes)
- 🇺🇸 United States: 31 holidays (Federal holidays)
- 🇯🇵 Japan: 54 holidays (National holidays with substitutes)
- 🇩🇪 Germany: 45 holidays (National and regional holidays)

### Technical Details

- Minimum Flutter version: 3.0.0
- Minimum Dart SDK: 3.0.0
- Dependencies: http, shared_preferences
- API endpoint: https://beomq.github.io/world_holidays/api
- Cache duration: 7 days
- Network timeout: 10 seconds
