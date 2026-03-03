import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // === Todo ===
  Stream<List<Todo>> getTodos() {
    return _db
        .collection('todos')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList(),
        );
  }

  Future<void> saveTodo(Todo todo) async {
    await _db.collection('todos').doc(todo.id).set(todo.toJson());
  }

  Future<void> deleteTodo(String id) async {
    await _db.collection('todos').doc(id).delete();
  }

  // === Habit ===
  Stream<List<Habit>> getHabits() {
    return _db
        .collection('habits')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Habit.fromJson(doc.data())).toList(),
        );
  }

  Future<void> saveHabit(Habit habit) async {
    await _db.collection('habits').doc(habit.id).set(habit.toJson());
  }

  Future<void> deleteHabit(String id) async {
    await _db.collection('habits').doc(id).delete();
  }

  // === Goal ===
  Stream<List<Goal>> getGoals() {
    return _db
        .collection('goals')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Goal.fromJson(doc.data())).toList(),
        );
  }

  Future<void> saveGoal(Goal goal) async {
    await _db.collection('goals').doc(goal.id).set(goal.toJson());
  }

  Future<void> deleteGoal(String id) async {
    await _db.collection('goals').doc(id).delete();
  }

  // === Study Session ===
  Stream<List<StudySession>> getStudySessions() {
    return _db
        .collection('study_sessions')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StudySession.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> saveStudySession(StudySession session) async {
    await _db
        .collection('study_sessions')
        .doc(session.id)
        .set(session.toJson());
  }

  Future<void> deleteStudySession(String id) async {
    await _db.collection('study_sessions').doc(id).delete();
  }

  // === Language Topic ===
  Stream<List<LanguageTopic>> getLanguageTopics() {
    return _db
        .collection('language_topics')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => LanguageTopic.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> saveLanguageTopic(LanguageTopic topic) async {
    await _db.collection('language_topics').doc(topic.id).set(topic.toJson());
  }

  Future<void> deleteLanguageTopic(String id) async {
    await _db.collection('language_topics').doc(id).delete();
  }

  // === Journal Entry ===
  Stream<List<JournalEntry>> getJournalEntries() {
    return _db
        .collection('journal_entries')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => JournalEntry.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> saveJournalEntry(JournalEntry entry) async {
    await _db.collection('journal_entries').doc(entry.id).set(entry.toJson());
  }

  Future<void> deleteJournalEntry(String id) async {
    await _db.collection('journal_entries').doc(id).delete();
  }

  // === Prayer Logs ===
  Stream<List<PrayerLog>> getPrayerLogs() {
    return _db
        .collection('prayer_logs')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PrayerLog.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> savePrayerLog(PrayerLog log) async {
    await _db.collection('prayer_logs').doc(log.date).set(log.toJson());
  }

  // === Events ===
  Stream<List<Event>> getEvents() {
    return _db
        .collection('events')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Event.fromJson(doc.data())).toList(),
        );
  }

  Future<void> saveEvent(Event event) async {
    await _db.collection('events').doc(event.id).set(event.toJson());
  }

  Future<void> deleteEvent(String id) async {
    await _db.collection('events').doc(id).delete();
  }
}
