import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln;
import 'package:timezone/timezone.dart' as tz;
import 'package:tasker/data/models/task_model.dart';

abstract class NotificationLocalDatasource {
  Future<void> initialize();
  Future<void> scheduleNotification(TaskModel task);
  Future<void> cancelNotification(String taskId);
  Future<void> cancelAllNotifications();
}

class NotificationLocalDatasourceImpl implements NotificationLocalDatasource {
  NotificationLocalDatasourceImpl(this._plugin);

  final fln.FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize() async {
    const androidSettings = fln.AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = fln.InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );
    await _plugin.initialize(initSettings);
  }

  @override
  Future<void> scheduleNotification(TaskModel task) async {
    if (task.dueDate == null) return;

    final notificationId = task.id.hashCode;

    const androidDetails = fln.AndroidNotificationDetails(
      'todo_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task due dates',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
    );
    const darwinDetails = fln.DarwinNotificationDetails();
    const details = fln.NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      notificationId,
      task.title,
      task.description ?? 'Task is due',
      tz.TZDateTime.from(task.dueDate!, tz.local),
      details,
      payload: task.id,
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          fln.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: fln.DateTimeComponents.dateAndTime,
    );
  }

  @override
  Future<void> cancelNotification(String taskId) async {
    final notificationId = taskId.hashCode;
    await _plugin.cancel(notificationId);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}
