import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/task_repository.dart';
import 'package:tasker/domain/usecases/task/search_tasks.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late SearchTasks useCase;
  late MockTaskRepository mockTaskRepository;

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    useCase = SearchTasks(mockTaskRepository);
  });

  group('SearchTasks', () {
    test(
      'should delegate to repository searchTasks with trimmed query',
      () async {
        when(() => mockTaskRepository.searchTasks('buy')).thenAnswer(
          (_) async => [
            Task(
              id: '1',
              title: 'Buy Groceries',
              description: 'Milk, eggs, bread',
              createdAt: DateTime(2026, 1, 1),
              updatedAt: DateTime(2026, 1, 1),
              priority: Priority.high,
            ),
          ],
        );

        final result = await useCase.call('buy');

        expect(result.length, 1);
        expect(result.first.id, '1');
        verify(() => mockTaskRepository.searchTasks('buy')).called(1);
        verifyNoMoreInteractions(mockTaskRepository);
      },
    );

    test('should trim whitespace from query before delegating', () async {
      when(() => mockTaskRepository.searchTasks('clean')).thenAnswer(
        (_) async => [
          Task(
            id: '2',
            title: 'Clean House',
            description: 'Vacuum and mop',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            priority: Priority.medium,
          ),
        ],
      );

      final result = await useCase.call('  clean  ');

      expect(result.length, 1);
      expect(result.first.id, '2');
      verify(() => mockTaskRepository.searchTasks('clean')).called(1);
    });

    test(
      'should return empty list and not call repository for empty query',
      () async {
        final result = await useCase.call('');

        expect(result, isEmpty);
        verifyZeroInteractions(mockTaskRepository);
      },
    );

    test(
      'should return empty list and not call repository for whitespace-only query',
      () async {
        final result = await useCase.call('   ');

        expect(result, isEmpty);
        verifyZeroInteractions(mockTaskRepository);
      },
    );

    test('should return empty list when repository finds no matches', () async {
      when(
        () => mockTaskRepository.searchTasks('xyz'),
      ).thenAnswer((_) async => []);

      final result = await useCase.call('xyz');

      expect(result, isEmpty);
      verify(() => mockTaskRepository.searchTasks('xyz')).called(1);
    });

    test('should return all matching tasks from repository', () async {
      final tasks = [
        Task(
          id: '1',
          title: 'Buy Groceries',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        Task(
          id: '3',
          title: 'Read Book',
          createdAt: DateTime(2026, 1, 3),
          updatedAt: DateTime(2026, 1, 3),
        ),
      ];
      when(
        () => mockTaskRepository.searchTasks('read'),
      ).thenAnswer((_) async => tasks);

      final result = await useCase.call('read');

      expect(result.length, 2);
    });
  });
}
