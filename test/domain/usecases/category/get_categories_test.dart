import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/domain/entities/category.dart';
import 'package:tasker/domain/repositories/category_repository.dart';
import 'package:tasker/domain/usecases/category/get_categories.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late GetCategories useCase;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    useCase = GetCategories(mockCategoryRepository);
  });

  final tCategories = [
    Category(
      id: 'cat-1',
      name: 'Work',
      color: 0xFF42A5F5,
      createdAt: DateTime(2026, 1, 1),
      order: 0,
    ),
    Category(
      id: 'cat-2',
      name: 'Personal',
      color: 0xFFEF5350,
      createdAt: DateTime(2026, 1, 2),
      order: 1,
    ),
  ];

  group('GetCategories', () {
    test('should get all categories from the repository', () async {
      when(
        () => mockCategoryRepository.getAllCategories(),
      ).thenAnswer((_) async => tCategories);

      final result = await useCase.call();

      expect(result, tCategories);
      verify(() => mockCategoryRepository.getAllCategories()).called(1);
      verifyNoMoreInteractions(mockCategoryRepository);
    });

    test('should return empty list when no categories exist', () async {
      when(
        () => mockCategoryRepository.getAllCategories(),
      ).thenAnswer((_) async => []);

      final result = await useCase.call();

      expect(result, isEmpty);
      verify(() => mockCategoryRepository.getAllCategories()).called(1);
    });
  });
}
