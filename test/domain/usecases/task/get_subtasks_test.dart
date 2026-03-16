import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/repositories/task_repository.dart';
import 'package:test_app/domain/usecases/task/get_subtasks.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late GetSubtasks useCase;
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    useCase = GetSubtasks(mockTaskRepository);
  });

  group('GetSubtasks', () {
    test('should return subtasks for a given parent task id', () async {
      final subtasks = [
        Task(
          id: 'sub-1',
          title: 'Subtask 1',
          parentTaskId: 'parent-1',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        Task(
          id: 'sub-2',
          title: 'Subtask 2',
          parentTaskId: 'parent-1',
          createdAt: DateTime(2026, 1, 2),
          updatedAt: DateTime(2026, 1, 2),
        ),
      ];

      when(() => mockTaskRepository.getTasksByParentId('parent-1'))
          .thenAnswer((_) async => subtasks);

      final result = await useCase.call('parent-1');

      expect(result, subtasks);
      expect(result.length, 2);
      verify(() => mockTaskRepository.getTasksByParentId('parent-1'))
          .called(1);
      verifyNoMoreInteractions(mockTaskRepository);
    });

    test('should return empty list when no subtasks exist', () async {
      when(() => mockTaskRepository.getTasksByParentId('parent-1'))
          .thenAnswer((_) async => []);

      final result = await useCase.call('parent-1');

      expect(result, isEmpty);
      verify(() => mockTaskRepository.getTasksByParentId('parent-1'))
          .called(1);
    });
  });
}
