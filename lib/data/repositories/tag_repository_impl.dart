import 'package:tasker/data/datasources/tag_local_datasource.dart';
import 'package:tasker/data/models/tag_model.dart';
import 'package:tasker/domain/entities/tag.dart';
import 'package:tasker/domain/repositories/tag_repository.dart';

class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(this._datasource);

  final TagLocalDatasource _datasource;

  @override
  Future<List<Tag>> getAllTags() async {
    final models = await _datasource.getAllTags();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Tag?> getTagById(String id) async {
    final model = await _datasource.getTagById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createTag(Tag tag) async {
    final model = TagModel.fromEntity(tag);
    await _datasource.createTag(model);
  }

  @override
  Future<void> updateTag(Tag tag) async {
    final model = TagModel.fromEntity(tag);
    await _datasource.updateTag(model);
  }

  @override
  Future<void> deleteTag(String id) async {
    await _datasource.deleteTag(id);
  }
}
