import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/repositories/task_repository.dart';

class GetSubtasks {
  GetSubtasks(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<List<Task>> call(String parentTaskId) async {
    return _taskRepository.getTasksByParentId(parentTaskId);
  }
}
