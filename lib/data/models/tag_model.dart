import 'package:hive_ce/hive.dart';
import 'package:tasker/domain/entities/tag.dart';

part 'tag_model.g.dart';

@HiveType(typeId: 3)
class TagModel extends HiveObject {
  TagModel({required this.id, required this.name, required this.createdAt});

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime createdAt;

  Tag toEntity() {
    return Tag(id: id, name: name, createdAt: createdAt);
  }

  static TagModel fromEntity(Tag entity) {
    return TagModel(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
    );
  }
}
