import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_holidays/world_holidays.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WorldHolidays', () {
    late WorldHolidays worldHolidays;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      worldHolidays = WorldHolidays();
    });

    test('should return supported countries', () {
      final countries = worldHolidays.getSupportedCountries();
      expect(
        countries,
        equals(['KR', 'US', 'JP', 'CN', 'VN', 'MY', 'TH', 'CA', 'BR', 'TW']),
      );
      expect(() => countries.clear(), throwsUnsupportedError);
    });

    test('should return supported years', () {
      final years = worldHolidays.getSupportedYears();
      expect(years, contains(2024));
      expect(years, contains(2025));
      expect(years, contains(2026));
      expect(years, contains(2027));
      expect(years, contains(2028));
      expect(() => years.clear(), throwsUnsupportedError);
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
        (h) =>
            h.name == "New Year's Day" && h.date.month == 1 && h.date.day == 1,
      );
      expect(newYear.type, equals(HolidayType.national));
    });

    test('should filter holidays by year', () async {
      final holidays2024 = await worldHolidays.getHolidays('KR', year: 2024);
      expect(holidays2024.every((h) => h.year == 2024), isTrue);
      expect(() => holidays2024.clear(), throwsUnsupportedError);
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

    test('should handle invalid country code', () async {
      final holidays = await worldHolidays.getHolidays('INVALID');
      expect(holidays, isEmpty);
    });

    test('should not expose mutable bundled data', () async {
      final holidays = await worldHolidays.getHolidays('KR');

      expect(() => holidays.clear(), throwsUnsupportedError);
      expect(await worldHolidays.getHolidays('KR'), isNotEmpty);
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
      expect(holiday.description, equals({'en': 'Test description'}));
    });

    test('should convert holiday to JSON', () {
      final holiday = Holiday(
        name: 'Test Holiday',
        date: DateTime(2024, 1, 1),
        type: HolidayType.national,
        description: const {'en': 'Test description'},
      );

      final json = holiday.toJson();
      expect(json['name'], equals('Test Holiday'));
      expect(json['date'], equals('2024-01-01'));
      expect(json['type'], equals('NATIONAL'));
      expect(json['description'], equals({'en': 'Test description'}));
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

    test('should not expose mutable description maps', () {
      final holiday = Holiday.fromJson({
        'name': 'Test Holiday',
        'date': '2024-01-01',
        'type': 'NATIONAL',
        'description': {'en': 'Original', 'ko': '원본'},
      });

      expect(
        () => holiday.description!['en'] = 'Changed',
        throwsUnsupportedError,
      );

      final json = holiday.toJson();
      (json['description'] as Map<String, String>)['en'] = 'Changed';
      expect(holiday.descriptionEn, 'Original');
    });
  });

  group('HolidayType', () {
    test('should create from string', () {
      expect(HolidayType.fromString('NATIONAL'), equals(HolidayType.national));
      expect(
        HolidayType.fromString('RELIGIOUS'),
        equals(HolidayType.religious),
      );
      expect(
        HolidayType.fromString('OBSERVANCE'),
        equals(HolidayType.observance),
      );
      expect(HolidayType.fromString('REGIONAL'), equals(HolidayType.regional));
    });

    test('should reject invalid string', () {
      expect(() => HolidayType.fromString('INVALID'), throwsFormatException);
    });
  });
}
