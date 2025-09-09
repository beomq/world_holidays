/// Information about a supported country
class CountryInfo {
  /// Country code (e.g., 'KR', 'US', 'JP')
  final String code;

  /// Full country name
  final String name;

  /// Total number of holidays across all supported years
  final int totalHolidays;

  /// URL to the country's holiday data
  final String dataUrl;

  const CountryInfo({
    required this.code,
    required this.name,
    required this.totalHolidays,
    required this.dataUrl,
  });

  /// Create CountryInfo from JSON data
  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      code: json['code'] as String,
      name: json['name'] as String,
      totalHolidays: json['totalHolidays'] as int,
      dataUrl: json['dataUrl'] as String,
    );
  }

  /// Convert CountryInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'totalHolidays': totalHolidays,
      'dataUrl': dataUrl,
    };
  }

  @override
  String toString() {
    return 'CountryInfo(code: $code, name: $name, holidays: $totalHolidays)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountryInfo && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}
