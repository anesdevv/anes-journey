import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';
import 'widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  StreamSubscription<List<PrayerLog>>? _prayerSub;
  StreamSubscription<List<Todo>>? _todoSub;
  StreamSubscription<List<Habit>>? _habitSub;
  StreamSubscription<List<Goal>>? _goalSub;
  StreamSubscription<List<StudySession>>? _sessionSub;

  Map<String, String> _prayerStatuses = {
    'Fajr': 'Not yet',
    'Dhuhr': 'Not yet',
    'Asr': 'Not yet',
    'Maghrib': 'Not yet',
    'Isha': 'Not yet',
  };

  int _todosTotal = 0;
  int _todosCompleted = 0;

  List<Habit> _activeHabits = [];
  List<Goal> _activeGoals = [];

  int _todayStudyDuration = 0;
  final int _studyTarget = 30; // default target

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _prayerSub?.cancel();
    _todoSub?.cancel();
    _habitSub?.cancel();
    _goalSub?.cancel();
    _sessionSub?.cancel();
    super.dispose();
  }

  void _loadDashboardData() {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    // 1. Load Prayers
    _prayerSub = _firestoreService.getPrayerLogs().listen((logs) {
      if (mounted) {
        final todayLog = logs.where((log) => log.date == todayStr).firstOrNull;
        setState(() {
          if (todayLog != null) {
            _prayerStatuses = todayLog.statuses;
          }
        });
      }
    });

    // 2. Load Todos
    _todoSub = _firestoreService.getTodos().listen((todos) {
      if (mounted) {
        final todayTodos = todos
            .where(
              (t) =>
                  t.dateCreated.year == now.year &&
                  t.dateCreated.month == now.month &&
                  t.dateCreated.day == now.day,
            )
            .toList();
        setState(() {
          _todosTotal = todayTodos.length;
          _todosCompleted = todayTodos.where((t) => t.isCompleted).length;
        });
      }
    });

    // 3. Load Habits
    _habitSub = _firestoreService.getHabits().listen((habits) {
      if (mounted) {
        setState(() {
          _activeHabits = habits.where((h) => h.streak > 0).take(5).toList();
          if (_activeHabits.isEmpty) {
            _activeHabits = habits
                .take(3)
                .toList(); // Fallback if no active streak
          }
        });
      }
    });

    // 4. Load Goals
    _goalSub = _firestoreService.getGoals().listen((goals) {
      if (mounted) {
        setState(() {
          _activeGoals = goals.where((g) => g.progress < 100).take(3).toList();
        });
      }
    });

    // 5. Load Language Sessions
    _sessionSub = _firestoreService.getStudySessions().listen((sessions) {
      if (mounted) {
        final todaySessions = sessions
            .where(
              (s) =>
                  s.date.year == now.year &&
                  s.date.month == now.month &&
                  s.date.day == now.day,
            )
            .toList();

        int studyTotal = 0;
        for (var s in todaySessions) {
          studyTotal += s.durationMinutes;
        }

        setState(() {
          _todayStudyDuration = studyTotal;
        });
      }
    });
  }

  String _mapPrayerStatusToDisplay(String status) {
    if (status == 'On time') return 'on_time';
    if (status == 'Late') return 'late';
    if (status == 'Missed') return 'missed';
    return 'pending'; // 'Not yet' or anything else
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Overview',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Prayers Status
          DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Daily Prayers', icon: Icons.mosque),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PrayerIndicator(
                      name: 'Fajr',
                      status: _mapPrayerStatusToDisplay(
                        _prayerStatuses['Fajr'] ?? 'Not yet',
                      ),
                    ),
                    PrayerIndicator(
                      name: 'Dhuhr',
                      status: _mapPrayerStatusToDisplay(
                        _prayerStatuses['Dhuhr'] ?? 'Not yet',
                      ),
                    ),
                    PrayerIndicator(
                      name: 'Asr',
                      status: _mapPrayerStatusToDisplay(
                        _prayerStatuses['Asr'] ?? 'Not yet',
                      ),
                    ),
                    PrayerIndicator(
                      name: 'Maghrib',
                      status: _mapPrayerStatusToDisplay(
                        _prayerStatuses['Maghrib'] ?? 'Not yet',
                      ),
                    ),
                    PrayerIndicator(
                      name: 'Isha',
                      status: _mapPrayerStatusToDisplay(
                        _prayerStatuses['Isha'] ?? 'Not yet',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. To-Do Progress
          DashboardCard(
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _todosTotal > 0
                            ? _todosCompleted / _todosTotal
                            : 0.0,
                        backgroundColor: const Color(0xFF333333),
                        color: const Color(0xFFE53935),
                        strokeWidth: 6,
                      ),
                      Center(
                        child: Text(
                          '$_todosCompleted/$_todosTotal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Tasks',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _todosTotal == 0
                            ? 'No tasks assigned for today.'
                            : 'You have completed $_todosCompleted out of $_todosTotal tasks today.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Habits Streak
          DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Active Habits', icon: Icons.loop),
                const SizedBox(height: 16),
                SizedBox(
                  height: 70,
                  child: _activeHabits.isEmpty
                      ? const Center(
                          child: Text(
                            'No habits found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _activeHabits.length,
                          itemBuilder: (context, index) {
                            final habit = _activeHabits[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: HabitStreakBadge(
                                habitName: habit.title,
                                streak: habit.streak,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // 4. Goals Progress
          DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Current Goals', icon: Icons.flag),
                const SizedBox(height: 16),
                if (_activeGoals.isEmpty)
                  const Text(
                    'No active goals right now.',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  ..._activeGoals.map((Goal g) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ProgressBar(
                        label: '${g.type.toUpperCase()}: ${g.title}',
                        progress: g.progress / 100.0,
                        trailingText: '${g.progress.toInt()}%',
                      ),
                    );
                  }),
              ],
            ),
          ),

          // 5. German Learning
          DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'German Learning',
                  icon: Icons.language,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Study Time",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_todayStudyDuration mins',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withValues(
                          alpha: 0.1,
                        ), // Keep this since dashboard is not using standard cards
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Target: ${_studyTarget}m',
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Spacer for FAB overlap
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
