/// 🌍 World Holidays - A comprehensive Flutter package for holiday information
///
/// Provides holiday data for multiple countries (2024-2026) with offline-first
/// support and optional online updates.
///
/// Supported countries:
/// - 🇰🇷 South Korea (KR) - 48 holidays
/// - 🇺🇸 United States (US) - 31 holidays
/// - 🇯🇵 Japan (JP) - 54 holidays
///
/// ## Usage
///
/// ```dart
/// import 'package:world_holidays/world_holidays.dart';
///
/// final worldHolidays = WorldHolidays();
///
/// // Get holidays for South Korea
/// final holidays = await worldHolidays.getHolidays('KR');
///
/// // Update with latest data (optional)
/// await worldHolidays.updateHolidays(countryCode: 'KR');
///
/// // Check if today is a holiday
/// final isToday = worldHolidays.isTodayHoliday('KR');
/// ```
library;

export 'src/world_holidays.dart';
export 'src/models/holiday.dart';
export 'src/models/holiday_type.dart';
export 'src/models/country_info.dart';
