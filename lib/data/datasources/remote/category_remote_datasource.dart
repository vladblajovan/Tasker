import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tasker/data/datasources/category_local_datasource.dart';
import 'package:tasker/data/models/category_model.dart';

class CategoryRemoteDatasourceImpl implements CategoryLocalDatasource {
  CategoryRemoteDatasourceImpl(this._client, this._localDatasource);

  final SupabaseClient _client;
  final CategoryLocalDatasource _localDatasource;

  static const _table = 'categories';

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final rows = await _client.from(_table).select();
      final categories = rows.map(fromSupabaseRow).toList();
      for (final cat in categories) {
        await _localDatasource.createCategory(cat);
      }
      return categories;
    } catch (_) {
      return _localDatasource.getAllCategories();
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final rows = await _client.from(_table).select().eq('id', id);
      if (rows.isEmpty) return null;
      final cat = fromSupabaseRow(rows.first);
      await _localDatasource.createCategory(cat);
      return cat;
    } catch (_) {
      return _localDatasource.getCategoryById(id);
    }
  }

  @override
  Future<void> createCategory(CategoryModel category) async {
    await _localDatasource.createCategory(category);
    try {
      await _client.from(_table).upsert(toSupabaseRow(category));
    } catch (_) {}
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _localDatasource.updateCategory(category);
    try {
      await _client.from(_table).upsert(toSupabaseRow(category));
    } catch (_) {}
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDatasource.deleteCategory(id);
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (_) {}
  }

  static CategoryModel fromSupabaseRow(Map<String, dynamic> row) {
    return CategoryModel(
      id: row['id'] as String,
      name: row['name'] as String,
      color: row['color'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      order: row['order'] as int? ?? 0,
    );
  }

  static Map<String, dynamic> toSupabaseRow(CategoryModel model) {
    return {
      'id': model.id,
      'name': model.name,
      'color': model.color,
      'created_at': model.createdAt.toIso8601String(),
      'order': model.order,
    };
  }
}
