import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';
import 'prayer_api_service.dart';

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({super.key});

  @override
  State<PrayersScreen> createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen> {
  final PrayerApiService _apiService = PrayerApiService();
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<PrayerLog>>? _logSubscription;

  String _todayStr = '';
  Map<String, String> _timings = {};
  Map<String, String> _statuses = {
    'Fajr': 'Not yet',
    'Dhuhr': 'Not yet',
    'Asr': 'Not yet',
    'Maghrib': 'Not yet',
    'Isha': 'Not yet',
  };
  bool _isLoading = true;

  final List<String> _prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  @override
  void initState() {
    super.initState();
    _todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadPrayerData();

    _logSubscription = _firestoreService.getPrayerLogs().listen((logs) {
      if (mounted) {
        PrayerLog? todayLog = logs
            .where((log) => log.date == _todayStr)
            .firstOrNull;
        if (todayLog != null) {
          setState(() {
            _statuses = todayLog.statuses;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerData() async {
    final timings = await _apiService.fetchTodayTimings();
    if (mounted) {
      setState(() {
        _timings = timings;
        _isLoading = false;
      });
    }
  }

  void _updatePrayerStatus(String prayer, String status) {
    setState(() {
      _statuses[prayer] = status;
    });

    final updatedLog = PrayerLog(
      date: _todayStr,
      statuses: _statuses,
      timings: _timings,
    );
    _firestoreService.savePrayerLog(updatedLog);
  }

  Widget _buildStatusButton(
    String prayer,
    String statusOption,
    Color color,
    String currentStatus,
  ) {
    final isSelected = currentStatus == statusOption;
    return InkWell(
      onTap: () => _updatePrayerStatus(prayer, statusOption),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : const Color(0xFF333333),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          statusOption,
          style: TextStyle(
            color: isSelected ? color : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE53935)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _prayerOrder.length,
      itemBuilder: (context, index) {
        final prayer = _prayerOrder[index];
        final time = _timings[prayer] ?? '--:--';
        final status = _statuses[prayer] ?? 'Not yet';

        return Card(
          color: const Color(0xFF111111),
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prayer,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusButton(prayer, 'Not yet', Colors.grey, status),
                    _buildStatusButton(prayer, 'On time', Colors.green, status),
                    _buildStatusButton(prayer, 'Late', Colors.orange, status),
                    _buildStatusButton(prayer, 'Missed', Colors.red, status),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
