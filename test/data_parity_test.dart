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
}
