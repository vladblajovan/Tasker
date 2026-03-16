import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/task_repository.dart';
import 'package:tasker/domain/usecases/task/delete_task.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late DeleteTask useCase;
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    useCase = DeleteTask(mockTaskRepository);
  });

  group('DeleteTask', () {
    test('should delete a task and its subtasks via the repository', () async {
      final subtask1 = Task(
        id: 'sub-1',
        title: 'Subtask 1',
        parentTaskId: '1',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final subtask2 = Task(
        id: 'sub-2',
        title: 'Subtask 2',
        parentTaskId: '1',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      when(
        () => mockTaskRepository.getTasksByParentId('1'),
      ).thenAnswer((_) async => [subtask1, subtask2]);
      when(() => mockTaskRepository.deleteTask(any())).thenAnswer((_) async {});

      await useCase.call('1');

      verify(() => mockTaskRepository.getTasksByParentId('1')).called(1);
      verify(() => mockTaskRepository.deleteTask('sub-1')).called(1);
      verify(() => mockTaskRepository.deleteTask('sub-2')).called(1);
      verify(() => mockTaskRepository.deleteTask('1')).called(1);
    });

    test('should delete a task with no subtasks', () async {
      when(
        () => mockTaskRepository.getTasksByParentId('1'),
      ).thenAnswer((_) async => []);
      when(() => mockTaskRepository.deleteTask('1')).thenAnswer((_) async {});

      await useCase.call('1');

      verify(() => mockTaskRepository.getTasksByParentId('1')).called(1);
      verify(() => mockTaskRepository.deleteTask('1')).called(1);
      verifyNoMoreInteractions(mockTaskRepository);
    });
  });
}
