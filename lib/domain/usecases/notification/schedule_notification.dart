import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/repositories/notification_repository.dart';

class ScheduleNotification {
  ScheduleNotification(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  Future<void> call(Task task) async {
    if (task.dueDate == null || task.isCompleted) {
      return;
    }

    await _notificationRepository.scheduleNotification(task);
  }
}
