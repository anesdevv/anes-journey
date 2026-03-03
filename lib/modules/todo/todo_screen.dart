import 'package:flutter/material.dart';
import 'dart:async';
import '../../models.dart';
import '../../services/firestore_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Todo>>? _todoSubscription;
  List<Todo> _todayTodos = [];

  @override
  void initState() {
    super.initState();
    _todoSubscription = _firestoreService.getTodos().listen(_processTodos);
  }

  @override
  void dispose() {
    _todoSubscription?.cancel();
    super.dispose();
  }

  void _processTodos(List<Todo> allTodos) {
    final now = DateTime.now();
    bool listModified = false;

    // Rollover logic: Any uncompleted task from a previous day gets updated to today
    for (var todo in allTodos) {
      bool isToday =
          todo.dateCreated.year == now.year &&
          todo.dateCreated.month == now.month &&
          todo.dateCreated.day == now.day;

      if (!isToday && !todo.isCompleted) {
        // Roll it over by updating its creation date to today in Firestore
        final rolledOver = Todo(
          id: todo.id,
          title: todo.title,
          dateCreated: now,
          isCompleted: false,
        );
        _firestoreService.saveTodo(rolledOver);
        listModified = true;
      }
    }

    if (!listModified) {
      setState(() {
        _todayTodos = allTodos.where((todo) {
          return todo.dateCreated.year == now.year &&
              todo.dateCreated.month == now.month &&
              todo.dateCreated.day == now.day;
        }).toList();
      });
    }
  }

  void _addTodo(String title) {
    if (title.isEmpty) return;

    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      dateCreated: DateTime.now(),
    );

    _firestoreService.saveTodo(newTodo);
  }

  void _toggleTodo(Todo todo) {
    todo.isCompleted = !todo.isCompleted;
    _firestoreService.saveTodo(todo);
  }

  void _showAddTodoDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        backgroundColor: const Color(0xFF111111),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Task Title'),
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
              _addTodo(titleController.text);
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
      appBar: AppBar(title: const Text('Daily To-Do')),
      body: _todayTodos.isEmpty
          ? const Center(
              child: Text(
                'No tasks for today. Chill or add one!',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _todayTodos.length,
              itemBuilder: (context, index) {
                final todo = _todayTodos[index];
                return CheckboxListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: todo.isCompleted ? Colors.grey : Colors.white,
                    ),
                  ),
                  value: todo.isCompleted,
                  activeColor: const Color(0xFFE53935),
                  checkColor: Colors.white,
                  onChanged: (bool? value) {
                    _toggleTodo(todo);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        backgroundColor: const Color(0xFFE53935),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
