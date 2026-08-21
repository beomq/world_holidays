import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_holidays/world_holidays.dart';

http.Response jsonResponse(Map<String, dynamic> body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('country update is visible through every async query', () async {
    final client = MockClient((request) async {
      expect(request.url.path, endsWith('/api/holidays/kr.json'));
      return jsonResponse({
        'holidays': [
          {
            'name': 'Remote sentinel',
            'date': '2028-12-31',
            'type': 'NATIONAL',
            'description': {'en': 'Remote sentinel', 'ko': '원격 확인'},
          },
        ],
      }, 200);
    });
    final worldHolidays = WorldHolidays(httpClient: client);

    final outcome = await worldHolidays.updateCountryHolidays('kr');

    expect(outcome.countryCode, 'KR');
    expect(outcome.source, HolidayDataSource.remote);
    expect(outcome.succeeded, isTrue);
    expect(() => outcome.holidays.clear(), throwsUnsupportedError);
    expect(
      await worldHolidays.isHolidayAsync('KR', DateTime(2028, 12, 31)),
      isTrue,
    );
    expect(
      (await worldHolidays.getNextHolidayAsync(
        'KR',
        from: DateTime(2028, 12, 30),
      ))
          ?.name,
      'Remote sentinel',
    );
    expect(
      await worldHolidays.getHolidaysInRange(
        'KR',
        DateTime(2028, 12, 31, 12),
        DateTime(2028, 12, 31, 23),
      ),
      hasLength(1),
    );
    expect(worldHolidays.isHoliday('KR', DateTime(2028, 12, 31)), isFalse);
  });

  test('bulk update continues after an individual failure', () async {
    final requestedCountries = <String>[];
    final client = MockClient((request) async {
      final code = request.url.pathSegments.last.split('.').first.toUpperCase();
      requestedCountries.add(code);
      if (code == 'CN') {
        return http.Response('Unavailable', 503);
      }
      return jsonResponse({
        'holidays': [
          {
            'name': '$code sentinel',
            'date': '2028-12-31',
            'type': 'NATIONAL',
            'description': {'en': '$code sentinel', 'ko': '$code sentinel'},
          },
        ],
      }, 200);
    });
    final worldHolidays = WorldHolidays(httpClient: client);

    final outcome = await worldHolidays.updateAllHolidays();

    expect(requestedCountries, worldHolidays.getSupportedCountries());
    expect(outcome.results, hasLength(10));
    expect(outcome.successfulCountries, hasLength(9));
    expect(outcome.failedCountries, ['CN']);
    expect(outcome.allSucceeded, isFalse);
    expect(
      outcome.results
          .singleWhere((result) => result.countryCode == 'CN')
          .source,
      HolidayDataSource.bundled,
    );
    expect(() => outcome.holidays.clear(), throwsUnsupportedError);
  });

  test('invalid remote holiday type falls back without caching', () async {
    final client = MockClient(
      (_) async => jsonResponse({
        'holidays': [
          {
            'name': 'Invalid sentinel',
            'date': '2028-12-31',
            'type': 'INVALID',
            'description': {'en': 'Invalid sentinel', 'ko': '잘못된 확인'},
          },
        ],
      }, 200),
    );
    final worldHolidays = WorldHolidays(httpClient: client);

    final outcome = await worldHolidays.updateCountryHolidays('KR');
    final cached = await worldHolidays.getHolidays('KR');

    expect(outcome.source, HolidayDataSource.bundled);
    expect(outcome.error, contains('Unknown holiday type'));
    expect(
      cached.any((holiday) => holiday.name == 'Invalid sentinel'),
      isFalse,
    );
  });
}
