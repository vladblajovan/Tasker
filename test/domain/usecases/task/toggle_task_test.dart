import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_app/core/error/failures.dart';
import 'package:test_app/domain/entities/priority.dart';
import 'package:test_app/domain/entities/recurrence.dart';
import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/repositories/notification_repository.dart';
import 'package:test_app/domain/repositories/task_repository.dart';
import 'package:test_app/domain/usecases/task/toggle_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

class FakeTask extends Fake implements Task {}

void main() {
  late ToggleTask useCase;
  late MockTaskRepository mockTaskRepository;
  late MockNotificationRepository mockNotificationRepository;

  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    mockNotificationRepository = MockNotificationRepository();
    useCase = ToggleTask(mockTaskRepository, mockNotificationRepository);
  });

  final now = DateTime(2026, 3, 10, 9, 0);

  final tTask = Task(
    id: '1',
    title: 'Test Task',
    isCompleted: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    priority: Priority.medium,
    dueDate: DateTime(2026, 3, 10),
  );

  group('ToggleTask', () {
    test('should mark an incomplete task as completed', () async {
      when(() => mockTaskRepository.getTaskById('1'))
          .thenAnswer((_) async => tTask);
      when(() => mockTaskRepository.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.cancelNotification('1'))
          .thenAnswer((_) async {});

      final result = await useCase.call('1', now: now);

      expect(result.isCompleted, true);
      expect(result.completedAt, now);

      verify(() => mockTaskRepository.updateTask(any())).called(1);
      verify(() => mockNotificationRepository.cancelNotification('1'))
          .called(1);
    });

    test('should mark a completed task as incomplete', () async {
      final completedTask = tTask.copyWith(
        isCompleted: true,
        completedAt: DateTime(2026, 3, 9),
      );

      when(() => mockTaskRepository.getTaskById('1'))
          .thenAnswer((_) async => completedTask);
      when(() => mockTaskRepository.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.scheduleNotification(any()))
          .thenAnswer((_) async {});

      final result = await useCase.call('1', now: now);

      expect(result.isCompleted, false);
      expect(result.completedAt, isNull);

      verify(() => mockTaskRepository.updateTask(any())).called(1);
    });

    test('should reschedule notification when uncompleting task with due date',
        () async {
      final completedTask = tTask.copyWith(
        isCompleted: true,
        completedAt: DateTime(2026, 3, 9),
        dueDate: DateTime(2026, 3, 15),
      );

      when(() => mockTaskRepository.getTaskById('1'))
          .thenAnswer((_) async => completedTask);
      when(() => mockTaskRepository.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.scheduleNotification(any()))
          .thenAnswer((_) async {});

      await useCase.call('1', now: now);

      verify(() => mockNotificationRepository.scheduleNotification(any()))
          .called(1);
    });

    test('should handle recurring daily task completion', () async {
      final recurringTask = tTask.copyWith(
        recurrence: const Recurrence(
          type: RecurrenceType.daily,
          interval: 1,
        ),
        dueDate: DateTime(2026, 3, 10),
      );

      when(() => mockTaskRepository.getTaskById('1'))
          .thenAnswer((_) async => recurringTask);
      when(() => mockTaskRepository.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockTaskRepository.createTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.cancelNotification('1'))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.scheduleNotification(any()))
          .thenAnswer((_) async {});

      final result = await useCase.call('1', now: now);

      expect(result.isCompleted, true);
      expect(result.completedAt, now);

      final captured = verify(
        () => mockTaskRepository.createTask(captureAny()),
      ).captured;
      final newTask = captured.first as Task;

      expect(newTask.id, isNot('1'));
      expect(newTask.title, 'Test Task');
      expect(newTask.isCompleted, false);
      expect(newTask.completedAt, isNull);
      expect(newTask.dueDate, DateTime(2026, 3, 11));
      expect(newTask.recurrence, recurringTask.recurrence);
      expect(newTask.priority, Priority.medium);

      verify(() => mockNotificationRepository.cancelNotification('1'))
          .called(1);
      verify(() => mockNotificationRepository.scheduleNotification(any()))
          .called(1);
    });

    test('should handle recurring weekly task completion', () async {
      final recurringTask = tTask.copyWith(
        recurrence: const Recurrence(
          type: RecurrenceType.weekly,
          interval: 1,
        ),
        dueDate: DateTime(2026, 3, 10),
      );

      when(() => mockTaskRepository.getTaskById('1'))
          .thenAnswer((_) async => recurringTask);
      when(() => mockTaskRepository.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockTaskRepository.createTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.cancelNotification('1'))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.scheduleNotification(any()))
          .thenAnswer((_) async {});

      await useCase.call('1', now: now);

      final captured = verify(
        () => mockTaskRepository.createTask(captureAny()),
      ).captured;
      final newTask = captured.first as Task;

      expect(newTask.dueDate, DateTime(2026, 3, 17));
    });

    test('should handle recurring monthly task completion', () async {
      final recurringTask = tTask.copyWith(
        recurrence: const Recurrence(
          type: RecurrenceType.monthly,
          interval: 1,
        ),
        dueDate: DateTime(2026, 3, 10),
      );

      when(() => mockTaskRepository.getTaskById('1'))
          .thenAnswer((_) async => recurringTask);
      when(() => mockTaskRepository.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockTaskRepository.createTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.cancelNotification('1'))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.scheduleNotification(any()))
          .thenAnswer((_) async {});

      await useCase.call('1', now: now);

      final captured = verify(
        () => mockTaskRepository.createTask(captureAny()),
      ).captured;
      final newTask = captured.first as Task;

      expect(newTask.dueDate, DateTime(2026, 4, 10));
    });

    test('should handle recurring task with interval > 1', () async {
      final recurringTask = tTask.copyWith(
        recurrence: const Recurrence(
          type: RecurrenceType.daily,
          interval: 3,
        ),
        dueDate: DateTime(2026, 3, 10),
      );

      when(() => mockTaskRepository.getTaskById('1'))
          .thenAnswer((_) async => recurringTask);
      when(() => mockTaskRepository.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockTaskRepository.createTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.cancelNotification('1'))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.scheduleNotification(any()))
          .thenAnswer((_) async {});

      await useCase.call('1', now: now);

      final captured = verify(
        () => mockTaskRepository.createTask(captureAny()),
      ).captured;
      final newTask = captured.first as Task;

      expect(newTask.dueDate, DateTime(2026, 3, 13));
    });

    test('should not create next occurrence if recurrence end date is passed',
        () async {
      final recurringTask = tTask.copyWith(
        recurrence: Recurrence(
          type: RecurrenceType.daily,
          interval: 1,
          endDate: DateTime(2026, 3, 10),
        ),
        dueDate: DateTime(2026, 3, 10),
      );

      when(() => mockTaskRepository.getTaskById('1'))
          .thenAnswer((_) async => recurringTask);
      when(() => mockTaskRepository.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.cancelNotification('1'))
          .thenAnswer((_) async {});

      await useCase.call('1', now: now);

      verifyNever(() => mockTaskRepository.createTask(any()));
    });

    test('should handle custom recurrence with weekdays', () async {
      // March 10, 2026 is a Tuesday (weekday 2)
      // Custom recurrence: every 2 weeks on Tue (2) and Thu (4)
      // Next occurrence after March 10 (Tue) should be March 12 (Thu)
      final recurringTask = tTask.copyWith(
        recurrence: const Recurrence(
          type: RecurrenceType.custom,
          interval: 2,
          weekdays: [2, 4], // Tue, Thu
        ),
        dueDate: DateTime(2026, 3, 10), // Tuesday
      );

      when(() => mockTaskRepository.getTaskById('1'))
          .thenAnswer((_) async => recurringTask);
      when(() => mockTaskRepository.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockTaskRepository.createTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.cancelNotification('1'))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.scheduleNotification(any()))
          .thenAnswer((_) async {});

      await useCase.call('1', now: now);

      final captured = verify(
        () => mockTaskRepository.createTask(captureAny()),
      ).captured;
      final newTask = captured.first as Task;

      // Next day in the same week that matches weekdays is Thursday March 12
      expect(newTask.dueDate, DateTime(2026, 3, 12));
    });

    test('should throw NotFoundFailure when task does not exist', () async {
      when(() => mockTaskRepository.getTaskById('nonexistent'))
          .thenAnswer((_) async => null);

      expect(
        () => useCase.call('nonexistent', now: now),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test(
        'should not toggle recurring flow when uncompleting a recurring task',
        () async {
      final completedRecurringTask = tTask.copyWith(
        isCompleted: true,
        completedAt: DateTime(2026, 3, 9),
        recurrence: const Recurrence(
          type: RecurrenceType.daily,
          interval: 1,
        ),
      );

      when(() => mockTaskRepository.getTaskById('1'))
          .thenAnswer((_) async => completedRecurringTask);
      when(() => mockTaskRepository.updateTask(any()))
          .thenAnswer((_) async {});
      when(() => mockNotificationRepository.scheduleNotification(any()))
          .thenAnswer((_) async {});

      final result = await useCase.call('1', now: now);

      expect(result.isCompleted, false);
      verifyNever(() => mockTaskRepository.createTask(any()));
    });
  });
}
