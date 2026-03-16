import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/datasources/remote/category_remote_datasource.dart';
import 'package:test_app/data/models/category_model.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  final tCategoryModel = CategoryModel(
    id: 'cat-1',
    name: 'Work',
    color: 0xFF2196F3,
    createdAt: now,
    order: 0,
  );

  group('toSupabaseRow / fromSupabaseRow', () {
    test('round-trips a CategoryModel correctly', () {
      final row = CategoryRemoteDatasourceImpl.toSupabaseRow(tCategoryModel);
      final result = CategoryRemoteDatasourceImpl.fromSupabaseRow(row);

      expect(result.id, tCategoryModel.id);
      expect(result.name, tCategoryModel.name);
      expect(result.color, tCategoryModel.color);
      expect(result.order, tCategoryModel.order);
    });
  });
}
