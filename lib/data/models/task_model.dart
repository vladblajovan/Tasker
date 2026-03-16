import 'package:hive_ce/hive.dart';
import 'package:tasker/data/models/recurrence_model.dart';
import 'package:tasker/domain/entities/priority.dart';
import 'package:tasker/domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    required this.priority,
    this.categoryId,
    required this.tags,
    this.parentTaskId,
    this.recurrence,
    this.completedAt,
    this.orderIndex = 0,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final DateTime? dueDate;

  @HiveField(7)
  final Priority priority;

  @HiveField(8)
  final String? categoryId;

  @HiveField(9)
  final List<String> tags;

  @HiveField(10)
  final String? parentTaskId;

  @HiveField(11)
  final RecurrenceModel? recurrence;

  @HiveField(12)
  final DateTime? completedAt;

  @HiveField(13)
  final int orderIndex;

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
      dueDate: dueDate,
      priority: priority,
      categoryId: categoryId,
      tags: tags,
      parentTaskId: parentTaskId,
      recurrence: recurrence?.toEntity(),
      completedAt: completedAt,
      orderIndex: orderIndex,
    );
  }

  static TaskModel fromEntity(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      dueDate: entity.dueDate,
      priority: entity.priority,
      categoryId: entity.categoryId,
      tags: entity.tags,
      parentTaskId: entity.parentTaskId,
      recurrence: entity.recurrence != null
          ? RecurrenceModel.fromEntity(entity.recurrence!)
          : null,
      completedAt: entity.completedAt,
      orderIndex: entity.orderIndex,
    );
  }
}
