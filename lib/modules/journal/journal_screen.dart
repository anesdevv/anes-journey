import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../models.dart';
import '../../services/firestore_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<JournalEntry>>? _entrySubscription;
  List<JournalEntry> _entries = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _entrySubscription = _firestoreService.getJournalEntries().listen((
      entries,
    ) {
      if (mounted) {
        entries.sort((a, b) => b.date.compareTo(a.date));
        setState(() {
          _entries = entries;
        });
      }
    });
  }

  @override
  void dispose() {
    _entrySubscription?.cancel();
    super.dispose();
  }

  void _addEntry(String text, String mood) {
    if (text.isEmpty) return;

    final newEntry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      text: text,
      mood: mood,
    );

    _firestoreService.saveJournalEntry(newEntry);
  }

  void _showAddEntryDialog() {
    final textController = TextEditingController();
    String selectedMood = '😐'; // Default Neutral

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBuilder) {
          return AlertDialog(
            title: const Text('New Journal Entry'),
            backgroundColor: const Color(0xFF111111),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'What\'s on your mind?',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('How are you feeling?'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['😊', '😐', '😔'].map((mood) {
                    final isSelected = mood == selectedMood;
                    return GestureDetector(
                      onTap: () {
                        setStateBuilder(() {
                          selectedMood = mood;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE53935).withValues(alpha: 0.2)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE53935)
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(mood, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
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
                  _addEntry(textController.text, selectedMood);
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

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _entries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      return entry.text.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Journal')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search journal...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF111111),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredEntries.isEmpty
                ? const Center(
                    child: Text(
                      'No entries found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return Card(
                        color: const Color(0xFF111111),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'EEEE, MMM d, yyyy',
                                    ).format(entry.date),
                                    style: const TextStyle(
                                      color: Color(0xFFE53935),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    entry.mood,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                entry.text,
                                style: const TextStyle(height: 1.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('h:mm a').format(entry.date),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        backgroundColor: const Color(0xFFE53935),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}
