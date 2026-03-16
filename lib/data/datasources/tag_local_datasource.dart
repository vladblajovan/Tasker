import 'package:hive_ce/hive.dart';
import 'package:test_app/data/models/tag_model.dart';

abstract class TagLocalDatasource {
  Future<List<TagModel>> getAllTags();
  Future<TagModel?> getTagById(String id);
  Future<void> createTag(TagModel tag);
  Future<void> updateTag(TagModel tag);
  Future<void> deleteTag(String id);
}

class TagLocalDatasourceImpl implements TagLocalDatasource {
  TagLocalDatasourceImpl(this._box);

  final Box<TagModel> _box;

  @override
  Future<List<TagModel>> getAllTags() async {
    return _box.values.toList();
  }

  @override
  Future<TagModel?> getTagById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> createTag(TagModel tag) async {
    await _box.put(tag.id, tag);
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    await _box.put(tag.id, tag);
  }

  @override
  Future<void> deleteTag(String id) async {
    await _box.delete(id);
  }
}
