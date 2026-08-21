/// World Holidays package for generated holiday information.
///
/// Provides generated data for 10 countries (2024-2028), offline-first lookup,
/// a seven-day cache, and explicit hosted updates.
///
/// Supported country codes: KR, US, JP, CN, VN, MY, TH, CA, BR, and TW.
///
/// ```dart
/// import 'package:world_holidays/world_holidays.dart';
///
/// final worldHolidays = WorldHolidays();
/// final holidays = await worldHolidays.getHolidays('KR', year: 2027);
/// final update = await worldHolidays.updateCountryHolidays('KR');
/// final isToday = await worldHolidays.isTodayHolidayAsync('KR');
/// ```
library;

export 'src/world_holidays.dart';
export 'src/models/holiday.dart';
export 'src/models/holiday_type.dart';
export 'src/models/country_info.dart';
export 'src/models/update_outcome.dart';
