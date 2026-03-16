import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_app/domain/entities/priority.dart';
import 'package:test_app/domain/entities/recurrence.dart';

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
  }) = _Task;
}
