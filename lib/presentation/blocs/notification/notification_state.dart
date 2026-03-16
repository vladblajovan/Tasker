import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationReady extends NotificationState {
  const NotificationReady();
}

class NotificationNavigate extends NotificationState {
  const NotificationNavigate(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
