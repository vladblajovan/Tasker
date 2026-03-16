import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/category_repository.dart';
import 'package:tasker/domain/repositories/task_repository.dart';
import 'package:tasker/domain/usecases/category/delete_category.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class FakeTask extends Fake implements Task {}

void main() {
  late DeleteCategory useCase;
  late MockCategoryRepository mockCategoryRepository;
  late MockTaskRepository mockTaskRepository;

  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    mockTaskRepository = MockTaskRepository();
    useCase = DeleteCategory(mockCategoryRepository, mockTaskRepository);
  });

  group('DeleteCategory', () {
    test(
      'should delete category and clear categoryId on affected tasks',
      () async {
        final task1 = Task(
          id: '1',
          title: 'Task 1',
          categoryId: 'cat-1',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          priority: Priority.medium,
        );
        final task2 = Task(
          id: '2',
          title: 'Task 2',
          categoryId: 'cat-1',
          createdAt: DateTime(2026, 1, 2),
          updatedAt: DateTime(2026, 1, 2),
          priority: Priority.low,
        );

        when(
          () => mockTaskRepository.getTasksByCategoryId('cat-1'),
        ).thenAnswer((_) async => [task1, task2]);
        when(
          () => mockTaskRepository.updateTask(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockCategoryRepository.deleteCategory('cat-1'),
        ).thenAnswer((_) async {});

        await useCase.call('cat-1');

        verify(
          () => mockTaskRepository.getTasksByCategoryId('cat-1'),
        ).called(1);

        final captured = verify(
          () => mockTaskRepository.updateTask(captureAny()),
        ).captured;
        expect(captured.length, 2);
        expect((captured[0] as Task).categoryId, isNull);
        expect((captured[1] as Task).categoryId, isNull);

        verify(() => mockCategoryRepository.deleteCategory('cat-1')).called(1);
      },
    );

    test('should delete category with no affected tasks', () async {
      when(
        () => mockTaskRepository.getTasksByCategoryId('cat-1'),
      ).thenAnswer((_) async => []);
      when(
        () => mockCategoryRepository.deleteCategory('cat-1'),
      ).thenAnswer((_) async {});

      await useCase.call('cat-1');

      verify(() => mockTaskRepository.getTasksByCategoryId('cat-1')).called(1);
      verifyNever(() => mockTaskRepository.updateTask(any()));
      verify(() => mockCategoryRepository.deleteCategory('cat-1')).called(1);
    });
  });
}
