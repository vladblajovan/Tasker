import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_app/domain/usecases/category/create_category.dart';
import 'package:test_app/domain/usecases/category/delete_category.dart';
import 'package:test_app/domain/usecases/category/get_categories.dart';
import 'package:test_app/domain/usecases/category/update_category.dart';
import 'package:test_app/presentation/blocs/category/category_event.dart';
import 'package:test_app/presentation/blocs/category/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({
    required GetCategories getCategories,
    required CreateCategory createCategory,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
  })  : _getCategories = getCategories,
        _createCategory = createCategory,
        _updateCategory = updateCategory,
        _deleteCategory = deleteCategory,
        super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<ReorderCategories>(_onReorderCategories);
  }

  final GetCategories _getCategories;
  final CreateCategory _createCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    try {
      final categories = await _getCategories();
      final sorted = List.of(categories)..sort((a, b) => a.order.compareTo(b.order));
      emit(CategoryLoaded(sorted));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _createCategory(event.category);
      add(const LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _updateCategory(event.category);
      add(const LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _deleteCategory(event.id);
      add(const LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onReorderCategories(
    ReorderCategories event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;

    try {
      final categoriesById = {
        for (final c in currentState.categories) c.id: c,
      };

      for (var i = 0; i < event.orderedIds.length; i++) {
        final id = event.orderedIds[i];
        final category = categoriesById[id];
        if (category == null) continue;
        final updated = category.copyWith(order: i);
        await _updateCategory(updated);
      }

      add(const LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
