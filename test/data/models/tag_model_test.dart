import 'package:flutter_test/flutter_test.dart';
import 'package:tasker/data/models/tag_model.dart';
import 'package:tasker/domain/entities/tag.dart';

void main() {
  group('TagModel', () {
    test('toEntity and fromEntity round-trip preserves all fields', () {
      final tag = Tag(
        id: 'tag-1',
        name: 'Urgent',
        createdAt: DateTime(2026, 1, 1),
      );

      final model = TagModel.fromEntity(tag);
      final result = model.toEntity();

      expect(result.id, tag.id);
      expect(result.name, tag.name);
      expect(result.createdAt, tag.createdAt);
    });
  });
}
