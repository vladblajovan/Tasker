import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:tasker/data/models/category_model.dart';
import 'package:tasker/data/models/priority_adapter.dart';
import 'package:tasker/data/models/recurrence_model.dart';
import 'package:tasker/data/models/recurrence_type_adapter.dart';
import 'package:tasker/data/models/tag_model.dart';
import 'package:tasker/data/models/task_model.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  // Register type adapters
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(RecurrenceModelAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(TagModelAdapter());
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(RecurrenceTypeAdapter());

  // Open boxes
  await Hive.openBox<TaskModel>('tasks');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<TagModel>('tags');
}
