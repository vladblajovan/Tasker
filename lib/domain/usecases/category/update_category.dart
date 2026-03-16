import 'package:tasker/core/error/failures.dart';
import 'package:tasker/domain/entities/category.dart';
import 'package:tasker/domain/repositories/category_repository.dart';

class UpdateCategory {
  UpdateCategory(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  Future<void> call(Category category) async {
    if (category.name.trim().isEmpty) {
      throw const ValidationFailure('Category name cannot be empty');
    }

    await _categoryRepository.updateCategory(category);
  }
}
