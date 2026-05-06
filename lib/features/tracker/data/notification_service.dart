// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  Future<void> scheduleInterviewReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Schedule for 1 day before
    final oneDayBefore = scheduledDate.subtract(const Duration(days: 1));
    if (oneDayBefore.isAfter(DateTime.now())) {
      await _schedule(id * 2, "Interview Tomorrow: $title", body, oneDayBefore);
    }

    // Schedule for the day of the interview
    if (scheduledDate.isAfter(DateTime.now())) {
      await _schedule(id * 2 + 1, "Interview Today: $title", body, scheduledDate);
    }
  }

  Future<void> _schedule(int id, String title, String body, DateTime date) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'interview_reminders',
          'Interview Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id * 2);
    await _notificationsPlugin.cancel(id * 2 + 1);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
