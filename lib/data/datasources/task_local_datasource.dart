import 'package:hive_ce/hive.dart';
import 'package:tasker/data/models/task_model.dart';

abstract class TaskLocalDatasource {
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel?> getTaskById(String id);
  Future<void> createTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskLocalDatasourceImpl implements TaskLocalDatasource {
  TaskLocalDatasourceImpl(this._box);

  final Box<TaskModel> _box;

  @override
  Future<List<TaskModel>> getAllTasks() async {
    return _box.values.toList();
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> createTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }
}
