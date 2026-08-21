import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_holidays/world_holidays.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('hosted metadata counts match every country payload', () {
    final index = jsonDecode(File('api/countries.json').readAsStringSync())
        as Map<String, dynamic>;
    final countries = index['countries'] as List<dynamic>;
    var aggregateCount = 0;

    for (final value in countries) {
      final country = value as Map<String, dynamic>;
      final code = country['code'] as String;
      final payload = jsonDecode(
        File('api/holidays/${code.toLowerCase()}.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final holidays = payload['holidays'] as List<dynamic>;

      expect(payload['totalHolidays'], holidays.length, reason: code);
      expect(country['totalHolidays'], holidays.length, reason: code);
      aggregateCount += holidays.length;
    }

    expect(index['totalHolidays'], aggregateCount);
  });

  test('bundled records exactly match hosted payloads', () async {
    final worldHolidays = WorldHolidays();

    for (final code in worldHolidays.getSupportedCountries()) {
      final payload = jsonDecode(
        File('api/holidays/${code.toLowerCase()}.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final hosted = (payload['holidays'] as List<dynamic>)
          .map(
            (value) => Holiday.fromJson(value as Map<String, dynamic>).toJson(),
          )
          .toList(growable: false);
      final bundled = (await worldHolidays.getHolidays(code))
          .map((holiday) => holiday.toJson())
          .toList(growable: false);

      expect(bundled, hosted, reason: code);
    }
  });

  test('South Korea includes official 2026 public holiday changes', () async {
    final worldHolidays = WorldHolidays();
    final holidays = await worldHolidays.getHolidays('KR', year: 2026);
    final namesByDate = {
      for (final holiday in holidays) holiday.dateString: holiday.name,
    };

    expect(namesByDate['2026-05-01'], 'Labor Day');
    expect(namesByDate['2026-06-03'], '지방선거');
    expect(namesByDate['2026-07-17'], 'Constitution Day');
    expect(worldHolidays.isHoliday('KR', DateTime(2026, 7, 17)), isTrue);
  });

  test('South Korea corrects 2024 and 2025 substitute holidays', () async {
    final worldHolidays = WorldHolidays();
    final holidays = await worldHolidays.getHolidays('KR');
    final namesByDate = {
      for (final holiday in holidays) holiday.dateString: holiday.name,
    };

    expect(namesByDate['2024-09-19'], isNull);
    expect(namesByDate['2025-01-27'], '임시공휴일');
    expect(namesByDate['2025-01-31'], isNull);
    expect(worldHolidays.isHoliday('KR', DateTime(2024, 9, 19)), isFalse);
    expect(worldHolidays.isHoliday('KR', DateTime(2025, 1, 27)), isTrue);
    expect(worldHolidays.isHoliday('KR', DateTime(2025, 1, 31)), isFalse);
  });
}
