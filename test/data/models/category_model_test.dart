import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/models/category_model.dart';
import 'package:test_app/domain/entities/category.dart';

void main() {
  group('CategoryModel', () {
    test('toEntity and fromEntity round-trip preserves all fields', () {
      final category = Category(
        id: 'cat-1',
        name: 'Work',
        color: 0xFF42A5F5,
        createdAt: DateTime(2026, 1, 1),
        order: 2,
      );

      final model = CategoryModel.fromEntity(category);
      final result = model.toEntity();

      expect(result.id, category.id);
      expect(result.name, category.name);
      expect(result.color, category.color);
      expect(result.createdAt, category.createdAt);
      expect(result.order, category.order);
    });
  });
}
