import 'package:hive_ce/hive.dart';
import 'package:tasker/domain/entities/category.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.order,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int color;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int order;

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      color: color,
      createdAt: createdAt,
      order: order,
    );
  }

  static CategoryModel fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      color: entity.color,
      createdAt: entity.createdAt,
      order: entity.order,
    );
  }
}
