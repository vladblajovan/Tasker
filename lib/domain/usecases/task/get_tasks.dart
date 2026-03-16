import 'package:tasker/domain/entities/task.dart';
import 'package:tasker/domain/repositories/task_repository.dart';

class GetTasks {
  GetTasks(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<List<Task>> call() async {
    return _taskRepository.getAllTasks();
  }
}
