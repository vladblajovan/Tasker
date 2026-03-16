import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_app/data/datasources/tag_local_datasource.dart';
import 'package:test_app/data/models/tag_model.dart';

class TagRemoteDatasourceImpl implements TagLocalDatasource {
  TagRemoteDatasourceImpl(this._client, this._localDatasource);

  final SupabaseClient _client;
  final TagLocalDatasource _localDatasource;

  static const _table = 'tags';

  @override
  Future<List<TagModel>> getAllTags() async {
    try {
      final rows = await _client.from(_table).select();
      final tags = rows.map(fromSupabaseRow).toList();
      for (final tag in tags) {
        await _localDatasource.createTag(tag);
      }
      return tags;
    } catch (_) {
      return _localDatasource.getAllTags();
    }
  }

  @override
  Future<TagModel?> getTagById(String id) async {
    try {
      final rows = await _client.from(_table).select().eq('id', id);
      if (rows.isEmpty) return null;
      final tag = fromSupabaseRow(rows.first);
      await _localDatasource.createTag(tag);
      return tag;
    } catch (_) {
      return _localDatasource.getTagById(id);
    }
  }

  @override
  Future<void> createTag(TagModel tag) async {
    await _localDatasource.createTag(tag);
    try {
      await _client.from(_table).upsert(toSupabaseRow(tag));
    } catch (_) {}
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    await _localDatasource.updateTag(tag);
    try {
      await _client.from(_table).upsert(toSupabaseRow(tag));
    } catch (_) {}
  }

  @override
  Future<void> deleteTag(String id) async {
    await _localDatasource.deleteTag(id);
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (_) {}
  }

  static TagModel fromSupabaseRow(Map<String, dynamic> row) {
    return TagModel(
      id: row['id'] as String,
      name: row['name'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  static Map<String, dynamic> toSupabaseRow(TagModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'created_at': model.createdAt.toIso8601String(),
    };
  }
}
