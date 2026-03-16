import 'package:tasker/data/datasources/notification_local_datasource.dart';
import 'package:tasker/data/models/task_model.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._datasource);

  final NotificationLocalDatasource _datasource;

  @override
  Future<void> scheduleNotification(Task task) async {
    final model = TaskModel.fromEntity(task);
    await _datasource.scheduleNotification(model);
  }

  @override
  Future<void> cancelNotification(String taskId) async {
    await _datasource.cancelNotification(taskId);
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _datasource.cancelAllNotifications();
  }
}
