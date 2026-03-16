import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/notification_repository.dart';
import 'package:tasker/domain/usecases/notification/schedule_notification.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class FakeTask extends Fake implements Task {}

void main() {
  late ScheduleNotification useCase;
  late MockNotificationRepository mockNotificationRepository;

  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  setUp(() {
    mockNotificationRepository = MockNotificationRepository();
    useCase = ScheduleNotification(mockNotificationRepository);
  });

  final tTask = Task(
    id: '1',
    title: 'Test Task',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    dueDate: DateTime(2026, 3, 15, 9, 0),
    priority: Priority.medium,
  );

  group('ScheduleNotification', () {
    test('should schedule a notification for a task with a due date', () async {
      when(
        () => mockNotificationRepository.scheduleNotification(tTask),
      ).thenAnswer((_) async {});

      await useCase.call(tTask);

      verify(
        () => mockNotificationRepository.scheduleNotification(tTask),
      ).called(1);
      verifyNoMoreInteractions(mockNotificationRepository);
    });

    test(
      'should not schedule a notification for a task without a due date',
      () async {
        final taskWithoutDueDate = tTask.copyWith(dueDate: null);

        await useCase.call(taskWithoutDueDate);

        verifyZeroInteractions(mockNotificationRepository);
      },
    );

    test('should not schedule a notification for a completed task', () async {
      final completedTask = tTask.copyWith(
        isCompleted: true,
        completedAt: DateTime(2026, 3, 10),
      );

      await useCase.call(completedTask);

      verifyZeroInteractions(mockNotificationRepository);
    });
  });
}
