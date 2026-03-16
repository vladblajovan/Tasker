import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasker/domain/usecases/notification/cancel_notification.dart';
import 'package:tasker/domain/usecases/notification/schedule_notification.dart';
import 'package:tasker/presentation/blocs/notification/notification_event.dart';
import 'package:tasker/presentation/blocs/notification/notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required ScheduleNotification scheduleNotification,
    required CancelNotification cancelNotification,
  }) : _scheduleNotification = scheduleNotification,
       _cancelNotification = cancelNotification,
       super(const NotificationInitial()) {
    on<ScheduleNotificationEvent>(_onScheduleNotification);
    on<CancelNotificationEvent>(_onCancelNotification);
    on<HandleNotificationTap>(_onHandleNotificationTap);
  }

  final ScheduleNotification _scheduleNotification;
  final CancelNotification _cancelNotification;

  Future<void> _onScheduleNotification(
    ScheduleNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _scheduleNotification(event.task);
      emit(const NotificationReady());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onCancelNotification(
    CancelNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _cancelNotification(event.taskId);
      emit(const NotificationReady());
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onHandleNotificationTap(
    HandleNotificationTap event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationNavigate(event.taskId));
  }
}
