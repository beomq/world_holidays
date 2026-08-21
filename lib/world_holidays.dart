/// World Holidays package for generated holiday information.
///
/// Provides generated data for 10 countries (2024-2028) through an
/// offline-first, stale-while-revalidate flow:
///
/// - Render cache or bundled data from [WorldHolidays.getHolidays] first.
/// - At a caller-controlled interval, refresh with
///   [WorldHolidays.updateCountryHolidays].
/// - Replace visible data only when the update outcome succeeds.
/// - Keep existing local data when the network request fails.
///
/// `getHolidays()` reads cache or bundle data but never starts a network
/// request. Cache expiry also falls back to the bundle without downloading. A
/// 24-hour refresh interval at app startup or resume is a practical default.
///
/// Supported country codes: KR, US, JP, CN, VN, MY, TH, CA, BR, and TW.
///
/// ```dart
/// import 'package:world_holidays/world_holidays.dart';
///
/// final worldHolidays = WorldHolidays();
/// var visible = await worldHolidays.getHolidays('KR');
///
/// // Run at a throttled point such as app startup or resume.
/// final outcome = await worldHolidays.updateCountryHolidays('KR');
/// if (outcome.succeeded) {
///   visible = outcome.holidays;
/// }
/// // On failure, keep the local `visible` list.
/// worldHolidays.dispose();
/// ```
///
/// Apps that must remain fully offline can upgrade the package and use
/// [WorldHolidays.isHoliday], [WorldHolidays.isTodayHoliday], and
/// [WorldHolidays.getNextHoliday], which always inspect the bundled snapshot.
library;

export 'src/world_holidays.dart';
export 'src/models/holiday.dart';
export 'src/models/holiday_type.dart';
export 'src/models/country_info.dart';
export 'src/models/update_outcome.dart';
