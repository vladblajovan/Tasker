import 'package:test_app/domain/repositories/notification_repository.dart';

class CancelNotification {
  CancelNotification(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  Future<void> call(String taskId) async {
    await _notificationRepository.cancelNotification(taskId);
  }
}
