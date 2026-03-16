import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/recurrence.dart';

part 'task.freezed.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    String? description,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? dueDate,
    @Default(Priority.none) Priority priority,
    String? categoryId,
    @Default([]) List<String> tags,
    String? parentTaskId,
    Recurrence? recurrence,
    DateTime? completedAt,
    @Default(0) int orderIndex,
  }) = _Task;
}
