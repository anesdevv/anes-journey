import 'package:flutter/material.dart';
import 'dart:async';
import '../../models.dart';
import '../../services/firestore_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Goal>>? _goalSubscription;
  List<Goal> _yearlyGoals = [];
  List<Goal> _monthlyGoals = [];
  List<Goal> _weeklyGoals = [];

  @override
  void initState() {
    super.initState();
    _goalSubscription = _firestoreService.getGoals().listen((goals) {
      if (mounted) {
        setState(() {
          _yearlyGoals = goals.where((g) => g.type == 'yearly').toList();
          _monthlyGoals = goals.where((g) => g.type == 'monthly').toList();
          _weeklyGoals = goals.where((g) => g.type == 'weekly').toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _goalSubscription?.cancel();
    super.dispose();
  }

  void _addGoal(String title, String type) {
    if (title.isEmpty) return;

    final newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: type.toLowerCase(),
    );

    _firestoreService.saveGoal(newGoal);
  }

  void _updateGoalProgress(Goal goal, double progress) {
    goal.progress = progress;
    _firestoreService.saveGoal(goal);
  }

  void _showEditGoalDialog(Goal goal) {
    final titleController = TextEditingController(text: goal.title);
    String selectedType =
        goal.type.substring(0, 1).toUpperCase() + goal.type.substring(1);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBuilder) {
          return AlertDialog(
            title: const Text('Edit Goal'),
            backgroundColor: const Color(0xFF111111),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Goal Title'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  dropdownColor: const Color(0xFF111111),
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Weekly', 'Monthly', 'Yearly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setStateBuilder(() {
                      selectedType = newValue!;
                    });
                  },
                ),
              ],
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
                  if (titleController.text.isNotEmpty) {
                    goal.title = titleController.text;
                    goal.type = selectedType.toLowerCase();
                    _firestoreService.saveGoal(goal);
                  }
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    String selectedType = 'Weekly';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBuilder) {
          return AlertDialog(
            title: const Text('Add Goal'),
            backgroundColor: const Color(0xFF111111),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Goal Title'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  dropdownColor: const Color(0xFF111111),
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Weekly', 'Monthly', 'Yearly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setStateBuilder(() {
                      selectedType = newValue!;
                    });
                  },
                ),
              ],
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
                  _addGoal(titleController.text, selectedType);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGoalList(String title, List<Goal> goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE53935),
            ),
          ),
        ),
        if (goals.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('No goals yet.', style: TextStyle(color: Colors.grey)),
          )
        else
          ...goals.map(
            (goal) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          goal.title,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.grey),
                        color: const Color(0xFF111111),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditGoalDialog(goal);
                          } else if (value == 'delete') {
                            _firestoreService.deleteGoal(goal.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text(
                              'Edit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Color(0xFFE53935)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: goal.progress,
                          min: 0,
                          max: 100,
                          activeColor: const Color(0xFFE53935),
                          inactiveColor: const Color(0xFF333333),
                          onChanged: (value) {
                            setState(() {
                              goal.progress = value;
                            });
                          },
                          onChangeEnd: (value) {
                            _updateGoalProgress(goal, value);
                          },
                        ),
                      ),
                      Text('${goal.progress.toInt()}%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const Divider(color: Color(0xFF333333)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          _buildGoalList('Yearly Goals', _yearlyGoals),
          _buildGoalList('Monthly Goals', _monthlyGoals),
          _buildGoalList('Weekly Goals', _weeklyGoals),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        backgroundColor: const Color(0xFFE53935),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
