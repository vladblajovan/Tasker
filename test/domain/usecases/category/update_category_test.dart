import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_app/core/error/failures.dart';
import 'package:test_app/domain/entities/category.dart';
import 'package:test_app/domain/repositories/category_repository.dart';
import 'package:test_app/domain/usecases/category/update_category.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late UpdateCategory useCase;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    useCase = UpdateCategory(mockCategoryRepository);
  });

  final tCategory = Category(
    id: 'cat-1',
    name: 'Work',
    color: 0xFF42A5F5,
    createdAt: DateTime(2026, 1, 1),
    order: 0,
  );

  group('UpdateCategory', () {
    test('should update a category via the repository', () async {
      when(() => mockCategoryRepository.updateCategory(tCategory))
          .thenAnswer((_) async {});

      await useCase.call(tCategory);

      verify(() => mockCategoryRepository.updateCategory(tCategory)).called(1);
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

    test('should throw ValidationFailure when name is only whitespace',
        () async {
      final invalidCategory = tCategory.copyWith(name: '   ');

      expect(
        () => useCase.call(invalidCategory),
        throwsA(isA<ValidationFailure>()),
      );

      verifyZeroInteractions(mockCategoryRepository);
    });
  });
}
