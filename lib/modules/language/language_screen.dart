import 'package:flutter/material.dart';
import 'dart:async';
import '../../models.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<StudySession>>? _sessionSubscription;
  StreamSubscription<List<LanguageTopic>>? _topicSubscription;
  List<StudySession> _sessions = [];
  List<LanguageTopic> _topics = [];

  @override
  void initState() {
    super.initState();
    _sessionSubscription = _firestoreService.getStudySessions().listen((
      sessions,
    ) {
      if (mounted) {
        setState(() {
          _sessions = sessions;
        });
      }
    });
    _topicSubscription = _firestoreService.getLanguageTopics().listen((topics) {
      if (mounted) {
        setState(() {
          _topics = topics;
        });
      }
    });
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    _topicSubscription?.cancel();
    super.dispose();
  }

  void _addSession(int duration, String source) {
    if (duration <= 0 || source.isEmpty) return;

    final newSession = StudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      durationMinutes: duration,
      source: source,
    );

    _firestoreService.saveStudySession(newSession);
  }

  void _addTopic(String title) {
    if (title.isEmpty) return;

    final newTopic = LanguageTopic(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );

    _firestoreService.saveLanguageTopic(newTopic);
  }

  void _updateTopicStatus(LanguageTopic topic, String newStatus) {
    topic.status = newStatus;
    _firestoreService.saveLanguageTopic(topic);
  }

  void _deleteSession(String sessionId) {
    _firestoreService.deleteStudySession(sessionId);
  }

  void _editSession(String sessionId, int duration, String source) {
    if (duration <= 0 || source.isEmpty) return;

    final existing = _sessions.firstWhere((s) => s.id == sessionId);
    final updated = StudySession(
      id: existing.id,
      date: existing.date,
      durationMinutes: duration,
      source: source,
    );
    _firestoreService.saveStudySession(updated);
  }

  void _deleteTopic(String topicId) {
    _firestoreService.deleteLanguageTopic(topicId);
  }

  void _editTopic(String topicId, String title) {
    if (title.isEmpty) return;

    final existing = _topics.firstWhere((t) => t.id == topicId);
    final updated = LanguageTopic(
      id: existing.id,
      title: title,
      status: existing.status,
    );
    _firestoreService.saveLanguageTopic(updated);
  }

  void _showAddSessionDialog() {
    final durationController = TextEditingController();
    String selectedSource = 'Duolingo';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBuilder) {
          return AlertDialog(
            title: const Text('Log Session'),
            backgroundColor: const Color(0xFF111111),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedSource,
                  dropdownColor: const Color(0xFF111111),
                  decoration: const InputDecoration(labelText: 'Source'),
                  items: ['Duolingo', 'Book', 'YouTube', 'Custom'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setStateBuilder(() {
                      selectedSource = newValue!;
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
                  final duration = int.tryParse(durationController.text) ?? 0;
                  _addSession(duration, selectedSource);
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

  void _showEditSessionDialog(StudySession session) {
    final durationController = TextEditingController(
      text: session.durationMinutes.toString(),
    );
    String selectedSource = session.source;

    // Ensure the source is one of the valid options, otherwise default to Custom
    final validSources = ['Duolingo', 'Book', 'YouTube', 'Custom'];
    if (!validSources.contains(selectedSource)) {
      selectedSource = 'Custom';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBuilder) {
          return AlertDialog(
            title: const Text('Edit Session'),
            backgroundColor: const Color(0xFF111111),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedSource,
                  dropdownColor: const Color(0xFF111111),
                  decoration: const InputDecoration(labelText: 'Source'),
                  items: validSources.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setStateBuilder(() {
                        selectedSource = newValue;
                      });
                    }
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
                  final duration = int.tryParse(durationController.text) ?? 0;
                  _editSession(session.id, duration, selectedSource);
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

  void _showAddTopicDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Topic'),
        backgroundColor: const Color(0xFF111111),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Topic Title'),
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
              _addTopic(titleController.text);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditTopicDialog(LanguageTopic topic) {
    final titleController = TextEditingController(text: topic.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Topic'),
        backgroundColor: const Color(0xFF111111),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Topic Title'),
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
              _editTopic(topic.id, titleController.text);
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicItem(LanguageTopic topic) {
    return Card(
      color: const Color(0xFF111111),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        title: Text(topic.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: topic.status,
              dropdownColor: const Color(0xFF111111),
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE53935)),
              items: ['Not started', 'In progress', 'Mastered'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: value == 'Mastered'
                          ? Colors.green
                          : (value == 'In progress'
                                ? Colors.orange
                                : Colors.grey),
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) _updateTopicStatus(topic, newValue);
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              color: const Color(0xFF111111),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditTopicDialog(topic);
                } else if (value == 'delete') {
                  _deleteTopic(topic.id);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalMinutes = _sessions.fold(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
    int topicsMastered = _topics.where((t) => t.status == 'Mastered').length;

    return Scaffold(
      appBar: AppBar(title: const Text('German Ausbildung')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$totalMinutes',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    const Text(
                      'Total Mins',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$topicsMastered',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    const Text(
                      'Mastered',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF333333)),

          ListTile(
            title: const Text(
              'Study Sessions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFE53935)),
              onPressed: _showAddSessionDialog,
            ),
          ),
          if (_sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'No sessions logged yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._sessions
                .take(3)
                .map(
                  (s) => ListTile(
                    title: Text('${s.durationMinutes} min - ${s.source}'),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(s.date)),
                    leading: const Icon(Icons.school, color: Colors.grey),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      color: const Color(0xFF111111),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditSessionDialog(s);
                        } else if (value == 'delete') {
                          _deleteSession(s.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

          const Divider(color: Color(0xFF333333)),

          ListTile(
            title: const Text(
              'Custom Topics',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFFE53935)),
              onPressed: _showAddTopicDialog,
            ),
          ),
          if (_topics.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'No topics added yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ..._topics.map(_buildTopicItem),
        ],
      ),
    );
  }
}
