import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/tag_repository.dart';
import 'package:tasker/domain/repositories/task_repository.dart';
import 'package:tasker/domain/usecases/tag/delete_tag.dart';

class MockTagRepository extends Mock implements TagRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class FakeTask extends Fake implements Task {}

void main() {
  late DeleteTag useCase;
  late MockTagRepository mockTagRepository;
  late MockTaskRepository mockTaskRepository;

  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  setUp(() {
    mockTagRepository = MockTagRepository();
    mockTaskRepository = MockTaskRepository();
    useCase = DeleteTag(mockTagRepository, mockTaskRepository);
  });

  group('DeleteTag', () {
    test('should delete tag and remove tagId from affected tasks', () async {
      final task1 = Task(
        id: '1',
        title: 'Task 1',
        tags: const ['tag-1', 'tag-2'],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        priority: Priority.medium,
      );
      final task2 = Task(
        id: '2',
        title: 'Task 2',
        tags: const ['tag-1'],
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
        priority: Priority.low,
      );

      when(
        () => mockTaskRepository.getTasksByTagId('tag-1'),
      ).thenAnswer((_) async => [task1, task2]);
      when(() => mockTaskRepository.updateTask(any())).thenAnswer((_) async {});
      when(() => mockTagRepository.deleteTag('tag-1')).thenAnswer((_) async {});

      await useCase.call('tag-1');

      verify(() => mockTaskRepository.getTasksByTagId('tag-1')).called(1);

      final captured = verify(
        () => mockTaskRepository.updateTask(captureAny()),
      ).captured;
      expect(captured.length, 2);

      final updatedTask1 = captured[0] as Task;
      expect(updatedTask1.tags, ['tag-2']);

      final updatedTask2 = captured[1] as Task;
      expect(updatedTask2.tags, isEmpty);

      verify(() => mockTagRepository.deleteTag('tag-1')).called(1);
    });

    test('should delete tag with no affected tasks', () async {
      when(
        () => mockTaskRepository.getTasksByTagId('tag-1'),
      ).thenAnswer((_) async => []);
      when(() => mockTagRepository.deleteTag('tag-1')).thenAnswer((_) async {});

      await useCase.call('tag-1');

      verify(() => mockTaskRepository.getTasksByTagId('tag-1')).called(1);
      verifyNever(() => mockTaskRepository.updateTask(any()));
      verify(() => mockTagRepository.deleteTag('tag-1')).called(1);
    });
  });
}
