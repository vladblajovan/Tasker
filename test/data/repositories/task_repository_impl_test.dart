import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_app/data/datasources/task_local_datasource.dart';
import 'package:test_app/data/models/task_model.dart';
import 'package:test_app/data/repositories/task_repository_impl.dart';
import 'package:test_app/domain/entities/priority.dart';
import 'package:test_app/domain/entities/task.dart';

class MockTaskLocalDatasource extends Mock implements TaskLocalDatasource {}

class FakeTaskModel extends Fake implements TaskModel {}

void main() {
  late TaskRepositoryImpl repository;
  late MockTaskLocalDatasource mockDatasource;

  setUpAll(() {
    registerFallbackValue(FakeTaskModel());
  });

  setUp(() {
    mockDatasource = MockTaskLocalDatasource();
    repository = TaskRepositoryImpl(mockDatasource);
  });

  final tTaskModel = TaskModel(
    id: '1',
    title: 'Test Task',
    isCompleted: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    priority: Priority.medium,
    tags: const [],
  );

  final tTask = Task(
    id: '1',
    title: 'Test Task',
    isCompleted: false,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    priority: Priority.medium,
    tags: const [],
  );

  group('getAllTasks', () {
    test('should return list of tasks from datasource', () async {
      when(() => mockDatasource.getAllTasks())
          .thenAnswer((_) async => [tTaskModel]);

      final result = await repository.getAllTasks();

      expect(result.length, 1);
      expect(result.first.id, tTask.id);
      expect(result.first.title, tTask.title);
      verify(() => mockDatasource.getAllTasks()).called(1);
    });
  });

  group('getTaskById', () {
    test('should return task when found', () async {
      when(() => mockDatasource.getTaskById('1'))
          .thenAnswer((_) async => tTaskModel);

      final result = await repository.getTaskById('1');

      expect(result, isNotNull);
      expect(result!.id, tTask.id);
      verify(() => mockDatasource.getTaskById('1')).called(1);
    });

    test('should return null when not found', () async {
      when(() => mockDatasource.getTaskById('1'))
          .thenAnswer((_) async => null);

      final result = await repository.getTaskById('1');

      expect(result, isNull);
    });
  });

  group('getTasksByParentId', () {
    test('should return tasks filtered by parentTaskId', () async {
      final parentTask = TaskModel(
        id: 'parent-1',
        title: 'Parent',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        priority: Priority.none,
        tags: const [],
      );
      final subtask = TaskModel(
        id: 'sub-1',
        title: 'Subtask',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        priority: Priority.none,
        tags: const [],
        parentTaskId: 'parent-1',
      );

      when(() => mockDatasource.getAllTasks())
          .thenAnswer((_) async => [parentTask, subtask]);

      final result = await repository.getTasksByParentId('parent-1');

      expect(result.length, 1);
      expect(result.first.id, 'sub-1');
    });
  });

  group('getTasksByCategoryId', () {
    test('should return tasks filtered by categoryId', () async {
      final taskWithCategory = TaskModel(
        id: '1',
        title: 'Task',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        priority: Priority.none,
        tags: const [],
        categoryId: 'cat-1',
      );
      final taskWithoutCategory = TaskModel(
        id: '2',
        title: 'Other Task',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        priority: Priority.none,
        tags: const [],
      );

      when(() => mockDatasource.getAllTasks())
          .thenAnswer((_) async => [taskWithCategory, taskWithoutCategory]);

      final result = await repository.getTasksByCategoryId('cat-1');

      expect(result.length, 1);
      expect(result.first.id, '1');
    });
  });

  group('getTasksByTagId', () {
    test('should return tasks that contain the given tag id', () async {
      final taskWithTag = TaskModel(
        id: '1',
        title: 'Task',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        priority: Priority.none,
        tags: const ['tag-1', 'tag-2'],
      );
      final taskWithoutTag = TaskModel(
        id: '2',
        title: 'Other Task',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        priority: Priority.none,
        tags: const ['tag-3'],
      );

      when(() => mockDatasource.getAllTasks())
          .thenAnswer((_) async => [taskWithTag, taskWithoutTag]);

      final result = await repository.getTasksByTagId('tag-1');

      expect(result.length, 1);
      expect(result.first.id, '1');
    });
  });

  group('createTask', () {
    test('should create task via datasource using fromEntity mapping',
        () async {
      when(() => mockDatasource.createTask(any()))
          .thenAnswer((_) async {});

      await repository.createTask(tTask);

      final captured = verify(
        () => mockDatasource.createTask(captureAny()),
      ).captured;
      final model = captured.first as TaskModel;
      expect(model.id, tTask.id);
      expect(model.title, tTask.title);
    });
  });

  group('updateTask', () {
    test('should update task via datasource using fromEntity mapping',
        () async {
      when(() => mockDatasource.updateTask(any()))
          .thenAnswer((_) async {});

      await repository.updateTask(tTask);

      final captured = verify(
        () => mockDatasource.updateTask(captureAny()),
      ).captured;
      final model = captured.first as TaskModel;
      expect(model.id, tTask.id);
      expect(model.title, tTask.title);
    });
  });

  group('deleteTask', () {
    test('should delete task via datasource', () async {
      when(() => mockDatasource.deleteTask('1'))
          .thenAnswer((_) async {});

      await repository.deleteTask('1');

      verify(() => mockDatasource.deleteTask('1')).called(1);
    });
  });

  group('searchTasks', () {
    test('should return tasks matching the query in title or description',
        () async {
      final task1 = TaskModel(
        id: '1',
        title: 'Buy groceries',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        priority: Priority.none,
        tags: const [],
      );
      final task2 = TaskModel(
        id: '2',
        title: 'Meeting',
        description: 'Discuss grocery budget',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        priority: Priority.none,
        tags: const [],
      );
      final task3 = TaskModel(
        id: '3',
        title: 'Walk the dog',
        isCompleted: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        priority: Priority.none,
        tags: const [],
      );

      when(() => mockDatasource.getAllTasks())
          .thenAnswer((_) async => [task1, task2, task3]);

      final result = await repository.searchTasks('grocer');

      expect(result.length, 2);
      expect(result.map((t) => t.id), containsAll(['1', '2']));
    });
  });
}
