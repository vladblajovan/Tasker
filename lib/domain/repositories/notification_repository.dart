import 'package:tasker/domain/entities/task.dart';

abstract class NotificationRepository {
  Future<void> scheduleNotification(Task task);
  Future<void> cancelNotification(String taskId);
  Future<void> cancelAllNotifications();
}
