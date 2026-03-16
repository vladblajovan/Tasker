import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/core/error/failures.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/task_repository.dart';
import 'package:tasker/domain/usecases/task/create_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late CreateTask useCase;
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    useCase = CreateTask(mockTaskRepository);
  });

  final tTask = Task(
    id: '1',
    title: 'Test Task',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    priority: Priority.medium,
  );

  group('CreateTask', () {
    test('should create a task via the repository', () async {
      when(() => mockTaskRepository.createTask(tTask)).thenAnswer((_) async {});

      await useCase.call(tTask);

      verify(() => mockTaskRepository.createTask(tTask)).called(1);
      verifyNoMoreInteractions(mockTaskRepository);
    });

    test('should throw ValidationFailure when title is empty', () async {
      final invalidTask = tTask.copyWith(title: '');

      expect(
        () => useCase.call(invalidTask),
        throwsA(isA<ValidationFailure>()),
      );

      verifyZeroInteractions(mockTaskRepository);
    });

    test(
      'should throw ValidationFailure when title is only whitespace',
      () async {
        final invalidTask = tTask.copyWith(title: '   ');

        expect(
          () => useCase.call(invalidTask),
          throwsA(isA<ValidationFailure>()),
        );

        verifyZeroInteractions(mockTaskRepository);
      },
    );

    test('should allow creating a subtask (one level deep)', () async {
      final subtask = tTask.copyWith(parentTaskId: 'parent-1');

      when(
        () => mockTaskRepository.getTaskById('parent-1'),
      ).thenAnswer((_) async => tTask);
      when(
        () => mockTaskRepository.createTask(subtask),
      ).thenAnswer((_) async {});

      await useCase.call(subtask);

      verify(() => mockTaskRepository.getTaskById('parent-1')).called(1);
      verify(() => mockTaskRepository.createTask(subtask)).called(1);
    });

    test(
      'should throw ValidationFailure when creating a subtask of a subtask',
      () async {
        final parentSubtask = tTask.copyWith(
          id: 'parent-sub',
          parentTaskId: 'grandparent',
        );
        final nestedSubtask = tTask.copyWith(parentTaskId: 'parent-sub');

        when(
          () => mockTaskRepository.getTaskById('parent-sub'),
        ).thenAnswer((_) async => parentSubtask);

        expect(
          () => useCase.call(nestedSubtask),
          throwsA(isA<ValidationFailure>()),
        );
      },
    );

    test(
      'should throw NotFoundFailure when parent task does not exist',
      () async {
        final subtask = tTask.copyWith(parentTaskId: 'nonexistent');

        when(
          () => mockTaskRepository.getTaskById('nonexistent'),
        ).thenAnswer((_) async => null);

        expect(() => useCase.call(subtask), throwsA(isA<NotFoundFailure>()));
      },
    );
  });
}
