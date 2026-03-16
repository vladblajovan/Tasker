import 'package:test_app/data/datasources/task_local_datasource.dart';
import 'package:test_app/data/models/task_model.dart';
import 'package:test_app/domain/entities/task.dart';
import 'package:test_app/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._datasource);

  final TaskLocalDatasource _datasource;

  @override
  Future<List<Task>> getAllTasks() async {
    final models = await _datasource.getAllTasks();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final model = await _datasource.getTaskById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Task>> getTasksByParentId(String parentTaskId) async {
    final models = await _datasource.getAllTasks();
    return models
        .where((model) => model.parentTaskId == parentTaskId)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<Task>> getTasksByCategoryId(String categoryId) async {
    final models = await _datasource.getAllTasks();
    return models
        .where((model) => model.categoryId == categoryId)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<List<Task>> getTasksByTagId(String tagId) async {
    final models = await _datasource.getAllTasks();
    return models
        .where((model) => model.tags.contains(tagId))
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<void> createTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await _datasource.createTask(model);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await _datasource.updateTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _datasource.deleteTask(id);
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    final models = await _datasource.getAllTasks();
    final lowerQuery = query.toLowerCase();
    return models
        .where((model) {
          final titleMatch = model.title.toLowerCase().contains(lowerQuery);
          final descriptionMatch =
              model.description?.toLowerCase().contains(lowerQuery) ?? false;
          return titleMatch || descriptionMatch;
        })
        .map((model) => model.toEntity())
        .toList();
  }
}
