# 🌍 World Holidays

A comprehensive Flutter package providing holiday information for multiple countries (2024-2026). Get holidays for South Korea, United States, Japan, China, Vietnam, Malaysia, Thailand, Canada, Brazil, and Taiwan with automatic online updates and offline fallback support.

[![pub package](https://img.shields.io/pub/v/world_holidays.svg)](https://pub.dev/packages/world_holidays)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ✨ Features

- 🆓 **Completely Free** - No API keys or costs required
- 🌐 **Always Up-to-Date** - Automatically fetches latest holiday data online
- 📱 **Offline Fallback** - Works without internet connection using local data
- 🔄 **Smart Caching** - Efficient data storage and retrieval
- 🏳️ **Multi-Country** - Support for 10 countries with 508 total holidays
- 🌐 **Multilingual** - English and Korean descriptions for all holidays
- 📅 **3-Year Coverage** - Holiday data for 2024, 2025, and 2026
- ⚡ **Fast & Lightweight** - Minimal dependencies and optimized performance

## 🏳️ Supported Countries

| Country       | Code | Holidays    | Flag |
| ------------- | ---- | ----------- | ---- |
| South Korea   | `KR` | 41 holidays | 🇰🇷   |
| United States | `US` | 32 holidays | 🇺🇸   |
| Japan         | `JP` | 57 holidays | 🇯🇵   |
| China         | `CN` | 72 holidays | 🇨🇳   |
| Vietnam       | `VN` | 44 holidays | 🇻🇳   |
| Malaysia      | `MY` | 44 holidays | 🇲🇾   |
| Thailand      | `TH` | 61 holidays | 🇹🇭   |
| Canada        | `CA` | 33 holidays | 🇨🇦   |
| Brazil        | `BR` | 51 holidays | 🇧🇷   |
| Taiwan        | `TW` | 57 holidays | 🇹🇼   |

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  world_holidays: ^2.0.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

```dart
import 'package:world_holidays/world_holidays.dart';

void main() async {
  final worldHolidays = WorldHolidays();

  // Get holidays for South Korea (fetches latest data online)
  final holidays = await worldHolidays.getHolidays('KR');
  print('Found ${holidays.length} holidays');

  // Check if today is a holiday
  final isToday = worldHolidays.isTodayHoliday('KR');
  print('Is today a holiday? $isToday');

  // Get next upcoming holiday
  final nextHoliday = worldHolidays.getNextHoliday('KR');
  if (nextHoliday != null) {
    print('Next holiday: ${nextHoliday.name} on ${nextHoliday.dateString}');
  }
}
```

## 📖 Detailed Usage

### Getting Holidays

```dart
final worldHolidays = WorldHolidays();

// Get all holidays for a country (automatically fetches latest data online)
final allHolidays = await worldHolidays.getHolidays('KR');

// Get holidays for a specific year (online data with offline fallback)
final holidays2025 = await worldHolidays.getHolidays('KR', year: 2025);

// Get holidays for different countries
final usHolidays = await worldHolidays.getHolidays('US');
final jpHolidays = await worldHolidays.getHolidays('JP');
final cnHolidays = await worldHolidays.getHolidays('CN');
final thHolidays = await worldHolidays.getHolidays('TH');
final brHolidays = await worldHolidays.getHolidays('BR');
```

### Manual Data Updates (Optional)

The library automatically fetches the latest data online. Use these methods only if you need to force updates:

```dart
// Force update specific country (downloads 3-year data)
await worldHolidays.updateHolidays(countryCode: 'KR');

// Force update all supported countries
await worldHolidays.updateHolidays();
```

### 📡 Online vs Offline Usage

**Default Behavior (Online-First):**

```dart
// Automatically fetches latest data from GitHub Pages API
final holidays = await worldHolidays.getHolidays('KR');
```

**Offline-Only Usage:**
If you want to use only local data without internet requests, disable automatic updates:

```dart
// For offline-only applications, use local fallback data
// Note: This requires manual cache management
await worldHolidays.clearCache(); // Clear any cached online data
final offlineHolidays = await worldHolidays.getHolidays('KR');
// Will use local hardcoded data when no internet/cache available
```

**Best Practice:** Let the library handle online/offline automatically - it will use online data when available and fall back to local data when offline.

### Checking Holidays

```dart
// Check if a specific date is a holiday
final isHoliday = worldHolidays.isHoliday('KR', DateTime(2024, 1, 1));

// Check if today is a holiday
final isTodayHoliday = worldHolidays.isTodayHoliday('US');

// Get the next upcoming holiday
final nextHoliday = worldHolidays.getNextHoliday('JP');

// Get holidays in a date range
final rangeHolidays = worldHolidays.getHolidaysInRange(
  'KR',
  DateTime(2024, 1, 1),
  DateTime(2024, 12, 31),
);
```

### Multilingual Support

All holidays now include multilingual descriptions in English and Korean:

```dart
final holidays = await worldHolidays.getHolidays('KR');
final holiday = holidays.first;

// Get description in specific language
print(holiday.getDescription('en')); // "New Year's Day"
print(holiday.getDescription('ko')); // "신정"

// Convenience getters
print(holiday.descriptionEn); // "New Year's Day"
print(holiday.descriptionKo); // "신정"

// Access raw description object
print(holiday.description); // {"en": "New Year's Day", "ko": "신정"}
```

### Utility Methods

```dart
// Get supported countries
final countries = worldHolidays.getSupportedCountries();
print(countries); // ['BR', 'CA', 'CN', 'JP', 'KR', 'MY', 'TH', 'TW', 'US', 'VN']

// Get supported years
final years = worldHolidays.getSupportedYears();
print(years); // [2024, 2025, 2026]

// Clear cached data
await worldHolidays.clearCache();
```

## 📱 Example App

Check out the [example app](example/) for a complete Flutter application demonstrating all features.

## 🔧 Holiday Types

The package categorizes holidays into different types:

- **NATIONAL** - Official national public holidays
- **RELIGIOUS** - Religious observances and holidays
- **REGIONAL** - Regional or state-specific holidays
- **OBSERVANCE** - Cultural observances and commemorative days

## 🌐 Data Source

Holiday data is sourced from:

- **GitHub Pages API** - Real-time updates via `https://beomq.github.io/world_holidays/api/`
- **Local Fallback** - Embedded data for offline usage (508 holidays across 10 countries)
- **Official Sources** - Government and cultural organization websites
- **Multilingual Support** - English and Korean descriptions for all holidays

## 🔄 Update Strategy

- **API Updates** - Immediate for urgent holiday changes
- **Library Updates** - Quarterly for new years and major changes
- **Data Accuracy** - Verified against official government sources

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Adding New Countries

1. Research official holidays from government sources
2. Create JSON data file with 3-year coverage
3. Add local fallback data to the library
4. Update tests and documentation
5. Submit PR with detailed information

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Holiday data sourced from official government websites
- Built with ❤️ for the Flutter community
- Inspired by the need for accurate, free holiday data

## 📞 Support

- 📧 Issues: [GitHub Issues](https://github.com/beomq/world_holidays/issues)
- 📖 Documentation: [GitHub Pages](https://beomq.github.io/world_holidays/)
- 💬 Discussions: [GitHub Discussions](https://github.com/beomq/world_holidays/discussions)

---

Made with 🌍 by [beomq](https://github.com/beomq)
