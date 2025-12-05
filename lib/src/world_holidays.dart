import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/holiday.dart';
import 'models/holiday_type.dart';

/// Main class for accessing world holiday data
///
/// Provides offline-first holiday information with optional online updates
/// for South Korea, United States, Japan, China, Vietnam, Malaysia, Thailand, Canada, Brazil, and Taiwan (2024-2026).
class WorldHolidays {
  /// GitHub Pages API base URL
  static const String _baseUrl = 'https://beomq.github.io/world_holidays/api';

  /// Cache key prefix for SharedPreferences
  static const String _cachePrefix = 'world_holidays_';

  /// Cache expiry time in milliseconds (7 days)
  static const int _cacheExpiryMs = 7 * 24 * 60 * 60 * 1000;

  /// Local hardcoded holiday data (offline fallback)
  static final Map<String, List<Holiday>> _localHolidays = {
    'BR': [
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2024, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Carnival Monday',
        date: DateTime(2024, 02, 12),
        type: HolidayType.national,
        description: {'en': 'Carnival Monday', 'ko': '카니발 월요일'},
      ),
      Holiday(
        name: 'Carnival Tuesday',
        date: DateTime(2024, 02, 13),
        type: HolidayType.national,
        description: {'en': 'Carnival Tuesday', 'ko': '카니발 화요일'},
      ),
      Holiday(
        name: 'Carnival End',
        date: DateTime(2024, 02, 14),
        type: HolidayType.national,
        description: {
          'en': 'Carnival end (until 2pm)',
          'ko': '카니발 종료 (오후 2시까지)'
        },
      ),
      Holiday(
        name: 'Good Friday',
        date: DateTime(2024, 03, 29),
        type: HolidayType.national,
        description: {'en': 'Good Friday', 'ko': '성금요일'},
      ),
      Holiday(
        name: 'Tiradentes Day',
        date: DateTime(2024, 04, 21),
        type: HolidayType.national,
        description: {'en': 'Tiradentes Day', 'ko': '티라덴테스의 날'},
      ),
      Holiday(
        name: 'Labor Day / May Day',
        date: DateTime(2024, 05, 01),
        type: HolidayType.national,
        description: {'en': 'Labor Day / May Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Corpus Christi',
        date: DateTime(2024, 05, 30),
        type: HolidayType.national,
        description: {'en': 'Corpus Christi', 'ko': '성체성사절'},
      ),
      Holiday(
        name: 'Independence Day',
        date: DateTime(2024, 09, 07),
        type: HolidayType.national,
        description: {'en': 'Independence Day', 'ko': '독립기념일'},
      ),
      Holiday(
        name: 'Our Lady of Aparecida / Children\'s Day',
        date: DateTime(2024, 10, 12),
        type: HolidayType.national,
        description: {
          'en': 'Our Lady of Aparecida / Children\'s Day',
          'ko': '아파레시다 성모님의 날 / 어린이날'
        },
      ),
      Holiday(
        name: 'Public Service Holiday',
        date: DateTime(2024, 10, 28),
        type: HolidayType.national,
        description: {'en': 'Public Service Holiday', 'ko': '공무원의 날'},
      ),
      Holiday(
        name: 'All Souls\' Day',
        date: DateTime(2024, 11, 02),
        type: HolidayType.national,
        description: {'en': 'All Souls\' Day', 'ko': '모든 영혼의 날'},
      ),
      Holiday(
        name: 'Republic Proclamation Day',
        date: DateTime(2024, 11, 15),
        type: HolidayType.national,
        description: {'en': 'Republic Proclamation Day', 'ko': '공화국 선포일'},
      ),
      Holiday(
        name: 'Black Awareness Day',
        date: DateTime(2024, 11, 20),
        type: HolidayType.national,
        description: {'en': 'Black Awareness Day', 'ko': '흑인 의식의 날'},
      ),
      Holiday(
        name: 'Christmas Eve',
        date: DateTime(2024, 12, 24),
        type: HolidayType.national,
        description: {
          'en': 'Christmas Eve (from 2pm)',
          'ko': '크리스마스 이브 (오후 2시부터)'
        },
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2024, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: 'New Year\'s Eve',
        date: DateTime(2024, 12, 31),
        type: HolidayType.national,
        description: {
          'en': 'New Year\'s Eve (from 2pm)',
          'ko': '신정 전야 (오후 2시부터)'
        },
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2025, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Carnival Monday',
        date: DateTime(2025, 03, 03),
        type: HolidayType.national,
        description: {'en': 'Carnival Monday', 'ko': '카니발 월요일'},
      ),
      Holiday(
        name: 'Carnival Tuesday',
        date: DateTime(2025, 03, 04),
        type: HolidayType.national,
        description: {'en': 'Carnival Tuesday', 'ko': '카니발 화요일'},
      ),
      Holiday(
        name: 'Carnival End',
        date: DateTime(2025, 03, 05),
        type: HolidayType.national,
        description: {
          'en': 'Carnival end (until 2pm)',
          'ko': '카니발 종료 (오후 2시까지)'
        },
      ),
      Holiday(
        name: 'Good Friday',
        date: DateTime(2025, 04, 18),
        type: HolidayType.national,
        description: {'en': 'Good Friday', 'ko': '성금요일'},
      ),
      Holiday(
        name: 'Tiradentes Day',
        date: DateTime(2025, 04, 21),
        type: HolidayType.national,
        description: {'en': 'Tiradentes Day', 'ko': '티라덴테스의 날'},
      ),
      Holiday(
        name: 'Labor Day / May Day',
        date: DateTime(2025, 05, 01),
        type: HolidayType.national,
        description: {'en': 'Labor Day / May Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Corpus Christi',
        date: DateTime(2025, 06, 19),
        type: HolidayType.national,
        description: {'en': 'Corpus Christi', 'ko': '성체성사절'},
      ),
      Holiday(
        name: 'Independence Day',
        date: DateTime(2025, 09, 07),
        type: HolidayType.national,
        description: {'en': 'Independence Day', 'ko': '독립기념일'},
      ),
      Holiday(
        name: 'Our Lady of Aparecida / Children\'s Day',
        date: DateTime(2025, 10, 12),
        type: HolidayType.national,
        description: {
          'en': 'Our Lady of Aparecida / Children\'s Day',
          'ko': '아파레시다 성모님의 날 / 어린이날'
        },
      ),
      Holiday(
        name: 'Public Service Holiday',
        date: DateTime(2025, 10, 28),
        type: HolidayType.national,
        description: {'en': 'Public Service Holiday', 'ko': '공무원의 날'},
      ),
      Holiday(
        name: 'All Souls\' Day',
        date: DateTime(2025, 11, 02),
        type: HolidayType.national,
        description: {'en': 'All Souls\' Day', 'ko': '모든 영혼의 날'},
      ),
      Holiday(
        name: 'Republic Proclamation Day',
        date: DateTime(2025, 11, 15),
        type: HolidayType.national,
        description: {'en': 'Republic Proclamation Day', 'ko': '공화국 선포일'},
      ),
      Holiday(
        name: 'Black Awareness Day',
        date: DateTime(2025, 11, 20),
        type: HolidayType.national,
        description: {'en': 'Black Awareness Day', 'ko': '흑인 의식의 날'},
      ),
      Holiday(
        name: 'Christmas Eve',
        date: DateTime(2025, 12, 24),
        type: HolidayType.national,
        description: {
          'en': 'Christmas Eve (from 2pm)',
          'ko': '크리스마스 이브 (오후 2시부터)'
        },
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2025, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: 'New Year\'s Eve',
        date: DateTime(2025, 12, 31),
        type: HolidayType.national,
        description: {
          'en': 'New Year\'s Eve (from 2pm)',
          'ko': '신정 전야 (오후 2시부터)'
        },
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2026, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Carnival Monday',
        date: DateTime(2026, 02, 16),
        type: HolidayType.national,
        description: {'en': 'Carnival Monday', 'ko': '카니발 월요일'},
      ),
      Holiday(
        name: 'Carnival Tuesday',
        date: DateTime(2026, 02, 17),
        type: HolidayType.national,
        description: {'en': 'Carnival Tuesday', 'ko': '카니발 화요일'},
      ),
      Holiday(
        name: 'Carnival End',
        date: DateTime(2026, 02, 18),
        type: HolidayType.national,
        description: {
          'en': 'Carnival end (until 2pm)',
          'ko': '카니발 종료 (오후 2시까지)'
        },
      ),
      Holiday(
        name: 'Good Friday',
        date: DateTime(2026, 04, 03),
        type: HolidayType.national,
        description: {'en': 'Good Friday', 'ko': '성금요일'},
      ),
      Holiday(
        name: 'Tiradentes Day',
        date: DateTime(2026, 04, 21),
        type: HolidayType.national,
        description: {'en': 'Tiradentes Day', 'ko': '티라덴테스의 날'},
      ),
      Holiday(
        name: 'Labor Day / May Day',
        date: DateTime(2026, 05, 01),
        type: HolidayType.national,
        description: {'en': 'Labor Day / May Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Corpus Christi',
        date: DateTime(2026, 06, 04),
        type: HolidayType.national,
        description: {'en': 'Corpus Christi', 'ko': '성체성사절'},
      ),
      Holiday(
        name: 'Independence Day',
        date: DateTime(2026, 09, 07),
        type: HolidayType.national,
        description: {'en': 'Independence Day', 'ko': '독립기념일'},
      ),
      Holiday(
        name: 'Our Lady of Aparecida / Children\'s Day',
        date: DateTime(2026, 10, 12),
        type: HolidayType.national,
        description: {
          'en': 'Our Lady of Aparecida / Children\'s Day',
          'ko': '아파레시다 성모님의 날 / 어린이날'
        },
      ),
      Holiday(
        name: 'Public Service Holiday',
        date: DateTime(2026, 10, 28),
        type: HolidayType.national,
        description: {'en': 'Public Service Holiday', 'ko': '공무원의 날'},
      ),
      Holiday(
        name: 'All Souls\' Day',
        date: DateTime(2026, 11, 02),
        type: HolidayType.national,
        description: {'en': 'All Souls\' Day', 'ko': '모든 영혼의 날'},
      ),
      Holiday(
        name: 'Republic Proclamation Day',
        date: DateTime(2026, 11, 15),
        type: HolidayType.national,
        description: {'en': 'Republic Proclamation Day', 'ko': '공화국 선포일'},
      ),
      Holiday(
        name: 'Black Awareness Day',
        date: DateTime(2026, 11, 20),
        type: HolidayType.national,
        description: {'en': 'Black Awareness Day', 'ko': '흑인 의식의 날'},
      ),
      Holiday(
        name: 'Christmas Eve',
        date: DateTime(2026, 12, 24),
        type: HolidayType.national,
        description: {
          'en': 'Christmas Eve (from 2pm)',
          'ko': '크리스마스 이브 (오후 2시부터)'
        },
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2026, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: 'New Year\'s Eve',
        date: DateTime(2026, 12, 31),
        type: HolidayType.national,
        description: {
          'en': 'New Year\'s Eve (from 2pm)',
          'ko': '신정 전야 (오후 2시부터)'
        },
      ),
    ],
    'CA': [
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2024, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Good Friday',
        date: DateTime(2024, 03, 29),
        type: HolidayType.national,
        description: {'en': 'Good Friday', 'ko': '성금요일'},
      ),
      Holiday(
        name: 'Easter Monday',
        date: DateTime(2024, 04, 01),
        type: HolidayType.regional,
        description: {
          'en': 'Easter Monday (NT, NU, QC)',
          'ko': '부활절 월요일 (노스웨스트 준주, 누나부트, 퀘벡)'
        },
      ),
      Holiday(
        name: 'Victoria Day',
        date: DateTime(2024, 05, 20),
        type: HolidayType.regional,
        description: {
          'en': 'Victoria Day (Many regions)',
          'ko': '빅토리아 데이 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Canada Day',
        date: DateTime(2024, 07, 01),
        type: HolidayType.national,
        description: {'en': 'Canada Day', 'ko': '캐나다 데이'},
      ),
      Holiday(
        name: 'Labour Day',
        date: DateTime(2024, 09, 02),
        type: HolidayType.national,
        description: {'en': 'Labour Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'National Day for Truth and Reconciliation',
        date: DateTime(2024, 09, 30),
        type: HolidayType.national,
        description: {
          'en': 'National Day for Truth and Reconciliation',
          'ko': '진실과 화해의 날'
        },
      ),
      Holiday(
        name: 'Thanksgiving Day',
        date: DateTime(2024, 10, 14),
        type: HolidayType.regional,
        description: {
          'en': 'Thanksgiving Day (Most regions)',
          'ko': '추수감사절 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Remembrance Day',
        date: DateTime(2024, 11, 11),
        type: HolidayType.regional,
        description: {
          'en': 'Remembrance Day (Many regions)',
          'ko': '현충일 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2024, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: 'Boxing Day',
        date: DateTime(2024, 12, 26),
        type: HolidayType.regional,
        description: {'en': 'Boxing Day (Many regions)', 'ko': '박싱데이 (대부분 지역)'},
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2025, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Good Friday',
        date: DateTime(2025, 04, 18),
        type: HolidayType.national,
        description: {'en': 'Good Friday', 'ko': '성금요일'},
      ),
      Holiday(
        name: 'Easter Monday',
        date: DateTime(2025, 04, 21),
        type: HolidayType.regional,
        description: {
          'en': 'Easter Monday (NT, NU, QC)',
          'ko': '부활절 월요일 (노스웨스트 준주, 누나부트, 퀘벡)'
        },
      ),
      Holiday(
        name: 'Victoria Day',
        date: DateTime(2025, 05, 19),
        type: HolidayType.regional,
        description: {
          'en': 'Victoria Day (Many regions)',
          'ko': '빅토리아 데이 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Canada Day',
        date: DateTime(2025, 07, 01),
        type: HolidayType.national,
        description: {'en': 'Canada Day', 'ko': '캐나다 데이'},
      ),
      Holiday(
        name: 'Labour Day',
        date: DateTime(2025, 09, 01),
        type: HolidayType.national,
        description: {'en': 'Labour Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'National Day for Truth and Reconciliation',
        date: DateTime(2025, 09, 30),
        type: HolidayType.national,
        description: {
          'en': 'National Day for Truth and Reconciliation',
          'ko': '진실과 화해의 날'
        },
      ),
      Holiday(
        name: 'Thanksgiving Day',
        date: DateTime(2025, 10, 13),
        type: HolidayType.regional,
        description: {
          'en': 'Thanksgiving Day (Most regions)',
          'ko': '추수감사절 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Remembrance Day',
        date: DateTime(2025, 11, 11),
        type: HolidayType.regional,
        description: {
          'en': 'Remembrance Day (Many regions)',
          'ko': '현충일 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2025, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: 'Boxing Day',
        date: DateTime(2025, 12, 26),
        type: HolidayType.regional,
        description: {'en': 'Boxing Day (Many regions)', 'ko': '박싱데이 (대부분 지역)'},
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2026, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Good Friday',
        date: DateTime(2026, 04, 03),
        type: HolidayType.national,
        description: {'en': 'Good Friday', 'ko': '성금요일'},
      ),
      Holiday(
        name: 'Easter Monday',
        date: DateTime(2026, 04, 06),
        type: HolidayType.regional,
        description: {
          'en': 'Easter Monday (NT, NU, QC)',
          'ko': '부활절 월요일 (노스웨스트 준주, 누나부트, 퀘벡)'
        },
      ),
      Holiday(
        name: 'Victoria Day',
        date: DateTime(2026, 05, 18),
        type: HolidayType.regional,
        description: {
          'en': 'Victoria Day (Many regions)',
          'ko': '빅토리아 데이 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Canada Day',
        date: DateTime(2026, 07, 01),
        type: HolidayType.national,
        description: {'en': 'Canada Day', 'ko': '캐나다 데이'},
      ),
      Holiday(
        name: 'Labour Day',
        date: DateTime(2026, 09, 07),
        type: HolidayType.national,
        description: {'en': 'Labour Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'National Day for Truth and Reconciliation',
        date: DateTime(2026, 09, 30),
        type: HolidayType.national,
        description: {
          'en': 'National Day for Truth and Reconciliation',
          'ko': '진실과 화해의 날'
        },
      ),
      Holiday(
        name: 'Thanksgiving Day',
        date: DateTime(2026, 10, 12),
        type: HolidayType.regional,
        description: {
          'en': 'Thanksgiving Day (Most regions)',
          'ko': '추수감사절 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Remembrance Day',
        date: DateTime(2026, 11, 11),
        type: HolidayType.regional,
        description: {
          'en': 'Remembrance Day (Many regions)',
          'ko': '현충일 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2026, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: 'Boxing Day',
        date: DateTime(2026, 12, 26),
        type: HolidayType.regional,
        description: {'en': 'Boxing Day (Many regions)', 'ko': '박싱데이 (대부분 지역)'},
      ),
    ],
    'CN': [
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2024, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Spring Festival Eve',
        date: DateTime(2024, 01, 28),
        type: HolidayType.national,
        description: {'en': 'Spring Festival Eve', 'ko': '춘절 전야'},
      ),
      Holiday(
        name: 'Chinese New Year',
        date: DateTime(2024, 01, 29),
        type: HolidayType.national,
        description: {
          'en': 'Chinese New Year (Spring Festival)',
          'ko': '춘절 (중국 신정)'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2024, 01, 30),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2024, 01, 31),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2024, 02, 01),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2024, 02, 02),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2024, 02, 03),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2024, 02, 04),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Qing Ming Jie holiday',
        date: DateTime(2024, 04, 04),
        type: HolidayType.national,
        description: {'en': 'Qing Ming Jie Holiday', 'ko': '청명절 연휴'},
      ),
      Holiday(
        name: 'Qing Ming Jie',
        date: DateTime(2024, 04, 05),
        type: HolidayType.national,
        description: {
          'en': 'Qing Ming Jie (Tomb Sweeping Day)',
          'ko': '청명절 (성묘의 날)'
        },
      ),
      Holiday(
        name: 'Qing Ming Jie holiday',
        date: DateTime(2024, 04, 06),
        type: HolidayType.national,
        description: {'en': 'Qing Ming Jie Holiday', 'ko': '청명절 연휴'},
      ),
      Holiday(
        name: 'Labour Day',
        date: DateTime(2024, 05, 01),
        type: HolidayType.national,
        description: {'en': 'Labour Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Labour Day Holiday',
        date: DateTime(2024, 05, 02),
        type: HolidayType.national,
        description: {'en': 'Labour Day Holiday', 'ko': '노동절 연휴'},
      ),
      Holiday(
        name: 'Labour Day Holiday',
        date: DateTime(2024, 05, 03),
        type: HolidayType.national,
        description: {'en': 'Labour Day Holiday', 'ko': '노동절 연휴'},
      ),
      Holiday(
        name: 'Labour Day Holiday',
        date: DateTime(2024, 05, 05),
        type: HolidayType.national,
        description: {'en': 'Labour Day Holiday', 'ko': '노동절 연휴'},
      ),
      Holiday(
        name: 'Dragon Boat Festival',
        date: DateTime(2024, 05, 31),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival', 'ko': '단오절 (용선축제)'},
      ),
      Holiday(
        name: 'Dragon Boat Festival holiday',
        date: DateTime(2024, 06, 01),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival Holiday', 'ko': '단오절 연휴'},
      ),
      Holiday(
        name: 'Dragon Boat Festival holiday',
        date: DateTime(2024, 06, 02),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival Holiday', 'ko': '단오절 연휴'},
      ),
      Holiday(
        name: 'National Day',
        date: DateTime(2024, 10, 01),
        type: HolidayType.national,
        description: {'en': 'National Day', 'ko': '국경절'},
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2024, 10, 02),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2024, 10, 03),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2024, 10, 04),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2024, 10, 05),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday / Mid-Autumn Festival',
        date: DateTime(2024, 10, 06),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday / Mid-Autumn Festival',
          'ko': '국경절 황금주간 연휴 / 중추절 (추석)'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2024, 10, 07),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2024, 10, 08),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2025, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Spring Festival Eve',
        date: DateTime(2025, 01, 25),
        type: HolidayType.national,
        description: {'en': 'Spring Festival Eve', 'ko': '춘절 전야'},
      ),
      Holiday(
        name: 'Chinese New Year',
        date: DateTime(2025, 01, 26),
        type: HolidayType.national,
        description: {
          'en': 'Chinese New Year (Spring Festival)',
          'ko': '춘절 (중국 신정)'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2025, 01, 27),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2025, 01, 28),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2025, 01, 29),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2025, 01, 30),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2025, 01, 31),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2025, 02, 01),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2025, 02, 02),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Qing Ming Jie',
        date: DateTime(2025, 04, 05),
        type: HolidayType.national,
        description: {
          'en': 'Qing Ming Jie (Tomb Sweeping Day)',
          'ko': '청명절 (성묘의 날)'
        },
      ),
      Holiday(
        name: 'Qing Ming Jie holiday',
        date: DateTime(2025, 04, 06),
        type: HolidayType.national,
        description: {'en': 'Qing Ming Jie Holiday', 'ko': '청명절 연휴'},
      ),
      Holiday(
        name: 'Labour Day',
        date: DateTime(2025, 05, 01),
        type: HolidayType.national,
        description: {'en': 'Labour Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Labour Day Holiday',
        date: DateTime(2025, 05, 02),
        type: HolidayType.national,
        description: {'en': 'Labour Day Holiday', 'ko': '노동절 연휴'},
      ),
      Holiday(
        name: 'Labour Day Holiday',
        date: DateTime(2025, 05, 03),
        type: HolidayType.national,
        description: {'en': 'Labour Day Holiday', 'ko': '노동절 연휴'},
      ),
      Holiday(
        name: 'Labour Day Holiday',
        date: DateTime(2025, 05, 05),
        type: HolidayType.national,
        description: {'en': 'Labour Day Holiday', 'ko': '노동절 연휴'},
      ),
      Holiday(
        name: 'Dragon Boat Festival',
        date: DateTime(2025, 05, 19),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival', 'ko': '단오절 (용선축제)'},
      ),
      Holiday(
        name: 'Dragon Boat Festival holiday',
        date: DateTime(2025, 05, 20),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival Holiday', 'ko': '단오절 연휴'},
      ),
      Holiday(
        name: 'Dragon Boat Festival holiday',
        date: DateTime(2025, 05, 21),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival Holiday', 'ko': '단오절 연휴'},
      ),
      Holiday(
        name: 'Mid-Autumn Festival',
        date: DateTime(2025, 09, 25),
        type: HolidayType.national,
        description: {'en': 'Mid-Autumn Festival', 'ko': '중추절 (추석)'},
      ),
      Holiday(
        name: 'Mid-Autumn Festival holiday',
        date: DateTime(2025, 09, 26),
        type: HolidayType.national,
        description: {'en': 'Mid-Autumn Festival Holiday', 'ko': '중추절 연휴'},
      ),
      Holiday(
        name: 'Mid-Autumn Festival holiday',
        date: DateTime(2025, 09, 27),
        type: HolidayType.national,
        description: {'en': 'Mid-Autumn Festival Holiday', 'ko': '중추절 연휴'},
      ),
      Holiday(
        name: 'National Day',
        date: DateTime(2025, 10, 01),
        type: HolidayType.national,
        description: {'en': 'National Day', 'ko': '국경절'},
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2025, 10, 02),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2025, 10, 03),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2025, 10, 04),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2025, 10, 05),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2025, 10, 06),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2026, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Spring Festival Eve',
        date: DateTime(2026, 01, 09),
        type: HolidayType.national,
        description: {'en': 'Spring Festival Eve', 'ko': '춘절 전야'},
      ),
      Holiday(
        name: 'Chinese New Year',
        date: DateTime(2026, 01, 10),
        type: HolidayType.national,
        description: {
          'en': 'Chinese New Year (Spring Festival)',
          'ko': '춘절 (중국 신정)'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2026, 01, 11),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2026, 01, 12),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2026, 01, 13),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2026, 01, 14),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2026, 01, 15),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2026, 01, 16),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Spring Festival Golden Week holiday',
        date: DateTime(2026, 01, 17),
        type: HolidayType.national,
        description: {
          'en': 'Spring Festival Golden Week Holiday',
          'ko': '춘절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'Qing Ming Jie',
        date: DateTime(2026, 04, 04),
        type: HolidayType.national,
        description: {
          'en': 'Qing Ming Jie (Tomb Sweeping Day)',
          'ko': '청명절 (성묘의 날)'
        },
      ),
      Holiday(
        name: 'Qing Ming Jie holiday',
        date: DateTime(2026, 04, 05),
        type: HolidayType.national,
        description: {'en': 'Qing Ming Jie Holiday', 'ko': '청명절 연휴'},
      ),
      Holiday(
        name: 'Qing Ming Jie holiday',
        date: DateTime(2026, 04, 06),
        type: HolidayType.national,
        description: {'en': 'Qing Ming Jie Holiday', 'ko': '청명절 연휴'},
      ),
      Holiday(
        name: 'Labour Day',
        date: DateTime(2026, 05, 01),
        type: HolidayType.national,
        description: {'en': 'Labour Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Labour Day Holiday',
        date: DateTime(2026, 05, 02),
        type: HolidayType.national,
        description: {'en': 'Labour Day Holiday', 'ko': '노동절 연휴'},
      ),
      Holiday(
        name: 'Labour Day Holiday',
        date: DateTime(2026, 05, 03),
        type: HolidayType.national,
        description: {'en': 'Labour Day Holiday', 'ko': '노동절 연휴'},
      ),
      Holiday(
        name: 'Labour Day Holiday',
        date: DateTime(2026, 05, 04),
        type: HolidayType.national,
        description: {'en': 'Labour Day Holiday', 'ko': '노동절 연휴'},
      ),
      Holiday(
        name: 'Labour Day Holiday',
        date: DateTime(2026, 05, 05),
        type: HolidayType.national,
        description: {'en': 'Labour Day Holiday', 'ko': '노동절 연휴'},
      ),
      Holiday(
        name: 'Dragon Boat Festival',
        date: DateTime(2026, 05, 10),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival', 'ko': '단오절 (용선축제)'},
      ),
      Holiday(
        name: 'Dragon Boat Festival holiday',
        date: DateTime(2026, 05, 11),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival Holiday', 'ko': '단오절 연휴'},
      ),
      Holiday(
        name: 'Dragon Boat Festival holiday',
        date: DateTime(2026, 05, 12),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival Holiday', 'ko': '단오절 연휴'},
      ),
      Holiday(
        name: 'Mid-Autumn Festival holiday',
        date: DateTime(2026, 09, 15),
        type: HolidayType.national,
        description: {'en': 'Mid-Autumn Festival Holiday', 'ko': '중추절 연휴'},
      ),
      Holiday(
        name: 'Mid-Autumn Festival holiday',
        date: DateTime(2026, 09, 16),
        type: HolidayType.national,
        description: {'en': 'Mid-Autumn Festival Holiday', 'ko': '중추절 연휴'},
      ),
      Holiday(
        name: 'Mid-Autumn Festival',
        date: DateTime(2026, 09, 17),
        type: HolidayType.national,
        description: {'en': 'Mid-Autumn Festival', 'ko': '중추절 (추석)'},
      ),
      Holiday(
        name: 'National Day',
        date: DateTime(2026, 10, 01),
        type: HolidayType.national,
        description: {'en': 'National Day', 'ko': '국경절'},
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2026, 10, 02),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2026, 10, 03),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2026, 10, 04),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2026, 10, 05),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2026, 10, 06),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
      Holiday(
        name: 'National Day Golden Week Holiday',
        date: DateTime(2026, 10, 07),
        type: HolidayType.national,
        description: {
          'en': 'National Day Golden Week Holiday',
          'ko': '국경절 황금주간 연휴'
        },
      ),
    ],
    'JP': [
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2024, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Coming of Age Day',
        date: DateTime(2024, 01, 08),
        type: HolidayType.national,
        description: {'en': 'Coming of Age Day', 'ko': '성인의 날'},
      ),
      Holiday(
        name: 'National Foundation Day',
        date: DateTime(2024, 02, 11),
        type: HolidayType.national,
        description: {'en': 'National Foundation Day', 'ko': '건국기념의 날'},
      ),
      Holiday(
        name: 'National Foundation Day (Observed)',
        date: DateTime(2024, 02, 12),
        type: HolidayType.national,
        description: {
          'en': 'National Foundation Day (Observed)',
          'ko': '건국기념의 날 대체휴일'
        },
      ),
      Holiday(
        name: 'Emperor\'s Birthday',
        date: DateTime(2024, 02, 23),
        type: HolidayType.national,
        description: {'en': 'Emperor\'s Birthday', 'ko': '천황 생일'},
      ),
      Holiday(
        name: 'Spring Equinox',
        date: DateTime(2024, 03, 20),
        type: HolidayType.national,
        description: {'en': 'Spring Equinox', 'ko': '춘분의 날'},
      ),
      Holiday(
        name: 'Shōwa Day',
        date: DateTime(2024, 04, 29),
        type: HolidayType.national,
        description: {'en': 'Shōwa Day', 'ko': '쇼와의 날'},
      ),
      Holiday(
        name: 'Constitution Memorial Day',
        date: DateTime(2024, 05, 03),
        type: HolidayType.national,
        description: {'en': 'Constitution Memorial Day', 'ko': '헌법기념일'},
      ),
      Holiday(
        name: 'Greenery Day',
        date: DateTime(2024, 05, 04),
        type: HolidayType.national,
        description: {'en': 'Greenery Day', 'ko': '녹색의 날'},
      ),
      Holiday(
        name: 'Children\'s Day',
        date: DateTime(2024, 05, 05),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day', 'ko': '어린이날'},
      ),
      Holiday(
        name: 'Children\'s Day (Observed)',
        date: DateTime(2024, 05, 06),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day (Observed)', 'ko': '어린이날 대체휴일'},
      ),
      Holiday(
        name: 'Sea Day',
        date: DateTime(2024, 07, 15),
        type: HolidayType.national,
        description: {'en': 'Sea Day', 'ko': '바다의 날'},
      ),
      Holiday(
        name: 'Mountain Day (Observed)',
        date: DateTime(2024, 08, 12),
        type: HolidayType.national,
        description: {'en': 'Mountain Day (Observed)', 'ko': '산의 날 대체휴일'},
      ),
      Holiday(
        name: 'Respect for the Aged Day',
        date: DateTime(2024, 09, 16),
        type: HolidayType.national,
        description: {'en': 'Respect for the Aged Day', 'ko': '경로의 날'},
      ),
      Holiday(
        name: 'Autumn Equinox',
        date: DateTime(2024, 09, 22),
        type: HolidayType.national,
        description: {'en': 'Autumn Equinox', 'ko': '추분의 날'},
      ),
      Holiday(
        name: 'Autumn Equinox (Observed)',
        date: DateTime(2024, 09, 23),
        type: HolidayType.national,
        description: {'en': 'Autumn Equinox (Observed)', 'ko': '추분의 날 대체휴일'},
      ),
      Holiday(
        name: 'Sports Day',
        date: DateTime(2024, 10, 14),
        type: HolidayType.national,
        description: {'en': 'Sports Day', 'ko': '체육의 날'},
      ),
      Holiday(
        name: 'Culture Day',
        date: DateTime(2024, 11, 03),
        type: HolidayType.national,
        description: {'en': 'Culture Day', 'ko': '문화의 날'},
      ),
      Holiday(
        name: 'Culture Day (Observed)',
        date: DateTime(2024, 11, 04),
        type: HolidayType.national,
        description: {'en': 'Culture Day (Observed)', 'ko': '문화의 날 대체휴일'},
      ),
      Holiday(
        name: 'Labor Thanksgiving Day',
        date: DateTime(2024, 11, 23),
        type: HolidayType.national,
        description: {'en': 'Labor Thanksgiving Day', 'ko': '근로감사의 날'},
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2025, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Coming of Age Day',
        date: DateTime(2025, 01, 13),
        type: HolidayType.national,
        description: {'en': 'Coming of Age Day', 'ko': '성인의 날'},
      ),
      Holiday(
        name: 'National Foundation Day',
        date: DateTime(2025, 02, 11),
        type: HolidayType.national,
        description: {'en': 'National Foundation Day', 'ko': '건국기념의 날'},
      ),
      Holiday(
        name: 'Emperor\'s Birthday',
        date: DateTime(2025, 02, 23),
        type: HolidayType.national,
        description: {'en': 'Emperor\'s Birthday', 'ko': '천황 생일'},
      ),
      Holiday(
        name: 'Emperor\'s Birthday (Observed)',
        date: DateTime(2025, 02, 24),
        type: HolidayType.national,
        description: {
          'en': 'Emperor\'s Birthday (Observed)',
          'ko': '천황 생일 대체휴일'
        },
      ),
      Holiday(
        name: 'Spring Equinox',
        date: DateTime(2025, 03, 20),
        type: HolidayType.national,
        description: {'en': 'Spring Equinox', 'ko': '춘분의 날'},
      ),
      Holiday(
        name: 'Shōwa Day',
        date: DateTime(2025, 04, 29),
        type: HolidayType.national,
        description: {'en': 'Shōwa Day', 'ko': '쇼와의 날'},
      ),
      Holiday(
        name: 'Constitution Memorial Day',
        date: DateTime(2025, 05, 03),
        type: HolidayType.national,
        description: {'en': 'Constitution Memorial Day', 'ko': '헌법기념일'},
      ),
      Holiday(
        name: 'Greenery Day',
        date: DateTime(2025, 05, 04),
        type: HolidayType.national,
        description: {'en': 'Greenery Day', 'ko': '녹색의 날'},
      ),
      Holiday(
        name: 'Children\'s Day',
        date: DateTime(2025, 05, 05),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day', 'ko': '어린이날'},
      ),
      Holiday(
        name: 'Greenery Day (Observed)',
        date: DateTime(2025, 05, 06),
        type: HolidayType.national,
        description: {'en': 'Greenery Day (Observed)', 'ko': '녹색의 날 대체휴일'},
      ),
      Holiday(
        name: 'Sea Day',
        date: DateTime(2025, 07, 21),
        type: HolidayType.national,
        description: {'en': 'Sea Day', 'ko': '바다의 날'},
      ),
      Holiday(
        name: 'Mountain Day',
        date: DateTime(2025, 08, 11),
        type: HolidayType.national,
        description: {'en': 'Mountain Day', 'ko': '산의 날'},
      ),
      Holiday(
        name: 'Respect for the Aged Day',
        date: DateTime(2025, 09, 15),
        type: HolidayType.national,
        description: {'en': 'Respect for the Aged Day', 'ko': '경로의 날'},
      ),
      Holiday(
        name: 'Autumn Equinox',
        date: DateTime(2025, 09, 23),
        type: HolidayType.national,
        description: {'en': 'Autumn Equinox', 'ko': '추분의 날'},
      ),
      Holiday(
        name: 'Sports Day',
        date: DateTime(2025, 10, 13),
        type: HolidayType.national,
        description: {'en': 'Sports Day', 'ko': '체육의 날'},
      ),
      Holiday(
        name: 'Culture Day',
        date: DateTime(2025, 11, 03),
        type: HolidayType.national,
        description: {'en': 'Culture Day', 'ko': '문화의 날'},
      ),
      Holiday(
        name: 'Labor Thanksgiving Day',
        date: DateTime(2025, 11, 23),
        type: HolidayType.national,
        description: {'en': 'Labor Thanksgiving Day', 'ko': '근로감사의 날'},
      ),
      Holiday(
        name: 'Labor Thanksgiving Day (Observed)',
        date: DateTime(2025, 11, 24),
        type: HolidayType.national,
        description: {
          'en': 'Labor Thanksgiving Day (Observed)',
          'ko': '근로감사의 날 대체휴일'
        },
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2026, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Coming of Age Day',
        date: DateTime(2026, 01, 12),
        type: HolidayType.national,
        description: {'en': 'Coming of Age Day', 'ko': '성인의 날'},
      ),
      Holiday(
        name: 'National Foundation Day',
        date: DateTime(2026, 02, 11),
        type: HolidayType.national,
        description: {'en': 'National Foundation Day', 'ko': '건국기념의 날'},
      ),
      Holiday(
        name: 'Emperor\'s Birthday',
        date: DateTime(2026, 02, 23),
        type: HolidayType.national,
        description: {'en': 'Emperor\'s Birthday', 'ko': '천황 생일'},
      ),
      Holiday(
        name: 'Spring Equinox',
        date: DateTime(2026, 03, 20),
        type: HolidayType.national,
        description: {'en': 'Spring Equinox', 'ko': '춘분의 날'},
      ),
      Holiday(
        name: 'Shōwa Day',
        date: DateTime(2026, 04, 29),
        type: HolidayType.national,
        description: {'en': 'Shōwa Day', 'ko': '쇼와의 날'},
      ),
      Holiday(
        name: 'Constitution Memorial Day',
        date: DateTime(2026, 05, 03),
        type: HolidayType.national,
        description: {'en': 'Constitution Memorial Day', 'ko': '헌법기념일'},
      ),
      Holiday(
        name: 'Greenery Day',
        date: DateTime(2026, 05, 04),
        type: HolidayType.national,
        description: {'en': 'Greenery Day', 'ko': '녹색의 날'},
      ),
      Holiday(
        name: 'Children\'s Day',
        date: DateTime(2026, 05, 05),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day', 'ko': '어린이날'},
      ),
      Holiday(
        name: 'Constitution Memorial Day (Observed)',
        date: DateTime(2026, 05, 06),
        type: HolidayType.national,
        description: {
          'en': 'Constitution Memorial Day (Observed)',
          'ko': '헌법기념일 대체휴일'
        },
      ),
      Holiday(
        name: 'Sea Day',
        date: DateTime(2026, 07, 20),
        type: HolidayType.national,
        description: {'en': 'Sea Day', 'ko': '바다의 날'},
      ),
      Holiday(
        name: 'Mountain Day',
        date: DateTime(2026, 08, 11),
        type: HolidayType.national,
        description: {'en': 'Mountain Day', 'ko': '산의 날'},
      ),
      Holiday(
        name: 'Respect for the Aged Day',
        date: DateTime(2026, 09, 21),
        type: HolidayType.national,
        description: {'en': 'Respect for the Aged Day', 'ko': '경로의 날'},
      ),
      Holiday(
        name: 'Bridge Public Holiday',
        date: DateTime(2026, 09, 22),
        type: HolidayType.national,
        description: {'en': 'Bridge Public Holiday', 'ko': '브릿지 공휴일'},
      ),
      Holiday(
        name: 'Autumn Equinox',
        date: DateTime(2026, 09, 23),
        type: HolidayType.national,
        description: {'en': 'Autumn Equinox', 'ko': '추분의 날'},
      ),
      Holiday(
        name: 'Sports Day',
        date: DateTime(2026, 10, 12),
        type: HolidayType.national,
        description: {'en': 'Sports Day', 'ko': '체육의 날'},
      ),
      Holiday(
        name: 'Culture Day',
        date: DateTime(2026, 11, 03),
        type: HolidayType.national,
        description: {'en': 'Culture Day', 'ko': '문화의 날'},
      ),
      Holiday(
        name: 'Labor Thanksgiving Day',
        date: DateTime(2026, 11, 23),
        type: HolidayType.national,
        description: {'en': 'Labor Thanksgiving Day', 'ko': '근로감사의 날'},
      ),
    ],
    'KR': [
      Holiday(
        name: '신정',
        date: DateTime(2024, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '새해 첫날'},
      ),
      Holiday(
        name: '설날',
        date: DateTime(2024, 02, 09),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Eve', 'ko': '음력 새해 (전날)'},
      ),
      Holiday(
        name: '설날',
        date: DateTime(2024, 02, 10),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Day', 'ko': '음력 새해'},
      ),
      Holiday(
        name: '설날',
        date: DateTime(2024, 02, 11),
        type: HolidayType.national,
        description: {
          'en': 'Lunar New Year\'s Day (Second Day)',
          'ko': '음력 새해 (다음날)'
        },
      ),
      Holiday(
        name: '설날 대체공휴일',
        date: DateTime(2024, 02, 12),
        type: HolidayType.national,
        description: {
          'en': 'Lunar New Year Substitute Holiday (Sunday → Monday)',
          'ko': '설날 대체공휴일 (일요일 → 월요일)'
        },
      ),
      Holiday(
        name: '삼일절',
        date: DateTime(2024, 03, 01),
        type: HolidayType.national,
        description: {'en': 'Independence Movement Day', 'ko': '3.1 독립운동 기념일'},
      ),
      Holiday(
        name: '국회의원 선거일',
        date: DateTime(2024, 04, 10),
        type: HolidayType.national,
        description: {
          'en': 'National Assembly Election Day',
          'ko': '22대 국회의원 선거'
        },
      ),
      Holiday(
        name: '부처님 오신 날',
        date: DateTime(2024, 05, 15),
        type: HolidayType.national,
        description: {'en': 'Buddha\'s Birthday', 'ko': '부처님 오신 날'},
      ),
      Holiday(
        name: '어린이날',
        date: DateTime(2024, 05, 05),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day', 'ko': '어린이날'},
      ),
      Holiday(
        name: '어린이날 대체휴일',
        date: DateTime(2024, 05, 06),
        type: HolidayType.national,
        description: {
          'en': 'Children\'s Day Substitute Holiday',
          'ko': '어린이날 대체휴일'
        },
      ),
      Holiday(
        name: '현충일',
        date: DateTime(2024, 06, 06),
        type: HolidayType.national,
        description: {'en': 'Memorial Day', 'ko': '현충일'},
      ),
      Holiday(
        name: '광복절',
        date: DateTime(2024, 08, 15),
        type: HolidayType.national,
        description: {'en': 'Liberation Day', 'ko': '광복절'},
      ),
      Holiday(
        name: '추석',
        date: DateTime(2024, 09, 16),
        type: HolidayType.national,
        description: {
          'en': 'Chuseok (Korean Thanksgiving) Eve',
          'ko': '추석 (전날)'
        },
      ),
      Holiday(
        name: '추석',
        date: DateTime(2024, 09, 17),
        type: HolidayType.national,
        description: {'en': 'Chuseok (Korean Thanksgiving)', 'ko': '추석'},
      ),
      Holiday(
        name: '추석',
        date: DateTime(2024, 09, 18),
        type: HolidayType.national,
        description: {
          'en': 'Chuseok (Korean Thanksgiving) Second Day',
          'ko': '추석 (다음날)'
        },
      ),
      Holiday(
        name: '추석 대체공휴일',
        date: DateTime(2024, 09, 19),
        type: HolidayType.national,
        description: {'en': 'Chuseok Substitute Holiday', 'ko': '추석 대체공휴일'},
      ),
      Holiday(
        name: '개천절',
        date: DateTime(2024, 10, 03),
        type: HolidayType.national,
        description: {'en': 'National Foundation Day', 'ko': '개천절'},
      ),
      Holiday(
        name: '한글날',
        date: DateTime(2024, 10, 09),
        type: HolidayType.national,
        description: {'en': 'Hangul Day', 'ko': '한글날'},
      ),
      Holiday(
        name: '크리스마스',
        date: DateTime(2024, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: '신정',
        date: DateTime(2025, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '새해 첫날'},
      ),
      Holiday(
        name: '설날',
        date: DateTime(2025, 01, 28),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Eve', 'ko': '음력 새해 (전날)'},
      ),
      Holiday(
        name: '설날',
        date: DateTime(2025, 01, 29),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Day', 'ko': '음력 새해'},
      ),
      Holiday(
        name: '설날',
        date: DateTime(2025, 01, 30),
        type: HolidayType.national,
        description: {
          'en': 'Lunar New Year\'s Day (Second Day)',
          'ko': '음력 새해 (다음날)'
        },
      ),
      Holiday(
        name: '설날 대체공휴일',
        date: DateTime(2025, 01, 31),
        type: HolidayType.national,
        description: {
          'en': 'Lunar New Year Substitute Holiday',
          'ko': '설날 대체공휴일'
        },
      ),
      Holiday(
        name: '삼일절',
        date: DateTime(2025, 03, 01),
        type: HolidayType.national,
        description: {'en': 'Independence Movement Day', 'ko': '3.1 독립운동 기념일'},
      ),
      Holiday(
        name: '부처님 오신 날 / 어린이날',
        date: DateTime(2025, 05, 05),
        type: HolidayType.national,
        description: {
          'en': 'Buddha\'s Birthday / Children\'s Day',
          'ko': '부처님 오신 날 / 어린이날'
        },
      ),
      Holiday(
        name: '어린이날 대체휴일',
        date: DateTime(2025, 05, 06),
        type: HolidayType.national,
        description: {
          'en': 'Children\'s Day Substitute Holiday',
          'ko': '어린이날 대체휴일'
        },
      ),
      Holiday(
        name: '현충일',
        date: DateTime(2025, 06, 06),
        type: HolidayType.national,
        description: {'en': 'Memorial Day', 'ko': '현충일'},
      ),
      Holiday(
        name: '광복절',
        date: DateTime(2025, 08, 15),
        type: HolidayType.national,
        description: {'en': 'Liberation Day', 'ko': '광복절'},
      ),
      Holiday(
        name: '추석',
        date: DateTime(2025, 10, 05),
        type: HolidayType.national,
        description: {
          'en': 'Chuseok (Korean Thanksgiving) Eve',
          'ko': '추석 (전날)'
        },
      ),
      Holiday(
        name: '추석',
        date: DateTime(2025, 10, 06),
        type: HolidayType.national,
        description: {'en': 'Chuseok (Korean Thanksgiving)', 'ko': '추석'},
      ),
      Holiday(
        name: '추석',
        date: DateTime(2025, 10, 07),
        type: HolidayType.national,
        description: {
          'en': 'Chuseok (Korean Thanksgiving) Second Day',
          'ko': '추석 (다음날)'
        },
      ),
      Holiday(
        name: '추석 대체공휴일',
        date: DateTime(2025, 10, 08),
        type: HolidayType.national,
        description: {'en': 'Chuseok Substitute Holiday', 'ko': '추석 대체공휴일'},
      ),
      Holiday(
        name: '개천절',
        date: DateTime(2025, 10, 03),
        type: HolidayType.national,
        description: {'en': 'National Foundation Day', 'ko': '개천절'},
      ),
      Holiday(
        name: '한글날',
        date: DateTime(2025, 10, 09),
        type: HolidayType.national,
        description: {'en': 'Hangul Day', 'ko': '한글날'},
      ),
      Holiday(
        name: '크리스마스',
        date: DateTime(2025, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: '신정',
        date: DateTime(2026, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '새해 첫날'},
      ),
      Holiday(
        name: '설날',
        date: DateTime(2026, 02, 16),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Eve', 'ko': '음력 새해 (전날)'},
      ),
      Holiday(
        name: '설날',
        date: DateTime(2026, 02, 17),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Day', 'ko': '음력 새해'},
      ),
      Holiday(
        name: '설날',
        date: DateTime(2026, 02, 18),
        type: HolidayType.national,
        description: {
          'en': 'Lunar New Year\'s Day (Second Day)',
          'ko': '음력 새해 (다음날)'
        },
      ),
      Holiday(
        name: '삼일절',
        date: DateTime(2026, 03, 01),
        type: HolidayType.national,
        description: {'en': 'Independence Movement Day', 'ko': '3.1 독립운동 기념일'},
      ),
      Holiday(
        name: '삼일절 대체휴일',
        date: DateTime(2026, 03, 02),
        type: HolidayType.national,
        description: {'en': 'Independence Movement Day', 'ko': '3.1 독립운동 기념일'},
      ),
      Holiday(
        name: '어린이날',
        date: DateTime(2026, 05, 05),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day', 'ko': '어린이날'},
      ),
      Holiday(
        name: '부처님 오신 날',
        date: DateTime(2026, 05, 24),
        type: HolidayType.national,
        description: {'en': 'Buddha\'s Birthday', 'ko': '부처님 오신 날'},
      ),
      Holiday(
        name: '대체휴일',
        date: DateTime(2026, 05, 25),
        type: HolidayType.national,
        description: {'en': 'Buddha\'s Birthday', 'ko': '부처님 오신 날'},
      ),
      Holiday(
        name: '지방선거',
        date: DateTime(2026, 06, 03),
        type: HolidayType.national,
        description: {'en': 'Local election', 'ko': '2026 지방선거'},
      ),
      Holiday(
        name: '현충일',
        date: DateTime(2026, 06, 06),
        type: HolidayType.national,
        description: {'en': 'Memorial Day', 'ko': '현충일'},
      ),
      Holiday(
        name: '광복절',
        date: DateTime(2026, 08, 15),
        type: HolidayType.national,
        description: {'en': 'Liberation Day', 'ko': '광복절'},
      ),
      Holiday(
        name: '광복절 대체휴일',
        date: DateTime(2026, 08, 17),
        type: HolidayType.national,
        description: {'en': 'Liberation Day', 'ko': '광복절'},
      ),
      Holiday(
        name: '추석',
        date: DateTime(2026, 09, 24),
        type: HolidayType.national,
        description: {
          'en': 'Chuseok (Korean Thanksgiving) Eve',
          'ko': '추석 (전날)'
        },
      ),
      Holiday(
        name: '추석',
        date: DateTime(2026, 09, 25),
        type: HolidayType.national,
        description: {'en': 'Chuseok (Korean Thanksgiving)', 'ko': '추석'},
      ),
      Holiday(
        name: '추석',
        date: DateTime(2026, 09, 26),
        type: HolidayType.national,
        description: {
          'en': 'Chuseok (Korean Thanksgiving) Second Day',
          'ko': '추석 (다음날)'
        },
      ),
      Holiday(
        name: '개천절',
        date: DateTime(2026, 10, 03),
        type: HolidayType.national,
        description: {'en': 'National Foundation Day', 'ko': '개천절'},
      ),
      Holiday(
        name: '개천절 대체휴일',
        date: DateTime(2026, 10, 05),
        type: HolidayType.national,
        description: {'en': 'National Foundation Day', 'ko': '개천절'},
      ),
      Holiday(
        name: '한글날',
        date: DateTime(2026, 10, 09),
        type: HolidayType.national,
        description: {'en': 'Hangul Day', 'ko': '한글날'},
      ),
      Holiday(
        name: '크리스마스',
        date: DateTime(2026, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
    ],
    'MY': [
      Holiday(
        name: 'Chinese New Year\'s Day',
        date: DateTime(2024, 02, 10),
        type: HolidayType.national,
        description: {'en': 'Chinese New Year\'s Day', 'ko': '중국 신정'},
      ),
      Holiday(
        name: 'Second Day of Chinese New Year',
        date: DateTime(2024, 02, 11),
        type: HolidayType.national,
        description: {
          'en': 'Second Day of Chinese New Year (Most regions)',
          'ko': '중국 신정 둘째 날 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Chinese New Year Holiday',
        date: DateTime(2024, 02, 12),
        type: HolidayType.national,
        description: {
          'en': 'Chinese New Year Holiday (Many regions)',
          'ko': '중국 신정 연휴 (많은 지역)'
        },
      ),
      Holiday(
        name: 'Hari Raya Puasa',
        date: DateTime(2024, 04, 10),
        type: HolidayType.national,
        description: {
          'en': 'Hari Raya Puasa (Eid al-Fitr)',
          'ko': '하리 라야 푸아사 (이드 알 피트르)'
        },
      ),
      Holiday(
        name: 'Hari Raya Puasa Day 2',
        date: DateTime(2024, 04, 11),
        type: HolidayType.national,
        description: {'en': 'Hari Raya Puasa Day 2', 'ko': '하리 라야 푸아사 둘째 날'},
      ),
      Holiday(
        name: 'Labour Day',
        date: DateTime(2024, 05, 01),
        type: HolidayType.national,
        description: {'en': 'Labour Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Wesak Day',
        date: DateTime(2024, 05, 22),
        type: HolidayType.national,
        description: {
          'en': 'Wesak Day (Buddha\'s Birthday)',
          'ko': '웨삭절 (부처님 오신 날)'
        },
      ),
      Holiday(
        name: 'The Yang di-Pertuan Agong\'s Birthday',
        date: DateTime(2024, 06, 03),
        type: HolidayType.national,
        description: {
          'en': 'The Yang di-Pertuan Agong\'s Birthday',
          'ko': '양 디 페르투안 아공 생일'
        },
      ),
      Holiday(
        name: 'Hari Raya Haji',
        date: DateTime(2024, 06, 17),
        type: HolidayType.national,
        description: {
          'en': 'Hari Raya Haji (Eid al-Adha)',
          'ko': '하리 라야 하지 (이드 알 아드하)'
        },
      ),
      Holiday(
        name: 'Hari Raya Haji (Day 2)',
        date: DateTime(2024, 06, 18),
        type: HolidayType.national,
        description: {
          'en': 'Hari Raya Haji (Day 2) (Kelantan, Terengganu)',
          'ko': '하리 라야 하지 둘째 날 (클란탄, 트렝가누)'
        },
      ),
      Holiday(
        name: 'Muharram/New Year',
        date: DateTime(2024, 07, 07),
        type: HolidayType.national,
        description: {
          'en': 'Muharram/New Year (Islamic New Year)',
          'ko': '무하람/신년 (이슬람 신년)'
        },
      ),
      Holiday(
        name: 'Malaysia\'s National Day',
        date: DateTime(2024, 08, 31),
        type: HolidayType.national,
        description: {'en': 'Malaysia\'s National Day', 'ko': '말레이시아 국경절'},
      ),
      Holiday(
        name: 'The Prophet Muhammad\'s Birthday / Malaysia Day',
        date: DateTime(2024, 09, 16),
        type: HolidayType.national,
        description: {
          'en': 'The Prophet Muhammad\'s Birthday / Malaysia Day',
          'ko': '예언자 무함마드 생일 / 말레이시아의 날'
        },
      ),
      Holiday(
        name: 'Diwali/Deepavali',
        date: DateTime(2024, 10, 31),
        type: HolidayType.national,
        description: {
          'en': 'Diwali/Deepavali (Most regions)',
          'ko': '디왈리/디파발리 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2024, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: 'Chinese New Year\'s Day',
        date: DateTime(2025, 01, 29),
        type: HolidayType.national,
        description: {'en': 'Chinese New Year\'s Day', 'ko': '중국 신정'},
      ),
      Holiday(
        name: 'Second Day of Chinese New Year',
        date: DateTime(2025, 01, 30),
        type: HolidayType.national,
        description: {
          'en': 'Second Day of Chinese New Year (Most regions)',
          'ko': '중국 신정 둘째 날 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Hari Raya Puasa',
        date: DateTime(2025, 03, 31),
        type: HolidayType.national,
        description: {
          'en': 'Hari Raya Puasa (Eid al-Fitr)',
          'ko': '하리 라야 푸아사 (이드 알 피트르)'
        },
      ),
      Holiday(
        name: 'Hari Raya Puasa Day 2',
        date: DateTime(2025, 04, 01),
        type: HolidayType.national,
        description: {'en': 'Hari Raya Puasa Day 2', 'ko': '하리 라야 푸아사 둘째 날'},
      ),
      Holiday(
        name: 'Labour Day',
        date: DateTime(2025, 05, 01),
        type: HolidayType.national,
        description: {'en': 'Labour Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Wesak Day',
        date: DateTime(2025, 05, 12),
        type: HolidayType.national,
        description: {
          'en': 'Wesak Day (Buddha\'s Birthday)',
          'ko': '웨삭절 (부처님 오신 날)'
        },
      ),
      Holiday(
        name: 'The Yang di-Pertuan Agong\'s Birthday',
        date: DateTime(2025, 06, 02),
        type: HolidayType.national,
        description: {
          'en': 'The Yang di-Pertuan Agong\'s Birthday',
          'ko': '양 디 페르투안 아공 생일'
        },
      ),
      Holiday(
        name: 'Hari Raya Haji',
        date: DateTime(2025, 06, 07),
        type: HolidayType.national,
        description: {
          'en': 'Hari Raya Haji (Eid al-Adha)',
          'ko': '하리 라야 하지 (이드 알 아드하)'
        },
      ),
      Holiday(
        name: 'Hari Raya Haji (Day 2)',
        date: DateTime(2025, 06, 08),
        type: HolidayType.national,
        description: {
          'en': 'Hari Raya Haji (Day 2) (Kelantan, Terengganu)',
          'ko': '하리 라야 하지 둘째 날 (클란탄, 트렝가누)'
        },
      ),
      Holiday(
        name: 'Muharram/New Year',
        date: DateTime(2025, 06, 27),
        type: HolidayType.national,
        description: {
          'en': 'Muharram/New Year (Islamic New Year)',
          'ko': '무하람/신년 (이슬람 신년)'
        },
      ),
      Holiday(
        name: 'Malaysia\'s National Day',
        date: DateTime(2025, 08, 31),
        type: HolidayType.national,
        description: {'en': 'Malaysia\'s National Day', 'ko': '말레이시아 국경절'},
      ),
      Holiday(
        name: 'The Prophet Muhammad\'s Birthday',
        date: DateTime(2025, 09, 05),
        type: HolidayType.national,
        description: {
          'en': 'The Prophet Muhammad\'s Birthday',
          'ko': '예언자 무함마드 생일'
        },
      ),
      Holiday(
        name: 'Malaysia Day Holiday',
        date: DateTime(2025, 09, 15),
        type: HolidayType.national,
        description: {'en': 'Malaysia Day Holiday', 'ko': '말레이시아의 날 연휴'},
      ),
      Holiday(
        name: 'Malaysia Day',
        date: DateTime(2025, 09, 16),
        type: HolidayType.national,
        description: {'en': 'Malaysia Day', 'ko': '말레이시아의 날'},
      ),
      Holiday(
        name: 'Diwali/Deepavali',
        date: DateTime(2025, 10, 20),
        type: HolidayType.national,
        description: {
          'en': 'Diwali/Deepavali (Most regions)',
          'ko': '디왈리/디파발리 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2025, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: 'Chinese New Year\'s Day',
        date: DateTime(2026, 02, 17),
        type: HolidayType.national,
        description: {'en': 'Chinese New Year\'s Day', 'ko': '중국 신정'},
      ),
      Holiday(
        name: 'Second Day of Chinese New Year',
        date: DateTime(2026, 02, 18),
        type: HolidayType.national,
        description: {
          'en': 'Second Day of Chinese New Year (Most regions)',
          'ko': '중국 신정 둘째 날 (대부분 지역)'
        },
      ),
      Holiday(
        name: 'Hari Raya Puasa',
        date: DateTime(2026, 03, 20),
        type: HolidayType.national,
        description: {
          'en': 'Hari Raya Puasa (Eid al-Fitr)',
          'ko': '하리 라야 푸아사 (이드 알 피트르)'
        },
      ),
      Holiday(
        name: 'Hari Raya Puasa Day 2',
        date: DateTime(2026, 03, 21),
        type: HolidayType.national,
        description: {'en': 'Hari Raya Puasa Day 2', 'ko': '하리 라야 푸아사 둘째 날'},
      ),
      Holiday(
        name: 'Labour Day',
        date: DateTime(2026, 05, 01),
        type: HolidayType.national,
        description: {'en': 'Labour Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Hari Raya Haji',
        date: DateTime(2026, 05, 27),
        type: HolidayType.national,
        description: {
          'en': 'Hari Raya Haji (Eid al-Adha)',
          'ko': '하리 라야 하지 (이드 알 아드하)'
        },
      ),
      Holiday(
        name: 'Hari Raya Haji (Day 2)',
        date: DateTime(2026, 05, 28),
        type: HolidayType.national,
        description: {
          'en': 'Hari Raya Haji (Day 2) (Kelantan, Terengganu)',
          'ko': '하리 라야 하지 둘째 날 (클란탄, 트렝가누)'
        },
      ),
      Holiday(
        name: 'The Yang di-Pertuan Agong\'s Birthday',
        date: DateTime(2026, 06, 01),
        type: HolidayType.national,
        description: {
          'en': 'The Yang di-Pertuan Agong\'s Birthday',
          'ko': '양 디 페르투안 아공 생일'
        },
      ),
      Holiday(
        name: 'Muharram/New Year',
        date: DateTime(2026, 06, 17),
        type: HolidayType.national,
        description: {
          'en': 'Muharram/New Year (Islamic New Year)',
          'ko': '무하람/신년 (이슬람 신년)'
        },
      ),
      Holiday(
        name: 'The Prophet Muhammad\'s Birthday',
        date: DateTime(2026, 08, 26),
        type: HolidayType.national,
        description: {
          'en': 'The Prophet Muhammad\'s Birthday',
          'ko': '예언자 무함마드 생일'
        },
      ),
      Holiday(
        name: 'Malaysia\'s National Day',
        date: DateTime(2026, 08, 31),
        type: HolidayType.national,
        description: {'en': 'Malaysia\'s National Day', 'ko': '말레이시아 국경절'},
      ),
      Holiday(
        name: 'Malaysia Day',
        date: DateTime(2026, 09, 16),
        type: HolidayType.national,
        description: {'en': 'Malaysia Day', 'ko': '말레이시아의 날'},
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2026, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
    ],
    'TH': [
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2024, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Makha Bucha (Observed)',
        date: DateTime(2024, 02, 26),
        type: HolidayType.national,
        description: {'en': 'Makha Bucha (Observed)', 'ko': '마카 부차 대체휴일'},
      ),
      Holiday(
        name: 'Chakri Day (Observed)',
        date: DateTime(2024, 04, 08),
        type: HolidayType.national,
        description: {'en': 'Chakri Day (Observed)', 'ko': '차크리 왕조 기념일 대체휴일'},
      ),
      Holiday(
        name: 'Songkran Holiday',
        date: DateTime(2024, 04, 12),
        type: HolidayType.national,
        description: {'en': 'Songkran Holiday', 'ko': '송크란 연휴'},
      ),
      Holiday(
        name: 'Songkran',
        date: DateTime(2024, 04, 13),
        type: HolidayType.national,
        description: {'en': 'Songkran (Thai New Year)', 'ko': '송크란 (태국 신정)'},
      ),
      Holiday(
        name: 'Songkran Holiday',
        date: DateTime(2024, 04, 14),
        type: HolidayType.national,
        description: {'en': 'Songkran Holiday', 'ko': '송크란 연휴'},
      ),
      Holiday(
        name: 'Songkran Holiday',
        date: DateTime(2024, 04, 15),
        type: HolidayType.national,
        description: {'en': 'Songkran Holiday', 'ko': '송크란 연휴'},
      ),
      Holiday(
        name: 'Songkran Observed',
        date: DateTime(2024, 04, 16),
        type: HolidayType.national,
        description: {'en': 'Songkran Observed', 'ko': '송크란 대체휴일'},
      ),
      Holiday(
        name: 'Coronation Day (Observed)',
        date: DateTime(2024, 05, 06),
        type: HolidayType.national,
        description: {'en': 'Coronation Day (Observed)', 'ko': '대관식 기념일 대체휴일'},
      ),
      Holiday(
        name: 'Royal Ploughing Ceremony Day',
        date: DateTime(2024, 05, 10),
        type: HolidayType.national,
        description: {
          'en': 'Royal Ploughing Ceremony Day',
          'ko': '왕실 쟁기질 의식의 날'
        },
      ),
      Holiday(
        name: 'Visakha Bucha',
        date: DateTime(2024, 05, 22),
        type: HolidayType.national,
        description: {
          'en': 'Visakha Bucha (Buddha\'s Birthday)',
          'ko': '위사카 부차 (부처님 오신 날)'
        },
      ),
      Holiday(
        name: 'Queen Suthida\'s Birthday',
        date: DateTime(2024, 06, 03),
        type: HolidayType.national,
        description: {'en': 'Queen Suthida\'s Birthday', 'ko': '수티다 왕비 생일'},
      ),
      Holiday(
        name: 'Asalha Bucha (Observed)',
        date: DateTime(2024, 07, 22),
        type: HolidayType.national,
        description: {'en': 'Asalha Bucha (Observed)', 'ko': '아살하 부차 대체휴일'},
      ),
      Holiday(
        name: 'King Vajiralongkorn\'s Birthday (Observed)',
        date: DateTime(2024, 07, 29),
        type: HolidayType.national,
        description: {
          'en': 'King Vajiralongkorn\'s Birthday (Observed)',
          'ko': '바지랄롱콘 국왕 생일 대체휴일'
        },
      ),
      Holiday(
        name: 'The Queen Mother\'s Birthday',
        date: DateTime(2024, 08, 12),
        type: HolidayType.national,
        description: {'en': 'The Queen Mother\'s Birthday', 'ko': '왕대비 생일'},
      ),
      Holiday(
        name: 'Anniversary of the Death of King Bhumibol (Observed)',
        date: DateTime(2024, 10, 14),
        type: HolidayType.national,
        description: {
          'en': 'Anniversary of the Death of King Bhumibol (Observed)',
          'ko': '푸미폰 국왕 서거 기념일 대체휴일'
        },
      ),
      Holiday(
        name: 'Chulalongkorn Day',
        date: DateTime(2024, 10, 23),
        type: HolidayType.national,
        description: {'en': 'Chulalongkorn Day', 'ko': '출라롱콘의 날'},
      ),
      Holiday(
        name: 'King Bhumibol\'s Birthday/Father\'s Day',
        date: DateTime(2024, 12, 05),
        type: HolidayType.national,
        description: {
          'en': 'King Bhumibol\'s Birthday/Father\'s Day',
          'ko': '푸미폰 국왕 생일/아버지의 날'
        },
      ),
      Holiday(
        name: 'Constitution Day',
        date: DateTime(2024, 12, 10),
        type: HolidayType.national,
        description: {'en': 'Constitution Day', 'ko': '헌법의 날'},
      ),
      Holiday(
        name: 'New Year Special Holiday',
        date: DateTime(2024, 12, 30),
        type: HolidayType.national,
        description: {'en': 'New Year Special Holiday', 'ko': '신정 특별휴일'},
      ),
      Holiday(
        name: 'New Year\'s Eve',
        date: DateTime(2024, 12, 31),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Eve', 'ko': '신정 전야'},
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2025, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Makha Bucha',
        date: DateTime(2025, 02, 12),
        type: HolidayType.national,
        description: {'en': 'Makha Bucha', 'ko': '마카 부차'},
      ),
      Holiday(
        name: 'Chakri Day (Observed)',
        date: DateTime(2025, 04, 07),
        type: HolidayType.national,
        description: {'en': 'Chakri Day (Observed)', 'ko': '차크리 왕조 기념일 대체휴일'},
      ),
      Holiday(
        name: 'Songkran',
        date: DateTime(2025, 04, 13),
        type: HolidayType.national,
        description: {'en': 'Songkran (Thai New Year)', 'ko': '송크란 (태국 신정)'},
      ),
      Holiday(
        name: 'Songkran Holiday',
        date: DateTime(2025, 04, 14),
        type: HolidayType.national,
        description: {'en': 'Songkran Holiday', 'ko': '송크란 연휴'},
      ),
      Holiday(
        name: 'Songkran Holiday',
        date: DateTime(2025, 04, 15),
        type: HolidayType.national,
        description: {'en': 'Songkran Holiday', 'ko': '송크란 연휴'},
      ),
      Holiday(
        name: 'Songkran Observed',
        date: DateTime(2025, 04, 16),
        type: HolidayType.national,
        description: {'en': 'Songkran Observed', 'ko': '송크란 대체휴일'},
      ),
      Holiday(
        name: 'Coronation Day (Observed)',
        date: DateTime(2025, 05, 05),
        type: HolidayType.national,
        description: {'en': 'Coronation Day (Observed)', 'ko': '대관식 기념일 대체휴일'},
      ),
      Holiday(
        name: 'Royal Ploughing Ceremony Day',
        date: DateTime(2025, 05, 09),
        type: HolidayType.national,
        description: {
          'en': 'Royal Ploughing Ceremony Day',
          'ko': '왕실 쟁기질 의식의 날'
        },
      ),
      Holiday(
        name: 'Visakha Bucha (Observed)',
        date: DateTime(2025, 05, 12),
        type: HolidayType.national,
        description: {'en': 'Visakha Bucha (Observed)', 'ko': '위사카 부차 대체휴일'},
      ),
      Holiday(
        name: 'Bridge Public Holiday',
        date: DateTime(2025, 06, 02),
        type: HolidayType.national,
        description: {'en': 'Bridge Public Holiday', 'ko': '브릿지 공휴일'},
      ),
      Holiday(
        name: 'Queen Suthida\'s Birthday',
        date: DateTime(2025, 06, 03),
        type: HolidayType.national,
        description: {'en': 'Queen Suthida\'s Birthday', 'ko': '수티다 왕비 생일'},
      ),
      Holiday(
        name: 'Asalha Bucha',
        date: DateTime(2025, 07, 10),
        type: HolidayType.national,
        description: {'en': 'Asalha Bucha', 'ko': '아살하 부차'},
      ),
      Holiday(
        name: 'King Vajiralongkorn\'s Birthday',
        date: DateTime(2025, 07, 28),
        type: HolidayType.national,
        description: {
          'en': 'King Vajiralongkorn\'s Birthday',
          'ko': '바지랄롱콘 국왕 생일'
        },
      ),
      Holiday(
        name: 'Bridge Public Holiday',
        date: DateTime(2025, 08, 11),
        type: HolidayType.national,
        description: {'en': 'Bridge Public Holiday', 'ko': '브릿지 공휴일'},
      ),
      Holiday(
        name: 'The Queen Mother\'s Birthday',
        date: DateTime(2025, 08, 12),
        type: HolidayType.national,
        description: {'en': 'The Queen Mother\'s Birthday', 'ko': '왕대비 생일'},
      ),
      Holiday(
        name: 'Anniversary of the Death of King Bhumibol',
        date: DateTime(2025, 10, 13),
        type: HolidayType.national,
        description: {
          'en': 'Anniversary of the Death of King Bhumibol',
          'ko': '푸미폰 국왕 서거 기념일'
        },
      ),
      Holiday(
        name: 'Chulalongkorn Day',
        date: DateTime(2025, 10, 23),
        type: HolidayType.national,
        description: {'en': 'Chulalongkorn Day', 'ko': '출라롱콘의 날'},
      ),
      Holiday(
        name: 'King Bhumibol\'s Birthday/Father\'s Day',
        date: DateTime(2025, 12, 05),
        type: HolidayType.national,
        description: {
          'en': 'King Bhumibol\'s Birthday/Father\'s Day',
          'ko': '푸미폰 국왕 생일/아버지의 날'
        },
      ),
      Holiday(
        name: 'Constitution Day',
        date: DateTime(2025, 12, 10),
        type: HolidayType.national,
        description: {'en': 'Constitution Day', 'ko': '헌법의 날'},
      ),
      Holiday(
        name: 'New Year\'s Eve',
        date: DateTime(2025, 12, 31),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Eve', 'ko': '신정 전야'},
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2026, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'New Year Special Holiday',
        date: DateTime(2026, 01, 02),
        type: HolidayType.national,
        description: {'en': 'New Year Special Holiday', 'ko': '신정 특별휴일'},
      ),
      Holiday(
        name: 'Makha Bucha',
        date: DateTime(2026, 03, 03),
        type: HolidayType.national,
        description: {'en': 'Makha Bucha', 'ko': '마카 부차'},
      ),
      Holiday(
        name: 'Chakri Day',
        date: DateTime(2026, 04, 06),
        type: HolidayType.national,
        description: {'en': 'Chakri Day', 'ko': '차크리 왕조 기념일'},
      ),
      Holiday(
        name: 'Songkran',
        date: DateTime(2026, 04, 13),
        type: HolidayType.national,
        description: {'en': 'Songkran (Thai New Year)', 'ko': '송크란 (태국 신정)'},
      ),
      Holiday(
        name: 'Songkran Holiday',
        date: DateTime(2026, 04, 14),
        type: HolidayType.national,
        description: {'en': 'Songkran Holiday', 'ko': '송크란 연휴'},
      ),
      Holiday(
        name: 'Songkran Holiday',
        date: DateTime(2026, 04, 15),
        type: HolidayType.national,
        description: {'en': 'Songkran Holiday', 'ko': '송크란 연휴'},
      ),
      Holiday(
        name: 'Coronation Day',
        date: DateTime(2026, 05, 04),
        type: HolidayType.national,
        description: {'en': 'Coronation Day', 'ko': '대관식 기념일'},
      ),
      Holiday(
        name: 'Visakha Bucha (Observed)',
        date: DateTime(2026, 06, 01),
        type: HolidayType.national,
        description: {'en': 'Visakha Bucha (Observed)', 'ko': '위사카 부차 대체휴일'},
      ),
      Holiday(
        name: 'Queen Suthida\'s Birthday',
        date: DateTime(2026, 06, 03),
        type: HolidayType.national,
        description: {'en': 'Queen Suthida\'s Birthday', 'ko': '수티다 왕비 생일'},
      ),
      Holiday(
        name: 'King Vajiralongkorn\'s Birthday',
        date: DateTime(2026, 07, 28),
        type: HolidayType.national,
        description: {
          'en': 'King Vajiralongkorn\'s Birthday',
          'ko': '바지랄롱콘 국왕 생일'
        },
      ),
      Holiday(
        name: 'Asalha Bucha',
        date: DateTime(2026, 07, 29),
        type: HolidayType.national,
        description: {'en': 'Asalha Bucha', 'ko': '아살하 부차'},
      ),
      Holiday(
        name: 'The Queen Mother\'s Birthday',
        date: DateTime(2026, 08, 12),
        type: HolidayType.national,
        description: {'en': 'The Queen Mother\'s Birthday', 'ko': '왕대비 생일'},
      ),
      Holiday(
        name: 'Anniversary of the Death of King Bhumibol',
        date: DateTime(2026, 10, 13),
        type: HolidayType.national,
        description: {
          'en': 'Anniversary of the Death of King Bhumibol',
          'ko': '푸미폰 국왕 서거 기념일'
        },
      ),
      Holiday(
        name: 'Chulalongkorn Day',
        date: DateTime(2026, 10, 23),
        type: HolidayType.national,
        description: {'en': 'Chulalongkorn Day', 'ko': '출라롱콘의 날'},
      ),
      Holiday(
        name: 'King Bhumibol\'s Birthday/Father\'s Day',
        date: DateTime(2026, 12, 05),
        type: HolidayType.national,
        description: {
          'en': 'King Bhumibol\'s Birthday/Father\'s Day',
          'ko': '푸미폰 국왕 생일/아버지의 날'
        },
      ),
      Holiday(
        name: 'King Bhumibol\'s Birthday/Father\'s Day (Observed)',
        date: DateTime(2026, 12, 07),
        type: HolidayType.national,
        description: {
          'en': 'King Bhumibol\'s Birthday/Father\'s Day (Observed)',
          'ko': '푸미폰 국왕 생일/아버지의 날 대체휴일'
        },
      ),
      Holiday(
        name: 'Constitution Day',
        date: DateTime(2026, 12, 10),
        type: HolidayType.national,
        description: {'en': 'Constitution Day', 'ko': '헌법의 날'},
      ),
      Holiday(
        name: 'New Year\'s Eve',
        date: DateTime(2026, 12, 31),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Eve', 'ko': '신정 전야'},
      ),
    ],
    'TW': [
      Holiday(
        name: 'Republic Day',
        date: DateTime(2024, 01, 01),
        type: HolidayType.national,
        description: {'en': 'Republic Day', 'ko': '중화민국 건국기념일'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2024, 02, 08),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year\'s Eve',
        date: DateTime(2024, 02, 09),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Eve', 'ko': '설날 전야'},
      ),
      Holiday(
        name: 'Lunar New Year\'s Day',
        date: DateTime(2024, 02, 10),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Day', 'ko': '설날'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2024, 02, 11),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2024, 02, 12),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2024, 02, 13),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2024, 02, 14),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Peace Memorial Day',
        date: DateTime(2024, 02, 28),
        type: HolidayType.national,
        description: {'en': 'Peace Memorial Day', 'ko': '평화기념일'},
      ),
      Holiday(
        name: 'Tomb Sweeping Day / Children\'s Day',
        date: DateTime(2024, 04, 04),
        type: HolidayType.national,
        description: {
          'en': 'Tomb Sweeping Day / Children\'s Day',
          'ko': '청명절 / 어린이날'
        },
      ),
      Holiday(
        name: 'Children\'s Day',
        date: DateTime(2024, 04, 05),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day', 'ko': '어린이날'},
      ),
      Holiday(
        name: 'Children\'s Day',
        date: DateTime(2024, 04, 06),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day', 'ko': '어린이날'},
      ),
      Holiday(
        name: 'Children\'s Day',
        date: DateTime(2024, 04, 07),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day', 'ko': '어린이날'},
      ),
      Holiday(
        name: 'Labor Day (Private Sector Only)',
        date: DateTime(2024, 05, 01),
        type: HolidayType.regional,
        description: {
          'en': 'Labor Day (Private Sector Only)',
          'ko': '노동절 (민간부문만)'
        },
      ),
      Holiday(
        name: 'Dragon Boat Festival',
        date: DateTime(2024, 06, 10),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival', 'ko': '단오절'},
      ),
      Holiday(
        name: 'Mid-Autumn Festival',
        date: DateTime(2024, 09, 17),
        type: HolidayType.national,
        description: {'en': 'Mid-Autumn Festival', 'ko': '중추절'},
      ),
      Holiday(
        name: 'National Day',
        date: DateTime(2024, 10, 10),
        type: HolidayType.national,
        description: {'en': 'National Day', 'ko': '국경일'},
      ),
      Holiday(
        name: 'Republic Day',
        date: DateTime(2025, 01, 01),
        type: HolidayType.national,
        description: {'en': 'Republic Day', 'ko': '중화민국 건국기념일'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2025, 01, 27),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year\'s Eve',
        date: DateTime(2025, 01, 28),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Eve', 'ko': '설날 전야'},
      ),
      Holiday(
        name: 'Lunar New Year\'s Day',
        date: DateTime(2025, 01, 29),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Day', 'ko': '설날'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2025, 01, 30),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2025, 01, 31),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2025, 02, 01),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2025, 02, 02),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Peace Memorial Day',
        date: DateTime(2025, 02, 28),
        type: HolidayType.national,
        description: {'en': 'Peace Memorial Day', 'ko': '평화기념일'},
      ),
      Holiday(
        name: 'Children\'s Day',
        date: DateTime(2025, 04, 03),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day', 'ko': '어린이날'},
      ),
      Holiday(
        name: 'Tomb Sweeping Day / Children\'s Day',
        date: DateTime(2025, 04, 04),
        type: HolidayType.national,
        description: {
          'en': 'Tomb Sweeping Day / Children\'s Day',
          'ko': '청명절 / 어린이날'
        },
      ),
      Holiday(
        name: 'Labor Day (Private Sector Only)',
        date: DateTime(2025, 05, 01),
        type: HolidayType.regional,
        description: {
          'en': 'Labor Day (Private Sector Only)',
          'ko': '노동절 (민간부문만)'
        },
      ),
      Holiday(
        name: 'Dragon Boat Festival Holiday',
        date: DateTime(2025, 05, 30),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival Holiday', 'ko': '단오절 연휴'},
      ),
      Holiday(
        name: 'Dragon Boat Festival',
        date: DateTime(2025, 05, 31),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival', 'ko': '단오절'},
      ),
      Holiday(
        name: 'Day off for Teachers\' Day',
        date: DateTime(2025, 09, 29),
        type: HolidayType.national,
        description: {'en': 'Day off for Teachers\' Day', 'ko': '스승의 날 대체휴일'},
      ),
      Holiday(
        name: 'Mid-Autumn Festival',
        date: DateTime(2025, 10, 06),
        type: HolidayType.national,
        description: {'en': 'Mid-Autumn Festival', 'ko': '중추절'},
      ),
      Holiday(
        name: 'National Day',
        date: DateTime(2025, 10, 10),
        type: HolidayType.national,
        description: {'en': 'National Day', 'ko': '국경일'},
      ),
      Holiday(
        name: 'Day off for Taiwan\'s Retrocession Day',
        date: DateTime(2025, 10, 24),
        type: HolidayType.national,
        description: {
          'en': 'Day off for Taiwan\'s Retrocession Day',
          'ko': '대만 광복절 대체휴일'
        },
      ),
      Holiday(
        name: 'Constitution Day',
        date: DateTime(2025, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Constitution Day', 'ko': '헌법기념일'},
      ),
      Holiday(
        name: 'Republic Day',
        date: DateTime(2026, 01, 01),
        type: HolidayType.national,
        description: {'en': 'Republic Day', 'ko': '중화민국 건국기념일'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2026, 02, 14),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2026, 02, 15),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year\'s Eve',
        date: DateTime(2026, 02, 16),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Eve', 'ko': '설날 전야'},
      ),
      Holiday(
        name: 'Lunar New Year\'s Day',
        date: DateTime(2026, 02, 17),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year\'s Day', 'ko': '설날'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2026, 02, 18),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2026, 02, 19),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2026, 02, 20),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2026, 02, 21),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Lunar New Year Holiday',
        date: DateTime(2026, 02, 22),
        type: HolidayType.national,
        description: {'en': 'Lunar New Year Holiday', 'ko': '설날 연휴'},
      ),
      Holiday(
        name: 'Peace Memorial Day (Observed)',
        date: DateTime(2026, 02, 27),
        type: HolidayType.national,
        description: {
          'en': 'Peace Memorial Day (Observed)',
          'ko': '평화기념일 대체휴일'
        },
      ),
      Holiday(
        name: 'Children\'s Day (Observed)',
        date: DateTime(2026, 04, 03),
        type: HolidayType.national,
        description: {'en': 'Children\'s Day (Observed)', 'ko': '어린이날 대체휴일'},
      ),
      Holiday(
        name: 'Tomb Sweeping Day',
        date: DateTime(2026, 04, 05),
        type: HolidayType.national,
        description: {'en': 'Tomb Sweeping Day', 'ko': '청명절'},
      ),
      Holiday(
        name: 'Tomb Sweeping Day Holiday',
        date: DateTime(2026, 04, 06),
        type: HolidayType.national,
        description: {'en': 'Tomb Sweeping Day Holiday', 'ko': '청명절 연휴'},
      ),
      Holiday(
        name: 'Labor Day',
        date: DateTime(2026, 05, 01),
        type: HolidayType.national,
        description: {'en': 'Labor Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Dragon Boat Festival',
        date: DateTime(2026, 06, 19),
        type: HolidayType.national,
        description: {'en': 'Dragon Boat Festival', 'ko': '단오절'},
      ),
      Holiday(
        name: 'Mid-Autumn Festival',
        date: DateTime(2026, 09, 25),
        type: HolidayType.national,
        description: {'en': 'Mid-Autumn Festival', 'ko': '중추절'},
      ),
      Holiday(
        name: 'Teachers\' Day',
        date: DateTime(2026, 09, 28),
        type: HolidayType.national,
        description: {'en': 'Teachers\' Day', 'ko': '스승의 날'},
      ),
      Holiday(
        name: 'National Day (Observed)',
        date: DateTime(2026, 10, 09),
        type: HolidayType.national,
        description: {'en': 'National Day (Observed)', 'ko': '국경일 대체휴일'},
      ),
      Holiday(
        name: 'Day off for Taiwan\'s Retrocession Day',
        date: DateTime(2026, 10, 26),
        type: HolidayType.national,
        description: {
          'en': 'Day off for Taiwan\'s Retrocession Day',
          'ko': '대만 광복절 대체휴일'
        },
      ),
      Holiday(
        name: 'Constitution Day',
        date: DateTime(2026, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Constitution Day', 'ko': '헌법기념일'},
      ),
    ],
    'US': [
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2024, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Martin Luther King Jr. Day',
        date: DateTime(2024, 01, 15),
        type: HolidayType.national,
        description: {
          'en': 'Martin Luther King Jr. Day',
          'ko': '마틴 루터 킹 주니어 기념일'
        },
      ),
      Holiday(
        name: 'Presidents\' Day',
        date: DateTime(2024, 02, 19),
        type: HolidayType.national,
        description: {'en': 'Presidents\' Day', 'ko': '대통령의 날'},
      ),
      Holiday(
        name: 'Memorial Day',
        date: DateTime(2024, 05, 27),
        type: HolidayType.national,
        description: {'en': 'Memorial Day', 'ko': '현충일'},
      ),
      Holiday(
        name: 'Juneteenth',
        date: DateTime(2024, 06, 19),
        type: HolidayType.national,
        description: {'en': 'Juneteenth', 'ko': '준틴스'},
      ),
      Holiday(
        name: 'Independence Day',
        date: DateTime(2024, 07, 04),
        type: HolidayType.national,
        description: {'en': 'Independence Day', 'ko': '독립기념일'},
      ),
      Holiday(
        name: 'Labor Day',
        date: DateTime(2024, 09, 02),
        type: HolidayType.national,
        description: {'en': 'Labor Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Columbus Day',
        date: DateTime(2024, 10, 14),
        type: HolidayType.national,
        description: {'en': 'Columbus Day', 'ko': '콜럼버스의 날'},
      ),
      Holiday(
        name: 'Veterans Day',
        date: DateTime(2024, 11, 11),
        type: HolidayType.national,
        description: {'en': 'Veterans Day', 'ko': '재향군인의 날'},
      ),
      Holiday(
        name: 'Thanksgiving Day',
        date: DateTime(2024, 11, 28),
        type: HolidayType.national,
        description: {'en': 'Thanksgiving Day', 'ko': '추수감사절'},
      ),
      Holiday(
        name: 'Christmas Eve',
        date: DateTime(2024, 12, 24),
        type: HolidayType.observance,
        description: {'en': 'Christmas Eve', 'ko': '크리스마스 이브'},
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2024, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2025, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'National Day of Mourning for Jimmy Carter',
        date: DateTime(2025, 01, 09),
        type: HolidayType.national,
        description: {
          'en': 'National Day of Mourning for Jimmy Carter',
          'ko': '지미 카터 추모일'
        },
      ),
      Holiday(
        name: 'Martin Luther King Jr. Day / Inauguration Day',
        date: DateTime(2025, 01, 20),
        type: HolidayType.national,
        description: {
          'en': 'Martin Luther King Jr. Day / Inauguration Day (DC, MD*, VA*)',
          'ko': '마틴 루터 킹 주니어 기념일 / 대통령 취임식'
        },
      ),
      Holiday(
        name: 'Presidents\' Day',
        date: DateTime(2025, 02, 17),
        type: HolidayType.national,
        description: {'en': 'Presidents\' Day', 'ko': '대통령의 날'},
      ),
      Holiday(
        name: 'Memorial Day',
        date: DateTime(2025, 05, 26),
        type: HolidayType.national,
        description: {'en': 'Memorial Day', 'ko': '현충일'},
      ),
      Holiday(
        name: 'Juneteenth',
        date: DateTime(2025, 06, 19),
        type: HolidayType.national,
        description: {'en': 'Juneteenth', 'ko': '준틴스'},
      ),
      Holiday(
        name: 'Independence Day',
        date: DateTime(2025, 07, 04),
        type: HolidayType.national,
        description: {'en': 'Independence Day', 'ko': '독립기념일'},
      ),
      Holiday(
        name: 'Labor Day',
        date: DateTime(2025, 09, 01),
        type: HolidayType.national,
        description: {'en': 'Labor Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Columbus Day',
        date: DateTime(2025, 10, 13),
        type: HolidayType.national,
        description: {'en': 'Columbus Day', 'ko': '콜럼버스의 날'},
      ),
      Holiday(
        name: 'Veterans Day',
        date: DateTime(2025, 11, 11),
        type: HolidayType.national,
        description: {'en': 'Veterans Day', 'ko': '재향군인의 날'},
      ),
      Holiday(
        name: 'Thanksgiving Day',
        date: DateTime(2025, 11, 27),
        type: HolidayType.national,
        description: {'en': 'Thanksgiving Day', 'ko': '추수감사절'},
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2025, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
      Holiday(
        name: 'New Year\'s Day',
        date: DateTime(2026, 01, 01),
        type: HolidayType.national,
        description: {'en': 'New Year\'s Day', 'ko': '신정'},
      ),
      Holiday(
        name: 'Martin Luther King Jr. Day',
        date: DateTime(2026, 01, 19),
        type: HolidayType.national,
        description: {
          'en': 'Martin Luther King Jr. Day',
          'ko': '마틴 루터 킹 주니어 기념일'
        },
      ),
      Holiday(
        name: 'Presidents\' Day',
        date: DateTime(2026, 02, 16),
        type: HolidayType.national,
        description: {'en': 'Presidents\' Day', 'ko': '대통령의 날'},
      ),
      Holiday(
        name: 'Memorial Day',
        date: DateTime(2026, 05, 25),
        type: HolidayType.national,
        description: {'en': 'Memorial Day', 'ko': '현충일'},
      ),
      Holiday(
        name: 'Juneteenth',
        date: DateTime(2026, 06, 19),
        type: HolidayType.national,
        description: {'en': 'Juneteenth', 'ko': '준틴스'},
      ),
      Holiday(
        name: 'Independence Day (Observed)',
        date: DateTime(2026, 07, 03),
        type: HolidayType.national,
        description: {'en': 'Independence Day (Observed)', 'ko': '독립기념일 대체휴일'},
      ),
      Holiday(
        name: 'Labor Day',
        date: DateTime(2026, 09, 07),
        type: HolidayType.national,
        description: {'en': 'Labor Day', 'ko': '노동절'},
      ),
      Holiday(
        name: 'Columbus Day',
        date: DateTime(2026, 10, 12),
        type: HolidayType.national,
        description: {'en': 'Columbus Day', 'ko': '콜럼버스의 날'},
      ),
      Holiday(
        name: 'Veterans Day',
        date: DateTime(2026, 11, 11),
        type: HolidayType.national,
        description: {'en': 'Veterans Day', 'ko': '재향군인의 날'},
      ),
      Holiday(
        name: 'Thanksgiving Day',
        date: DateTime(2026, 11, 26),
        type: HolidayType.national,
        description: {'en': 'Thanksgiving Day', 'ko': '추수감사절'},
      ),
      Holiday(
        name: 'Christmas Day',
        date: DateTime(2026, 12, 25),
        type: HolidayType.national,
        description: {'en': 'Christmas Day', 'ko': '크리스마스'},
      ),
    ],
    'VN': [
      Holiday(
        name: 'International New Year\'s Day',
        date: DateTime(2024, 01, 01),
        type: HolidayType.national,
        description: {'en': 'International New Year\'s Day', 'ko': '국제 신정'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2024, 02, 08),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Vietnamese New Year\'s Eve',
        date: DateTime(2024, 02, 09),
        type: HolidayType.national,
        description: {'en': 'Vietnamese New Year\'s Eve', 'ko': '베트남 설날 전야'},
      ),
      Holiday(
        name: 'Vietnamese New Year',
        date: DateTime(2024, 02, 10),
        type: HolidayType.national,
        description: {'en': 'Vietnamese New Year (Tet)', 'ko': '베트남 설날 (뗏)'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2024, 02, 11),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2024, 02, 12),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2024, 02, 13),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2024, 02, 14),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Hung Kings Festival',
        date: DateTime(2024, 04, 18),
        type: HolidayType.national,
        description: {'en': 'Hung Kings Festival', 'ko': '흥왕제 (베트남 건국 기념일)'},
      ),
      Holiday(
        name: 'Liberation Day/Reunification Day Holiday',
        date: DateTime(2024, 04, 29),
        type: HolidayType.national,
        description: {
          'en': 'Liberation Day/Reunification Day Holiday',
          'ko': '통일절 연휴'
        },
      ),
      Holiday(
        name: 'Liberation Day/Reunification Day',
        date: DateTime(2024, 04, 30),
        type: HolidayType.national,
        description: {
          'en': 'Liberation Day/Reunification Day',
          'ko': '통일절 (사이공 해방일)'
        },
      ),
      Holiday(
        name: 'International Labor Day',
        date: DateTime(2024, 05, 01),
        type: HolidayType.national,
        description: {'en': 'International Labor Day', 'ko': '국제 노동절'},
      ),
      Holiday(
        name: 'Independence Day Holiday',
        date: DateTime(2024, 08, 31),
        type: HolidayType.national,
        description: {'en': 'Independence Day Holiday', 'ko': '독립기념일 연휴'},
      ),
      Holiday(
        name: 'Independence Day Holiday',
        date: DateTime(2024, 09, 01),
        type: HolidayType.national,
        description: {'en': 'Independence Day Holiday', 'ko': '독립기념일 연휴'},
      ),
      Holiday(
        name: 'Independence Day',
        date: DateTime(2024, 09, 02),
        type: HolidayType.national,
        description: {'en': 'Independence Day', 'ko': '독립기념일 (호치민 독립 선언일)'},
      ),
      Holiday(
        name: 'Independence Day Holiday',
        date: DateTime(2024, 09, 03),
        type: HolidayType.national,
        description: {'en': 'Independence Day Holiday', 'ko': '독립기념일 연휴'},
      ),
      Holiday(
        name: 'International New Year\'s Day',
        date: DateTime(2025, 01, 01),
        type: HolidayType.national,
        description: {'en': 'International New Year\'s Day', 'ko': '국제 신정'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2025, 01, 25),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2025, 01, 26),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2025, 01, 27),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Vietnamese New Year\'s Eve',
        date: DateTime(2025, 01, 28),
        type: HolidayType.national,
        description: {'en': 'Vietnamese New Year\'s Eve', 'ko': '베트남 설날 전야'},
      ),
      Holiday(
        name: 'Vietnamese New Year',
        date: DateTime(2025, 01, 29),
        type: HolidayType.national,
        description: {'en': 'Vietnamese New Year (Tet)', 'ko': '베트남 설날 (뗏)'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2025, 01, 30),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2025, 01, 31),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2025, 02, 01),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2025, 02, 02),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Hung Kings Festival',
        date: DateTime(2025, 04, 07),
        type: HolidayType.national,
        description: {'en': 'Hung Kings Festival', 'ko': '흥왕제 (베트남 건국 기념일)'},
      ),
      Holiday(
        name: 'Working Day for May 2',
        date: DateTime(2025, 04, 26),
        type: HolidayType.observance,
        description: {'en': 'Working Day for May 2', 'ko': '5월 2일 대체 근무일'},
      ),
      Holiday(
        name: 'Liberation Day/Reunification Day',
        date: DateTime(2025, 04, 30),
        type: HolidayType.national,
        description: {
          'en': 'Liberation Day/Reunification Day',
          'ko': '통일절 (사이공 해방일)'
        },
      ),
      Holiday(
        name: 'International Labor Day',
        date: DateTime(2025, 05, 01),
        type: HolidayType.national,
        description: {'en': 'International Labor Day', 'ko': '국제 노동절'},
      ),
      Holiday(
        name: 'International Labor Day Holiday',
        date: DateTime(2025, 05, 02),
        type: HolidayType.national,
        description: {
          'en': 'International Labor Day Holiday',
          'ko': '국제 노동절 연휴'
        },
      ),
      Holiday(
        name: 'Independence Day Holiday',
        date: DateTime(2025, 09, 01),
        type: HolidayType.national,
        description: {'en': 'Independence Day Holiday', 'ko': '독립기념일 연휴'},
      ),
      Holiday(
        name: 'Independence Day',
        date: DateTime(2025, 09, 02),
        type: HolidayType.national,
        description: {'en': 'Independence Day', 'ko': '독립기념일 (호치민 독립 선언일)'},
      ),
      Holiday(
        name: 'International New Year\'s Day',
        date: DateTime(2026, 01, 01),
        type: HolidayType.national,
        description: {'en': 'International New Year\'s Day', 'ko': '국제 신정'},
      ),
      Holiday(
        name: 'Vietnamese New Year\'s Eve',
        date: DateTime(2026, 02, 16),
        type: HolidayType.national,
        description: {'en': 'Vietnamese New Year\'s Eve', 'ko': '베트남 설날 전야'},
      ),
      Holiday(
        name: 'Vietnamese New Year',
        date: DateTime(2026, 02, 17),
        type: HolidayType.national,
        description: {'en': 'Vietnamese New Year (Tet)', 'ko': '베트남 설날 (뗏)'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2026, 02, 18),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2026, 02, 19),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2026, 02, 20),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Tet Holiday',
        date: DateTime(2026, 02, 21),
        type: HolidayType.national,
        description: {'en': 'Tet Holiday', 'ko': '뗏 연휴'},
      ),
      Holiday(
        name: 'Hung Kings Festival',
        date: DateTime(2026, 04, 26),
        type: HolidayType.national,
        description: {'en': 'Hung Kings Festival', 'ko': '흥왕제 (베트남 건국 기념일)'},
      ),
      Holiday(
        name: 'Liberation Day/Reunification Day',
        date: DateTime(2026, 04, 30),
        type: HolidayType.national,
        description: {
          'en': 'Liberation Day/Reunification Day',
          'ko': '통일절 (사이공 해방일)'
        },
      ),
      Holiday(
        name: 'International Labor Day',
        date: DateTime(2026, 05, 01),
        type: HolidayType.national,
        description: {'en': 'International Labor Day', 'ko': '국제 노동절'},
      ),
      Holiday(
        name: 'Independence Day',
        date: DateTime(2026, 09, 02),
        type: HolidayType.national,
        description: {'en': 'Independence Day', 'ko': '독립기념일 (호치민 독립 선언일)'},
      ),
    ],
  };

  /// Get holidays for a specific country
  ///
  /// [countryCode] - Country code ('KR', 'US', 'JP', 'CN', 'VN', 'MY', 'TH', 'CA', 'BR', 'TW')
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
