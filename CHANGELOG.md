# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
