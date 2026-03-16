import 'package:tasker/domain/entities/category.dart';
import 'package:tasker/domain/repositories/category_repository.dart';

class GetCategories {
  GetCategories(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  Future<List<Category>> call() async {
    return _categoryRepository.getAllCategories();
  }
}
