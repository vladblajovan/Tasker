import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/core/error/failures.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/task_repository.dart';
import 'package:tasker/domain/usecases/task/update_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late UpdateTask useCase;
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    useCase = UpdateTask(mockTaskRepository);
  });

  final tTask = Task(
    id: '1',
    title: 'Test Task',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    priority: Priority.medium,
  );

  group('UpdateTask', () {
    test('should update a task via the repository', () async {
      when(() => mockTaskRepository.updateTask(tTask)).thenAnswer((_) async {});

      await useCase.call(tTask);

      verify(() => mockTaskRepository.updateTask(tTask)).called(1);
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
  });
}
