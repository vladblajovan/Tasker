import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/repositories/task_repository.dart';

class GetTasks {
  GetTasks(this._taskRepository);

  final TaskRepository _taskRepository;

  Future<List<Task>> call() async {
    return _taskRepository.getAllTasks();
  }
}
