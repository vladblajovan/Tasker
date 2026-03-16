import 'package:test_app/domain/repositories/category_repository.dart';
import 'package:test_app/domain/repositories/task_repository.dart';

class DeleteCategory {
  DeleteCategory(this._categoryRepository, this._taskRepository);

  final CategoryRepository _categoryRepository;
  final TaskRepository _taskRepository;

  Future<void> call(String categoryId) async {
    final affectedTasks =
        await _taskRepository.getTasksByCategoryId(categoryId);

    for (final task in affectedTasks) {
      final updatedTask = task.copyWith(categoryId: null);
      await _taskRepository.updateTask(updatedTask);
    }

    await _categoryRepository.deleteCategory(categoryId);
  }
}
