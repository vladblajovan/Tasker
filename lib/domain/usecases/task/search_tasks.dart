import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/repositories/task_repository.dart';

class SearchTasks {
  SearchTasks(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<List<Task>> call(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return [];
    }

    return _taskRepository.searchTasks(trimmedQuery);
  }
}
