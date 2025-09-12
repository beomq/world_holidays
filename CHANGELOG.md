# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
