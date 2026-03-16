import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/data/datasources/category_local_datasource.dart';
import 'package:tasker/data/models/category_model.dart';
import 'package:tasker/data/repositories/category_repository_impl.dart';
import 'package:tasker/domain/entities/category.dart';

class MockCategoryLocalDatasource extends Mock
    implements CategoryLocalDatasource {}

class FakeCategoryModel extends Fake implements CategoryModel {}

void main() {
  late CategoryRepositoryImpl repository;
  late MockCategoryLocalDatasource mockDatasource;

  setUpAll(() {
    registerFallbackValue(FakeCategoryModel());
  });

  setUp(() {
    mockDatasource = MockCategoryLocalDatasource();
    repository = CategoryRepositoryImpl(mockDatasource);
  });

  final tCategoryModel = CategoryModel(
    id: 'cat-1',
    name: 'Work',
    color: 0xFF42A5F5,
    createdAt: DateTime(2026, 1, 1),
    order: 0,
  );

  final tCategory = Category(
    id: 'cat-1',
    name: 'Work',
    color: 0xFF42A5F5,
    createdAt: DateTime(2026, 1, 1),
    order: 0,
  );

  group('getAllCategories', () {
    test('should return list of categories from datasource', () async {
      when(
        () => mockDatasource.getAllCategories(),
      ).thenAnswer((_) async => [tCategoryModel]);

      final result = await repository.getAllCategories();

      expect(result.length, 1);
      expect(result.first.id, tCategory.id);
      expect(result.first.name, tCategory.name);
      verify(() => mockDatasource.getAllCategories()).called(1);
    });
  });

  group('getCategoryById', () {
    test('should return category when found', () async {
      when(
        () => mockDatasource.getCategoryById('cat-1'),
      ).thenAnswer((_) async => tCategoryModel);

      final result = await repository.getCategoryById('cat-1');

      expect(result, isNotNull);
      expect(result!.id, tCategory.id);
      verify(() => mockDatasource.getCategoryById('cat-1')).called(1);
    });

    test('should return null when not found', () async {
      when(
        () => mockDatasource.getCategoryById('cat-1'),
      ).thenAnswer((_) async => null);

      final result = await repository.getCategoryById('cat-1');

      expect(result, isNull);
    });
  });

  group('createCategory', () {
    test(
      'should create category via datasource using fromEntity mapping',
      () async {
        when(
          () => mockDatasource.createCategory(any()),
        ).thenAnswer((_) async {});

        await repository.createCategory(tCategory);

        final captured = verify(
          () => mockDatasource.createCategory(captureAny()),
        ).captured;
        final model = captured.first as CategoryModel;
        expect(model.id, tCategory.id);
        expect(model.name, tCategory.name);
        expect(model.color, tCategory.color);
      },
    );
  });

  group('updateCategory', () {
    test(
      'should update category via datasource using fromEntity mapping',
      () async {
        when(
          () => mockDatasource.updateCategory(any()),
        ).thenAnswer((_) async {});

        await repository.updateCategory(tCategory);

        final captured = verify(
          () => mockDatasource.updateCategory(captureAny()),
        ).captured;
        final model = captured.first as CategoryModel;
        expect(model.id, tCategory.id);
        expect(model.name, tCategory.name);
      },
    );
  });

  group('deleteCategory', () {
    test('should delete category via datasource', () async {
      when(
        () => mockDatasource.deleteCategory('cat-1'),
      ).thenAnswer((_) async {});

      await repository.deleteCategory('cat-1');

      verify(() => mockDatasource.deleteCategory('cat-1')).called(1);
    });
  });
}
