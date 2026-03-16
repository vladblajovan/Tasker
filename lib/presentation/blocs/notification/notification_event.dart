import 'package:equatable/equatable.dart';
import 'package:test_app/domain/entities/task.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleNotificationEvent extends NotificationEvent {
  const ScheduleNotificationEvent(this.task);

  final Task task;

  @override
  List<Object?> get props => [task];
}

class CancelNotificationEvent extends NotificationEvent {
  const CancelNotificationEvent(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

class HandleNotificationTap extends NotificationEvent {
  const HandleNotificationTap(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}
