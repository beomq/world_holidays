import 'holiday_type.dart';

/// Represents a holiday with its details
class Holiday {
  /// The name of the holiday
  final String name;

  /// The date of the holiday
  final DateTime date;

  /// The type of holiday
  final HolidayType type;

  /// Optional description of the holiday (multilingual)
  final Map<String, String>? description;

  const Holiday({
    required this.name,
    required this.date,
    required this.type,
    this.description,
  });

  /// Create Holiday from JSON data
  factory Holiday.fromJson(Map<String, dynamic> json) {
    Map<String, String>? description;
    if (json['description'] != null) {
      if (json['description'] is Map<String, dynamic>) {
        description = Map<String, String>.from(json['description']);
      } else if (json['description'] is String) {
        // Backward compatibility for old format
        description = {'en': json['description'] as String};
      }
    }

    return Holiday(
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      type: HolidayType.fromString(json['type'] as String),
      description: description,
    );
  }

  /// Convert Holiday to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'type': type.value,
      'description': description,
    };
  }

  /// Get the year of this holiday
  int get year => date.year;

  /// Get the month of this holiday
  int get month => date.month;

  /// Get the day of this holiday
  int get day => date.day;

  /// Check if this holiday falls on the given date
  bool isOnDate(DateTime date) {
    return this.date.year == date.year &&
        this.date.month == date.month &&
        this.date.day == date.day;
  }

  /// Check if this holiday is today
  bool get isToday {
    final now = DateTime.now();
    return isOnDate(now);
  }

  /// Get formatted date string (YYYY-MM-DD)
  String get dateString => date.toIso8601String().split('T')[0];

  /// Get description in specified language
  String? getDescription(String language) {
    if (description == null) return null;
    return description![language] ??
        description!['en'] ??
        description!.values.first;
  }

  /// Get description in English
  String? get descriptionEn => getDescription('en');

  /// Get description in Korean
  String? get descriptionKo => getDescription('ko');

  @override
  String toString() {
    return 'Holiday(name: $name, date: $dateString, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Holiday &&
        other.name == name &&
        other.date == date &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(name, date, type);
}
