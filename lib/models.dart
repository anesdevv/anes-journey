class Event {
  final String id;
  final String title;
  final DateTime date;
  final String notes;

  Event({
    required this.id,
    required this.title,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'notes': notes,
  };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'],
    title: json['title'],
    date: DateTime.parse(json['date']),
    notes: json['notes'] ?? '',
  );
}

class Todo {
  final String id;
  final String title;
  final DateTime dateCreated;
  bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    required this.dateCreated,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'dateCreated': dateCreated.toIso8601String(),
    'isCompleted': isCompleted,
  };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    id: json['id'],
    title: json['title'],
    dateCreated: DateTime.parse(json['dateCreated']),
    isCompleted: json['isCompleted'] ?? false,
  );
}

class Goal {
  final String id;
  final String title;
  final String type; // 'yearly', 'monthly', 'weekly'
  double progress;

  Goal({
    required this.id,
    required this.title,
    required this.type,
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type,
    'progress': progress,
  };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    id: json['id'],
    title: json['title'],
    type: json['type'],
    progress: json['progress'] ?? 0.0,
  );
}

class Habit {
  final String id;
  final String title;
  final String frequency; // 'daily'
  int streak;

  Habit({
    required this.id,
    required this.title,
    required this.frequency,
    this.streak = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'frequency': frequency,
    'streak': streak,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'],
    title: json['title'],
    frequency: json['frequency'],
    streak: json['streak'] ?? 0,
  );
}

class PrayerLog {
  final String date; // YYYY-MM-DD format
  final Map<String, String>
  statuses; // e.g. {'Fajr': 'On time', 'Dhuhr': 'Late'}
  final Map<String, String> timings; // Cache of the pulled times

  PrayerLog({
    required this.date,
    required this.statuses,
    required this.timings,
  });

  Map<String, dynamic> toJson() => {
    'date': date,
    'statuses': statuses,
    'timings': timings,
  };

  factory PrayerLog.fromJson(Map<String, dynamic> json) => PrayerLog(
    date: json['date'],
    statuses: Map<String, String>.from(json['statuses']),
    timings: Map<String, String>.from(json['timings']),
  );
}

class StudySession {
  final String id;
  final DateTime date;
  final int durationMinutes;
  final String source;

  StudySession({
    required this.id,
    required this.date,
    required this.durationMinutes,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'durationMinutes': durationMinutes,
    'source': source,
  };

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
    id: json['id'],
    date: DateTime.parse(json['date']),
    durationMinutes: json['durationMinutes'],
    source: json['source'],
  );
}

class LanguageTopic {
  final String id;
  final String title;
  String status; // 'Not started', 'In progress', 'Mastered'

  LanguageTopic({
    required this.id,
    required this.title,
    this.status = 'Not started',
  });

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'status': status};

  factory LanguageTopic.fromJson(Map<String, dynamic> json) => LanguageTopic(
    id: json['id'],
    title: json['title'],
    status: json['status'],
  );
}

class JournalEntry {
  final String id;
  final DateTime date;
  final String text;
  final String mood; // '😊', '😐', '😔'

  JournalEntry({
    required this.id,
    required this.date,
    required this.text,
    required this.mood,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'text': text,
    'mood': mood,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'],
    date: DateTime.parse(json['date']),
    text: json['text'],
    mood: json['mood'],
  );
}
