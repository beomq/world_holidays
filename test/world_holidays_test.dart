import 'package:flutter_test/flutter_test.dart';
import 'package:world_holidays/world_holidays.dart';

void main() {
  group('WorldHolidays', () {
    late WorldHolidays worldHolidays;

    setUp(() {
      worldHolidays = WorldHolidays();
    });

    test('should return supported countries', () {
      final countries = worldHolidays.getSupportedCountries();
      expect(countries, contains('KR'));
      expect(countries, contains('US'));
      expect(countries, contains('JP'));
      expect(countries, contains('DE'));
      expect(countries.length, equals(4));
    });

    test('should return supported years', () {
      final years = worldHolidays.getSupportedYears();
      expect(years, contains(2024));
      expect(years, contains(2025));
      expect(years, contains(2026));
      expect(years.length, equals(3));
    });

    test('should get Korean holidays', () async {
      final holidays = await worldHolidays.getHolidays('KR');
      expect(holidays, isNotEmpty);

      // Check if New Year's Day is included
      final newYear = holidays.firstWhere(
        (h) => h.name == '신정' && h.date.month == 1 && h.date.day == 1,
      );
      expect(newYear.type, equals(HolidayType.national));
    });

    test('should get US holidays', () async {
      final holidays = await worldHolidays.getHolidays('US');
      expect(holidays, isNotEmpty);

      // Check if Independence Day is included
      final independenceDay = holidays.firstWhere(
        (h) =>
            h.name == 'Independence Day' &&
            h.date.month == 7 &&
            h.date.day == 4,
      );
      expect(independenceDay.type, equals(HolidayType.national));
    });

    test('should get Japanese holidays', () async {
      final holidays = await worldHolidays.getHolidays('JP');
      expect(holidays, isNotEmpty);

      // Check if New Year's Day is included
      final newYear = holidays.firstWhere(
        (h) => h.name == '元日' && h.date.month == 1 && h.date.day == 1,
      );
      expect(newYear.type, equals(HolidayType.national));
    });

    test('should filter holidays by year', () async {
      final holidays2024 = await worldHolidays.getHolidays('KR', year: 2024);
      expect(holidays2024.every((h) => h.year == 2024), isTrue);
    });

    test('should check if date is holiday', () {
      // New Year's Day should be a holiday
      final isNewYear = worldHolidays.isHoliday('KR', DateTime(2024, 1, 1));
      expect(isNewYear, isTrue);

      // Random date should not be a holiday
      final isRandomDate = worldHolidays.isHoliday('KR', DateTime(2024, 6, 15));
      expect(isRandomDate, isFalse);
    });

    test('should get next holiday', () {
      final nextHoliday = worldHolidays.getNextHoliday(
        'KR',
        from: DateTime(2024, 1, 1),
      );

      expect(nextHoliday, isNotNull);
      expect(nextHoliday!.date.isAfter(DateTime(2024, 1, 1)), isTrue);
    });

    test('should get German holidays', () async {
      final holidays = await worldHolidays.getHolidays('DE');
      expect(holidays, isNotEmpty);

      // Check if New Year's Day is included
      final newYear = holidays.firstWhere(
        (h) => h.name == 'Neujahrstag' && h.date.month == 1 && h.date.day == 1,
      );
      expect(newYear.type, equals(HolidayType.national));
    });

    test('should handle invalid country code', () async {
      final holidays = await worldHolidays.getHolidays('INVALID');
      expect(holidays, isEmpty);
    });
  });

  group('Holiday', () {
    test('should create holiday from JSON', () {
      final json = {
        'name': 'Test Holiday',
        'date': '2024-01-01',
        'type': 'NATIONAL',
        'description': 'Test description',
      };

      final holiday = Holiday.fromJson(json);
      expect(holiday.name, equals('Test Holiday'));
      expect(holiday.date, equals(DateTime(2024, 1, 1)));
      expect(holiday.type, equals(HolidayType.national));
      expect(holiday.description, equals('Test description'));
    });

    test('should convert holiday to JSON', () {
      final holiday = Holiday(
        name: 'Test Holiday',
        date: DateTime(2024, 1, 1),
        type: HolidayType.national,
        description: 'Test description',
      );

      final json = holiday.toJson();
      expect(json['name'], equals('Test Holiday'));
      expect(json['date'], equals('2024-01-01'));
      expect(json['type'], equals('NATIONAL'));
      expect(json['description'], equals('Test description'));
    });

    test('should check if holiday is on specific date', () {
      final holiday = Holiday(
        name: 'Test Holiday',
        date: DateTime(2024, 1, 1),
        type: HolidayType.national,
      );

      expect(holiday.isOnDate(DateTime(2024, 1, 1)), isTrue);
      expect(holiday.isOnDate(DateTime(2024, 1, 2)), isFalse);
    });
  });

  group('HolidayType', () {
    test('should create from string', () {
      expect(HolidayType.fromString('NATIONAL'), equals(HolidayType.national));
      expect(
          HolidayType.fromString('RELIGIOUS'), equals(HolidayType.religious));
      expect(
          HolidayType.fromString('OBSERVANCE'), equals(HolidayType.observance));
      expect(HolidayType.fromString('REGIONAL'), equals(HolidayType.regional));
    });

    test('should default to national for invalid string', () {
      expect(HolidayType.fromString('INVALID'), equals(HolidayType.national));
    });
  });
}
