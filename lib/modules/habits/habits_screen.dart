import 'package:flutter/material.dart';
import 'dart:async';
import '../../models.dart';
import '../../services/firestore_service.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Habit>>? _habitSubscription;
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _habitSubscription = _firestoreService.getHabits().listen((habits) {
      if (mounted) {
        setState(() {
          _habits = habits;
        });
      }
    });
  }

  @override
  void dispose() {
    _habitSubscription?.cancel();
    super.dispose();
  }

  void _addHabit(String title) {
    if (title.isEmpty) return;

    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      frequency: 'daily',
    );

    _firestoreService.saveHabit(newHabit);
  }

  void _incrementStreak(Habit habit) {
    habit.streak += 1;
    _firestoreService.saveHabit(habit);
  }

  void _resetStreak(Habit habit) {
    habit.streak = 0;
    _firestoreService.saveHabit(habit);
  }

  void _showAddHabitDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Habit'),
        backgroundColor: const Color(0xFF111111),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Habit Title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
            ),
            onPressed: () {
              _addHabit(titleController.text);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _habits.isEmpty
          ? const Center(
              child: Text(
                'No habits tracking yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return Card(
                  color: const Color(0xFF111111),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    title: Text(
                      habit.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Current Streak: ${habit.streak} days',
                      style: const TextStyle(color: Color(0xFFE53935)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => _resetStreak(habit),
                          tooltip: 'Missed',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Color(0xFFE53935),
                          ),
                          onPressed: () => _incrementStreak(habit),
                          tooltip: 'Done',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        backgroundColor: const Color(0xFFE53935),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
