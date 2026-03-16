import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/usecases/notification/cancel_notification.dart';
import 'package:test_app/domain/usecases/notification/schedule_notification.dart';
import 'package:test_app/presentation/blocs/notification/notification_bloc.dart';
import 'package:test_app/presentation/blocs/notification/notification_event.dart';
import 'package:test_app/presentation/blocs/notification/notification_state.dart';

class MockScheduleNotification extends Mock implements ScheduleNotification {}

class MockCancelNotification extends Mock implements CancelNotification {}

class FakeTask extends Fake implements Task {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  late MockScheduleNotification mockScheduleNotification;
  late MockCancelNotification mockCancelNotification;

  final now = DateTime(2026, 3, 14, 10);

  final tTask = Task(
    id: 'task-1',
    title: 'Test Task',
    isCompleted: false,
    createdAt: now,
    updatedAt: now,
    dueDate: now.add(const Duration(hours: 1)),
  );

  NotificationBloc buildBloc() => NotificationBloc(
        scheduleNotification: mockScheduleNotification,
        cancelNotification: mockCancelNotification,
      );

  setUp(() {
    mockScheduleNotification = MockScheduleNotification();
    mockCancelNotification = MockCancelNotification();
  });

  group('NotificationBloc', () {
    test('initial state is NotificationInitial', () {
      expect(buildBloc().state, const NotificationInitial());
    });

    group('ScheduleNotificationEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits NotificationReady after scheduling',
        build: buildBloc,
        setUp: () {
          when(() => mockScheduleNotification(any())).thenAnswer((_) async {});
        },
        act: (bloc) => bloc.add(ScheduleNotificationEvent(tTask)),
        expect: () => [const NotificationReady()],
        verify: (_) {
          verify(() => mockScheduleNotification(tTask)).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits NotificationError when scheduleNotification throws',
        build: buildBloc,
        setUp: () {
          when(() => mockScheduleNotification(any()))
              .thenThrow(Exception('permission denied'));
        },
        act: (bloc) => bloc.add(ScheduleNotificationEvent(tTask)),
        expect: () => [isA<NotificationError>()],
      );
    });

    group('CancelNotificationEvent', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits NotificationReady after cancelling',
        build: buildBloc,
        setUp: () {
          when(() => mockCancelNotification('task-1'))
              .thenAnswer((_) async {});
        },
        act: (bloc) => bloc.add(const CancelNotificationEvent('task-1')),
        expect: () => [const NotificationReady()],
        verify: (_) {
          verify(() => mockCancelNotification('task-1')).called(1);
        },
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits NotificationError when cancelNotification throws',
        build: buildBloc,
        setUp: () {
          when(() => mockCancelNotification('task-1'))
              .thenThrow(Exception('error'));
        },
        act: (bloc) => bloc.add(const CancelNotificationEvent('task-1')),
        expect: () => [isA<NotificationError>()],
      );
    });

    group('HandleNotificationTap', () {
      blocTest<NotificationBloc, NotificationState>(
        'emits NotificationNavigate with the tapped taskId',
        build: buildBloc,
        act: (bloc) => bloc.add(const HandleNotificationTap('task-42')),
        expect: () => [
          isA<NotificationNavigate>().having(
            (s) => s.taskId,
            'taskId',
            'task-42',
          ),
        ],
      );

      blocTest<NotificationBloc, NotificationState>(
        'emits NotificationNavigate regardless of current state',
        build: buildBloc,
        seed: () => const NotificationReady(),
        act: (bloc) => bloc.add(const HandleNotificationTap('task-99')),
        expect: () => [
          isA<NotificationNavigate>()
              .having((s) => s.taskId, 'taskId', 'task-99'),
        ],
      );
    });
  });
}
