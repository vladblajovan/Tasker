import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/data/datasources/task_local_datasource.dart';
import 'package:test_app/data/models/recurrence_model.dart';
import 'package:test_app/data/models/task_model.dart';
import 'package:test_app/domain/entities/priority.dart';
import 'package:test_app/domain/entities/recurrence.dart';

class TaskRemoteDatasourceImpl implements TaskLocalDatasource {
  TaskRemoteDatasourceImpl(this._client, this._localDatasource);

  final SupabaseClient _client;
  final TaskLocalDatasource _localDatasource;

  static const _table = 'tasks';

  // ──── Reads ────

  @override
  Future<List<TaskModel>> getAllTasks() async {
    try {
      final rows = await _client.from(_table).select();
      final tasks = rows.map(fromSupabaseRow).toList();
      // Cache to local
      for (final task in tasks) {
        await _localDatasource.createTask(task);
      }
      return tasks;
    } catch (_) {
      // Offline fallback
      return _localDatasource.getAllTasks();
    }
  }

  @override
  Future<TaskModel?> getTaskById(String id) async {
    try {
      final rows = await _client.from(_table).select().eq('id', id);
      if (rows.isEmpty) return null;
      final task = fromSupabaseRow(rows.first);
      await _localDatasource.createTask(task);
      return task;
    } catch (_) {
      return _localDatasource.getTaskById(id);
    }
  }

  // ──── Writes (optimistic local) ────

  @override
  Future<void> createTask(TaskModel task) async {
    await _localDatasource.createTask(task);
    try {
      await _client.from(_table).upsert(toSupabaseRow(task));
    } catch (_) {
      // Local data persists — sync/retry out of scope for v1
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _localDatasource.updateTask(task);
    try {
      await _client.from(_table).upsert(toSupabaseRow(task));
    } catch (_) {}
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDatasource.deleteTask(id);
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (_) {}
  }

  // ──── Conversion Helpers ────

  static TaskModel fromSupabaseRow(Map<String, dynamic> row) {
    return TaskModel(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String?,
      isCompleted: row['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      dueDate: row['due_date'] != null
          ? DateTime.parse(row['due_date'] as String)
          : null,
      priority: Priority.values[row['priority'] as int? ?? 0],
      categoryId: row['category_id'] as String?,
      tags: List<String>.from(row['tags'] ?? []),
      parentTaskId: row['parent_task_id'] as String?,
      recurrence: _recurrenceFromRow(row),
      completedAt: row['completed_at'] != null
          ? DateTime.parse(row['completed_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic> toSupabaseRow(TaskModel model) {
    return {
      'id': model.id,
      'title': model.title,
      'description': model.description,
      'is_completed': model.isCompleted,
      'created_at': model.createdAt.toIso8601String(),
      'updated_at': model.updatedAt.toIso8601String(),
      'due_date': model.dueDate?.toIso8601String(),
      'priority': model.priority.index,
      'category_id': model.categoryId,
      'tags': model.tags,
      'parent_task_id': model.parentTaskId,
      'completed_at': model.completedAt?.toIso8601String(),
      'recurrence_type': model.recurrence?.type.index,
      'recurrence_interval': model.recurrence?.interval,
      'recurrence_days_of_week': model.recurrence?.weekdays,
      'recurrence_end_date': model.recurrence?.endDate?.toIso8601String(),
    };
  }

  static RecurrenceModel? _recurrenceFromRow(Map<String, dynamic> row) {
    final type = row['recurrence_type'] as int?;
    if (type == null) return null;
    return RecurrenceModel(
      type: RecurrenceType.values[type],
      interval: row['recurrence_interval'] as int,
      weekdays: row['recurrence_days_of_week'] != null
          ? List<int>.from(row['recurrence_days_of_week'])
          : null,
      endDate: row['recurrence_end_date'] != null
          ? DateTime.parse(row['recurrence_end_date'] as String)
          : null,
    );
  }
}
