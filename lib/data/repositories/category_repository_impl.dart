import 'package:test_app/data/datasources/category_local_datasource.dart';
import 'package:test_app/data/models/category_model.dart';
import 'package:test_app/domain/entities/category.dart';
import 'package:test_app/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._datasource);

  final CategoryLocalDatasource _datasource;

  @override
  Future<List<Category>> getAllCategories() async {
    final models = await _datasource.getAllCategories();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final model = await _datasource.getCategoryById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await _datasource.createCategory(model);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await _datasource.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _datasource.deleteCategory(id);
  }
}
