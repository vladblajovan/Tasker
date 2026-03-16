import 'package:hive_ce/hive.dart';
import 'package:test_app/data/models/category_model.dart';

abstract class CategoryLocalDatasource {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryById(String id);
  Future<void> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  CategoryLocalDatasourceImpl(this._box);

  final Box<CategoryModel> _box;

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return _box.values.toList();
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> createCategory(CategoryModel category) async {
    await _box.put(category.id, category);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _box.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }
}
