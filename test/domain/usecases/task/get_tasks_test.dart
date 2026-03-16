import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/task_repository.dart';
import 'package:tasker/domain/usecases/task/get_tasks.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late GetTasks useCase;
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    useCase = GetTasks(mockTaskRepository);
  });

  final tTasks = [
    Task(
      id: '1',
      title: 'Task 1',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      priority: Priority.high,
    ),
    Task(
      id: '2',
      title: 'Task 2',
      createdAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
      priority: Priority.low,
    ),
  ];

  group('GetTasks', () {
    test('should get all top-level tasks from the repository', () async {
      when(
        () => mockTaskRepository.getAllTasks(),
      ).thenAnswer((_) async => tTasks);

      final result = await useCase.call();

      expect(result, tTasks);
      verify(() => mockTaskRepository.getAllTasks()).called(1);
      verifyNoMoreInteractions(mockTaskRepository);
    });

    test('should return empty list when no tasks exist', () async {
      when(() => mockTaskRepository.getAllTasks()).thenAnswer((_) async => []);

      final result = await useCase.call();

      expect(result, isEmpty);
      verify(() => mockTaskRepository.getAllTasks()).called(1);
    });
  });
}
