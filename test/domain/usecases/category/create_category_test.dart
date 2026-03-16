import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/core/error/failures.dart';
import 'package:tasker/domain/entities/category.dart';
import 'package:tasker/domain/repositories/category_repository.dart';
import 'package:tasker/domain/usecases/category/create_category.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late CreateCategory useCase;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    useCase = CreateCategory(mockCategoryRepository);
  });

  final tCategory = Category(
    id: 'cat-1',
    name: 'Work',
    color: 0xFF42A5F5,
    createdAt: DateTime(2026, 1, 1),
    order: 0,
  );

  group('CreateCategory', () {
    test('should create a category via the repository', () async {
      when(
        () => mockCategoryRepository.createCategory(tCategory),
      ).thenAnswer((_) async {});

      await useCase.call(tCategory);

      verify(() => mockCategoryRepository.createCategory(tCategory)).called(1);
      verifyNoMoreInteractions(mockCategoryRepository);
    });

    test('should throw ValidationFailure when name is empty', () async {
      final invalidCategory = tCategory.copyWith(name: '');

      expect(
        () => useCase.call(invalidCategory),
        throwsA(isA<ValidationFailure>()),
      );

      verifyZeroInteractions(mockCategoryRepository);
    });

    test(
      'should throw ValidationFailure when name is only whitespace',
      () async {
        final invalidCategory = tCategory.copyWith(name: '   ');

        expect(
          () => useCase.call(invalidCategory),
          throwsA(isA<ValidationFailure>()),
        );

        verifyZeroInteractions(mockCategoryRepository);
      },
    );
  });
}
