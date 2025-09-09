/// Types of holidays supported by the World Holidays package
enum HolidayType {
  /// National holidays (공휴일)
  national('NATIONAL'),

  /// Religious holidays (종교적 휴일)
  religious('RELIGIOUS'),

  /// Observance days (기념일)
  observance('OBSERVANCE'),

  /// Regional holidays (지역 휴일)
  regional('REGIONAL');

  const HolidayType(this.value);

  /// The string value used in API responses
  final String value;

  /// Create HolidayType from string value
  static HolidayType fromString(String value) {
    return HolidayType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => HolidayType.national,
    );
  }

  @override
  String toString() => value;
}
