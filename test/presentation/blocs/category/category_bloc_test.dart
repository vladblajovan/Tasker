import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/domain/entities/category.dart';
import 'package:tasker/domain/usecases/category/create_category.dart';
import 'package:tasker/domain/usecases/category/delete_category.dart';
import 'package:tasker/domain/usecases/category/get_categories.dart';
import 'package:tasker/domain/usecases/category/update_category.dart';
import 'package:tasker/presentation/blocs/category/category_bloc.dart';
import 'package:tasker/presentation/blocs/category/category_event.dart';
import 'package:tasker/presentation/blocs/category/category_state.dart';

class MockGetCategories extends Mock implements GetCategories {}

class MockCreateCategory extends Mock implements CreateCategory {}

class MockUpdateCategory extends Mock implements UpdateCategory {}

class MockDeleteCategory extends Mock implements DeleteCategory {}

class FakeCategory extends Fake implements Category {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCategory());
  });

  late MockGetCategories mockGetCategories;
  late MockCreateCategory mockCreateCategory;
  late MockUpdateCategory mockUpdateCategory;
  late MockDeleteCategory mockDeleteCategory;

  final now = DateTime(2026, 3, 14);

  final tCategory1 = Category(
    id: 'cat-1',
    name: 'Work',
    color: 0xFF0000FF,
    createdAt: now,
    order: 0,
  );

  final tCategory2 = Category(
    id: 'cat-2',
    name: 'Personal',
    color: 0xFFFF0000,
    createdAt: now,
    order: 1,
  );

  CategoryBloc buildBloc() => CategoryBloc(
    getCategories: mockGetCategories,
    createCategory: mockCreateCategory,
    updateCategory: mockUpdateCategory,
    deleteCategory: mockDeleteCategory,
  );

  setUp(() {
    mockGetCategories = MockGetCategories();
    mockCreateCategory = MockCreateCategory();
    mockUpdateCategory = MockUpdateCategory();
    mockDeleteCategory = MockDeleteCategory();
  });

  group('CategoryBloc', () {
    test('initial state is CategoryInitial', () {
      expect(buildBloc().state, const CategoryInitial());
    });

    group('LoadCategories', () {
      blocTest<CategoryBloc, CategoryState>(
        'emits [CategoryLoading, CategoryLoaded] with sorted categories',
        build: buildBloc,
        setUp: () {
          when(
            () => mockGetCategories(),
          ).thenAnswer((_) async => [tCategory2, tCategory1]);
        },
        act: (bloc) => bloc.add(const LoadCategories()),
        expect: () => [
          const CategoryLoading(),
          isA<CategoryLoaded>()
              .having((s) => s.categories.length, 'categories length', 2)
              .having(
                (s) => s.categories.first.id,
                'first category is order 0',
                'cat-1',
              ),
        ],
      );

      blocTest<CategoryBloc, CategoryState>(
        'emits CategoryError when getCategories throws',
        build: buildBloc,
        setUp: () {
          when(() => mockGetCategories()).thenThrow(Exception('DB error'));
        },
        act: (bloc) => bloc.add(const LoadCategories()),
        expect: () => [const CategoryLoading(), isA<CategoryError>()],
      );
    });

    group('CreateCategoryEvent', () {
      blocTest<CategoryBloc, CategoryState>(
        'calls createCategory and reloads',
        build: buildBloc,
        setUp: () {
          when(() => mockCreateCategory(tCategory1)).thenAnswer((_) async {});
          when(() => mockGetCategories()).thenAnswer((_) async => [tCategory1]);
        },
        act: (bloc) => bloc.add(CreateCategoryEvent(tCategory1)),
        expect: () => [const CategoryLoading(), isA<CategoryLoaded>()],
        verify: (_) {
          verify(() => mockCreateCategory(tCategory1)).called(1);
        },
      );

      blocTest<CategoryBloc, CategoryState>(
        'emits CategoryError when createCategory throws',
        build: buildBloc,
        setUp: () {
          when(
            () => mockCreateCategory(tCategory1),
          ).thenThrow(Exception('error'));
        },
        act: (bloc) => bloc.add(CreateCategoryEvent(tCategory1)),
        expect: () => [isA<CategoryError>()],
      );
    });

    group('UpdateCategoryEvent', () {
      blocTest<CategoryBloc, CategoryState>(
        'calls updateCategory and reloads',
        build: buildBloc,
        setUp: () {
          when(() => mockUpdateCategory(tCategory1)).thenAnswer((_) async {});
          when(() => mockGetCategories()).thenAnswer((_) async => [tCategory1]);
        },
        act: (bloc) => bloc.add(UpdateCategoryEvent(tCategory1)),
        expect: () => [const CategoryLoading(), isA<CategoryLoaded>()],
        verify: (_) {
          verify(() => mockUpdateCategory(tCategory1)).called(1);
        },
      );
    });

    group('DeleteCategoryEvent', () {
      blocTest<CategoryBloc, CategoryState>(
        'calls deleteCategory and reloads',
        build: buildBloc,
        setUp: () {
          when(() => mockDeleteCategory('cat-1')).thenAnswer((_) async {});
          when(() => mockGetCategories()).thenAnswer((_) async => [tCategory2]);
        },
        act: (bloc) => bloc.add(const DeleteCategoryEvent('cat-1')),
        expect: () => [const CategoryLoading(), isA<CategoryLoaded>()],
        verify: (_) {
          verify(() => mockDeleteCategory('cat-1')).called(1);
        },
      );
    });

    group('ReorderCategories', () {
      blocTest<CategoryBloc, CategoryState>(
        'updates each category order and reloads',
        build: buildBloc,
        seed: () => CategoryLoaded([tCategory1, tCategory2]),
        setUp: () {
          // After reorder, cat-2 becomes order 0, cat-1 becomes order 1
          when(() => mockUpdateCategory(any())).thenAnswer((_) async {});
          when(() => mockGetCategories()).thenAnswer(
            (_) async => [
              tCategory2.copyWith(order: 0),
              tCategory1.copyWith(order: 1),
            ],
          );
        },
        act: (bloc) => bloc.add(const ReorderCategories(['cat-2', 'cat-1'])),
        expect: () => [
          const CategoryLoading(),
          isA<CategoryLoaded>().having(
            (s) => s.categories.first.id,
            'first after reorder',
            'cat-2',
          ),
        ],
        verify: (_) {
          // updateCategory called twice (once per category)
          verify(() => mockUpdateCategory(any())).called(2);
        },
      );

      blocTest<CategoryBloc, CategoryState>(
        'does nothing when state is not CategoryLoaded',
        build: buildBloc,
        act: (bloc) => bloc.add(const ReorderCategories(['cat-1', 'cat-2'])),
        expect: () => [],
      );
    });
  });
}
