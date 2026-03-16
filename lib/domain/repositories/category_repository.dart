import 'package:tasker/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<Category?> getCategoryById(String id);
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}
