import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/holiday.dart';
import 'models/holiday_type.dart';

/// Main class for accessing world holiday data
///
/// Provides offline-first holiday information with optional online updates
/// for South Korea, United States, Japan, and Germany (2024-2026).
class WorldHolidays {
  /// GitHub Pages API base URL
  static const String _baseUrl = 'https://beomq.github.io/world_holidays/api';

  /// Cache key prefix for SharedPreferences
  static const String _cachePrefix = 'world_holidays_';

  /// Cache expiry time in milliseconds (7 days)
  static const int _cacheExpiryMs = 7 * 24 * 60 * 60 * 1000;

  /// Local hardcoded holiday data (offline fallback)
  static final Map<String, List<Holiday>> _localHolidays = {
    'KR': [
      Holiday(
        name: '신정',
        date: DateTime(2024, 1, 1),
        type: HolidayType.national,
        description: '새해 첫날',
      ),
      Holiday(
        name: '설날',
        date: DateTime(2024, 2, 10),
        type: HolidayType.national,
        description: '음력 새해',
      ),
      Holiday(
        name: '삼일절',
        date: DateTime(2024, 3, 1),
        type: HolidayType.national,
        description: '3.1 독립운동 기념일',
      ),
      Holiday(
        name: '어린이날',
        date: DateTime(2024, 5, 5),
        type: HolidayType.national,
        description: '어린이날',
      ),
      Holiday(
        name: '현충일',
        date: DateTime(2024, 6, 6),
        type: HolidayType.national,
        description: '호국영령 추모일',
      ),
      Holiday(
        name: '광복절',
        date: DateTime(2024, 8, 15),
        type: HolidayType.national,
        description: '일제강점기 해방 기념일',
      ),
      Holiday(
        name: '추석',
        date: DateTime(2024, 9, 17),
        type: HolidayType.national,
        description: '음력 8월 15일',
      ),
      Holiday(
        name: '개천절',
        date: DateTime(2024, 10, 3),
        type: HolidayType.national,
        description: '단군 건국 기념일',
      ),
      Holiday(
        name: '한글날',
        date: DateTime(2024, 10, 9),
        type: HolidayType.national,
        description: '한글 창제 기념일',
      ),
      Holiday(
        name: '크리스마스',
        date: DateTime(2024, 12, 25),
        type: HolidayType.national,
        description: '기독탄신일',
      ),
    ],
    'US': [
      Holiday(
        name: "New Year's Day",
        date: DateTime(2024, 1, 1),
        type: HolidayType.national,
        description: 'First day of the year',
      ),
      Holiday(
        name: 'Independence Day',
        date: DateTime(2024, 7, 4),
        type: HolidayType.national,
        description: 'American Independence Day',
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2024, 12, 25),
        type: HolidayType.national,
        description: 'Christmas celebration',
      ),
    ],
    'JP': [
      Holiday(
        name: '元日',
        date: DateTime(2024, 1, 1),
        type: HolidayType.national,
        description: '新年',
      ),
      Holiday(
        name: '成人の日',
        date: DateTime(2024, 1, 8),
        type: HolidayType.national,
        description: '成人を祝う日',
      ),
      Holiday(
        name: '建国記念の日',
        date: DateTime(2024, 2, 11),
        type: HolidayType.national,
        description: '建国をしのび、国を愛する心を養う',
      ),
    ],
    'DE': [
      Holiday(
        name: 'Neujahrstag',
        date: DateTime(2024, 1, 1),
        type: HolidayType.national,
        description: 'New Year\'s Day',
      ),
      Holiday(
        name: 'Karfreitag',
        date: DateTime(2024, 3, 29),
        type: HolidayType.national,
        description: 'Good Friday',
      ),
      Holiday(
        name: 'Ostermontag',
        date: DateTime(2024, 4, 1),
        type: HolidayType.national,
        description: 'Easter Monday',
      ),
      Holiday(
        name: 'Tag der Arbeit',
        date: DateTime(2024, 5, 1),
        type: HolidayType.national,
        description: 'Labour Day',
      ),
      Holiday(
        name: 'Tag der Deutschen Einheit',
        date: DateTime(2024, 10, 3),
        type: HolidayType.national,
        description: 'German Unity Day',
      ),
      Holiday(
        name: '1. Weihnachtsfeiertag',
        date: DateTime(2024, 12, 25),
        type: HolidayType.national,
        description: 'Christmas Day',
      ),
      Holiday(
        name: '2. Weihnachtsfeiertag',
        date: DateTime(2024, 12, 26),
        type: HolidayType.national,
        description: 'Boxing Day',
      ),
    ],
  };

  /// Get holidays for a specific country
  ///
  /// [countryCode] - Country code ('KR', 'US', 'JP', 'DE')
  /// [year] - Optional year filter (2024-2026)
  ///
  /// Returns cached data if available, otherwise returns local fallback data
  Future<List<Holiday>> getHolidays(String countryCode, {int? year}) async {
    try {
      // Try to get cached data first
      final cachedHolidays = await _getCachedHolidays(countryCode);
      if (cachedHolidays.isNotEmpty) {
        return _filterByYear(cachedHolidays, year);
      }
    } catch (e) {
      debugPrint('Failed to get cached holidays: $e');
    }

    // Fallback to local data
    final localHolidays = _getLocalHolidays(countryCode);
    return _filterByYear(localHolidays, year);
  }

  /// Update holiday data from online source
  ///
  /// [countryCode] - Optional specific country to update
  ///
  /// Downloads latest holiday data and caches it locally.
  /// Falls back to local data if network request fails.
  Future<List<Holiday>> updateHolidays({String? countryCode}) async {
    try {
      if (countryCode != null) {
        return await _updateSingleCountry(countryCode);
      } else {
        // Update all supported countries
        final countries = getSupportedCountries();
        final List<Holiday> allHolidays = [];

        for (final country in countries) {
          final holidays = await _updateSingleCountry(country);
          allHolidays.addAll(holidays);
        }

        return allHolidays;
      }
    } catch (e) {
      debugPrint('Update failed, using local data: $e');
      return _getLocalHolidays(countryCode ?? 'KR');
    }
  }

  /// Check if a specific date is a holiday
  ///
  /// [countryCode] - Country code to check
  /// [date] - Date to check
  bool isHoliday(String countryCode, DateTime date) {
    final holidays = _getLocalHolidays(countryCode);
    return holidays.any((holiday) => holiday.isOnDate(date));
  }

  /// Check if today is a holiday in the specified country
  bool isTodayHoliday(String countryCode) {
    return isHoliday(countryCode, DateTime.now());
  }

  /// Get the next upcoming holiday
  ///
  /// [countryCode] - Country code
  /// [from] - Optional reference date (defaults to now)
  Holiday? getNextHoliday(String countryCode, {DateTime? from}) {
    final referenceDate = from ?? DateTime.now();
    final holidays = _getLocalHolidays(countryCode);

    final upcomingHolidays = holidays
        .where((holiday) => holiday.date.isAfter(referenceDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return upcomingHolidays.isNotEmpty ? upcomingHolidays.first : null;
  }

  /// Get list of supported country codes
  List<String> getSupportedCountries() {
    return _localHolidays.keys.toList();
  }

  /// Get supported years
  List<int> getSupportedYears() {
    return [2024, 2025, 2026];
  }

  /// Update a single country's holiday data
  Future<List<Holiday>> _updateSingleCountry(String countryCode) async {
    final url = '$_baseUrl/holidays/${countryCode.toLowerCase()}.json';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final holidaysList = data['holidays'] as List<dynamic>;

      final holidays = holidaysList
          .map((json) => Holiday.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache the updated data
      await _cacheHolidays(countryCode, holidays);

      return holidays;
    } else {
      throw Exception(
          'Failed to update holidays for $countryCode: ${response.statusCode}');
    }
  }

  /// Get local hardcoded holiday data
  List<Holiday> _getLocalHolidays(String countryCode) {
    return _localHolidays[countryCode.toUpperCase()] ?? [];
  }

  /// Filter holidays by year
  List<Holiday> _filterByYear(List<Holiday> holidays, int? year) {
    if (year == null) return holidays;
    return holidays.where((holiday) => holiday.year == year).toList();
  }

  /// Cache holidays to local storage
  Future<void> _cacheHolidays(
      String countryCode, List<Holiday> holidays) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix${countryCode.toLowerCase()}';
      final cacheData = {
        'holidays': holidays.map((h) => h.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(cacheKey, json.encode(cacheData));
    } catch (e) {
      debugPrint('Failed to cache holidays: $e');
    }
  }

  /// Get cached holidays from local storage
  Future<List<Holiday>> _getCachedHolidays(String countryCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix${countryCode.toLowerCase()}';
      final cachedString = prefs.getString(cacheKey);

      if (cachedString == null) return [];

      final cacheData = json.decode(cachedString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;

      // Check if cache is expired
      if (DateTime.now().millisecondsSinceEpoch - timestamp > _cacheExpiryMs) {
        return [];
      }

      final holidaysList = cacheData['holidays'] as List<dynamic>;
      return holidaysList
          .map((json) => Holiday.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Failed to get cached holidays: $e');
      return [];
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));

      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }
}
