import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/holiday_data.g.dart';
import 'models/holiday.dart';
import 'models/update_outcome.dart';

/// Accesses bundled, cached, and hosted world holiday data.
class WorldHolidays {
  /// GitHub Pages API base URL.
  static const String _baseUrl = 'https://beomq.github.io/world_holidays/api';

  /// Cache key prefix for SharedPreferences.
  static const String _cachePrefix = 'world_holidays_';

  /// Cache duration: seven days.
  static const int _cacheExpiryMs = 7 * 24 * 60 * 60 * 1000;

  final http.Client _httpClient;
  final bool _ownsHttpClient;

  /// Creates a service with an optional HTTP client for deterministic testing.
  WorldHolidays({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client(),
        _ownsHttpClient = httpClient == null;

  /// Releases the HTTP client owned by this service instance.
  void dispose() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }

  /// Get holidays for a specific country
  ///
  /// [countryCode] - Country code ('KR', 'US', 'JP', 'CN', 'VN', 'MY', 'TH', 'CA', 'BR', 'TW')
  /// [year] - Optional year filter (2024-2028)
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
    if (countryCode != null) {
      return (await updateCountryHolidays(countryCode)).holidays;
    }
    return (await updateAllHolidays()).holidays;
  }

  /// Updates one country and reports its actual source.
  Future<CountryUpdateOutcome> updateCountryHolidays(String countryCode) async {
    final normalizedCode = countryCode.toUpperCase();
    final bundled = _filterByYear(_getLocalHolidays(normalizedCode), null);

    if (!bundledHolidayData.containsKey(normalizedCode)) {
      return CountryUpdateOutcome(
        countryCode: normalizedCode,
        source: HolidayDataSource.bundled,
        holidays: bundled,
        error: 'Unsupported country code: $normalizedCode',
      );
    }

    try {
      final holidays = await _updateSingleCountry(normalizedCode);
      return CountryUpdateOutcome(
        countryCode: normalizedCode,
        source: HolidayDataSource.remote,
        holidays: holidays,
      );
    } catch (error) {
      debugPrint('Update failed for $normalizedCode: $error');
      return CountryUpdateOutcome(
        countryCode: normalizedCode,
        source: HolidayDataSource.bundled,
        holidays: bundled,
        error: error.toString(),
      );
    }
  }

  /// Attempts every supported country and reports partial failures.
  Future<BulkUpdateOutcome> updateAllHolidays() async {
    final results = <CountryUpdateOutcome>[];
    for (final countryCode in getSupportedCountries()) {
      results.add(await updateCountryHolidays(countryCode));
    }
    return BulkUpdateOutcome(results);
  }

  /// Cache-aware asynchronous holiday check.
  Future<bool> isHolidayAsync(String countryCode, DateTime date) async {
    final holidays = await getHolidays(countryCode);
    return holidays.any((holiday) => holiday.isOnDate(date));
  }

  /// Cache-aware asynchronous current-day check.
  Future<bool> isTodayHolidayAsync(String countryCode) {
    return isHolidayAsync(countryCode, DateTime.now());
  }

  /// Cache-aware asynchronous next-holiday lookup.
  Future<Holiday?> getNextHolidayAsync(
    String countryCode, {
    DateTime? from,
  }) async {
    final referenceDate = from ?? DateTime.now();
    final holidays = await getHolidays(countryCode);
    final upcoming = holidays
        .where((holiday) => holiday.date.isAfter(referenceDate))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  /// Cache-aware inclusive date-range query.
  Future<List<Holiday>> getHolidaysInRange(
    String countryCode,
    DateTime start,
    DateTime end,
  ) async {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    if (endDate.isBefore(startDate)) {
      throw ArgumentError.value(end, 'end', 'Must be on or after start');
    }
    final holidays = await getHolidays(countryCode);
    return List.unmodifiable(
      holidays.where(
        (holiday) =>
            !holiday.date.isBefore(startDate) && !holiday.date.isAfter(endDate),
      ),
    );
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
    return List.unmodifiable(bundledHolidayData.keys);
  }

  /// Get supported years
  List<int> getSupportedYears() {
    return List.unmodifiable(bundledSupportedYears);
  }

  /// Update a single country's holiday data
  Future<List<Holiday>> _updateSingleCountry(String countryCode) async {
    final url = '$_baseUrl/holidays/${countryCode.toLowerCase()}.json';

    final response = await _httpClient.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json'
    }).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final holidaysList = data['holidays'] as List<dynamic>;

      final holidays = holidaysList
          .map((json) => Holiday.fromJson(json as Map<String, dynamic>))
          .toList(growable: false);

      // Cache the updated data
      await _cacheHolidays(countryCode, holidays);

      return List.unmodifiable(holidays);
    } else {
      throw Exception(
        'Failed to update holidays for $countryCode: ${response.statusCode}',
      );
    }
  }

  /// Get local hardcoded holiday data
  List<Holiday> _getLocalHolidays(String countryCode) {
    return bundledHolidayData[countryCode.toUpperCase()] ?? const [];
  }

  /// Filter holidays by year
  List<Holiday> _filterByYear(List<Holiday> holidays, int? year) {
    if (year == null) return List.unmodifiable(holidays);
    return List.unmodifiable(holidays.where((holiday) => holiday.year == year));
  }

  /// Cache holidays to local storage
  Future<void> _cacheHolidays(
    String countryCode,
    List<Holiday> holidays,
  ) async {
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
          .toList(growable: false);
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
