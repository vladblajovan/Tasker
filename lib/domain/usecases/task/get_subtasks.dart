import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/task_repository.dart';

class GetSubtasks {
  GetSubtasks(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<List<Task>> call(String parentTaskId) async {
    return _taskRepository.getTasksByParentId(parentTaskId);
  }
}
