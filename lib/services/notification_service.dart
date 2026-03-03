import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const defaultIcon = '@mipmap/ic_launcher';

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(defaultIcon);

    // Note: iOS/macOS requires additional setup via DarwinInitializationSettings
    // Using default for web/other platforms where applicable, but FLN is mostly mobile
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    // Request permissions for Android 13+
    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> schedulePrayerReminder(String prayerName, DateTime time) async {
    // Basic implementation for a scheduled notification
    // Real implementation would use zonedSchedule
    await _showNotification(
      id: prayerName.hashCode,
      title: 'Time for $prayerName',
      body: 'It is time to pray $prayerName.',
    );
  }

  Future<void> scheduleTodoReminder(String title, DateTime time) async {
    await _showNotification(
      id: title.hashCode,
      title: 'To-Do Reminder',
      body: title,
    );
  }

  Future<void> scheduleHabitReminder(String habit, DateTime time) async {
    await _showNotification(
      id: habit.hashCode,
      title: 'Habit Reminder',
      body: "Don't forget your habit: $habit",
    );
  }

  Future<void> scheduleCalendarEvent(String title, DateTime time) async {
    await _showNotification(
      id: title.hashCode,
      title: 'Upcoming Event',
      body: title,
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'anes_journey_channel',
          'Anes Journey Notifications',
          channelDescription: 'Main channel for app notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformDetails,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
}
