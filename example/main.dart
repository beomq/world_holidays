import 'package:flutter/material.dart';
import 'package:world_holidays/world_holidays.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Holidays Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HolidayScreen(),
    );
  }
}

class HolidayScreen extends StatefulWidget {
  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  final WorldHolidays _worldHolidays = WorldHolidays();

  List<Holiday> _holidays = [];
  String _selectedCountry = 'KR';
  int? _selectedYear;
  bool _isLoading = false;
  String? _errorMessage;
  Holiday? _nextHoliday;

  final Map<String, String> _countryNames = {
    'KR': '🇰🇷 South Korea',
    'US': '🇺🇸 United States',
    'JP': '🇯🇵 Japan',
  };

  @override
  void initState() {
    super.initState();
    _loadHolidays();
    _loadNextHoliday();
  }

  Future<void> _loadHolidays() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final holidays = await _worldHolidays.getHolidays(
        _selectedCountry,
        year: _selectedYear,
      );

      setState(() {
        _holidays = holidays;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load holidays: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNextHoliday() async {
    final nextHoliday = _worldHolidays.getNextHoliday(_selectedCountry);
    setState(() {
      _nextHoliday = nextHoliday;
    });
  }

  Future<void> _updateHolidays() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _worldHolidays.updateHolidays(countryCode: _selectedCountry);
      await _loadHolidays();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Holidays updated successfully!')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update holidays: $e';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Update failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 World Holidays'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _updateHolidays,
            tooltip: 'Update holidays',
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Country selector
                Row(
                  children: [
                    const Text('Country: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedCountry,
                        isExpanded: true,
                        items: _worldHolidays
                            .getSupportedCountries()
                            .map((country) {
                          return DropdownMenuItem(
                            value: country,
                            child: Text(_countryNames[country] ?? country),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCountry = value;
                            });
                            _loadHolidays();
                            _loadNextHoliday();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Year selector
                Row(
                  children: [
                    const Text('Year: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: DropdownButton<int?>(
                        value: _selectedYear,
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All years'),
                          ),
                          ..._worldHolidays.getSupportedYears().map((year) {
                            return DropdownMenuItem<int?>(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedYear = value;
                          });
                          _loadHolidays();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Next Holiday Card
          if (_nextHoliday != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.blue),
                  title: const Text('Next Holiday',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${_nextHoliday!.name}\n${_nextHoliday!.dateString}',
                  ),
                  trailing: Text(
                    _getDaysUntil(_nextHoliday!.date),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Holiday List
          Expanded(
            child: _buildHolidayList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading holidays...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHolidays,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_holidays.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No holidays found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _holidays.length,
      itemBuilder: (context, index) {
        final holiday = _holidays[index];
        final isToday = holiday.isToday;

        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          color: isToday ? Colors.green.shade50 : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTypeColor(holiday.type),
              child: Text(
                holiday.date.day.toString(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                    child: Text(holiday.name,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                if (isToday)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('TODAY',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${holiday.dateString} (${_getWeekday(holiday.date)})'),
                if (holiday.description != null)
                  Text(holiday.description!,
                      style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            trailing: Chip(
              label: Text(
                holiday.type.name.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: _getTypeColor(holiday.type).withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(HolidayType type) {
    switch (type) {
      case HolidayType.national:
        return Colors.red;
      case HolidayType.religious:
        return Colors.purple;
      case HolidayType.observance:
        return Colors.blue;
      case HolidayType.regional:
        return Colors.orange;
    }
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    final difference =
        date.difference(DateTime(now.year, now.month, now.day)).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference > 0) return 'in ${difference}d';
    return 'Past';
  }
}
