import 'package:flutter_test/flutter_test.dart';
import 'package:test_app/data/datasources/remote/tag_remote_datasource.dart';
import 'package:test_app/data/models/tag_model.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  final tTagModel = TagModel(
    id: 'tag-1',
    name: 'urgent',
    createdAt: now,
  );

  group('toSupabaseRow / fromSupabaseRow', () {
    test('round-trips a TagModel correctly', () {
      final row = TagRemoteDatasourceImpl.toSupabaseRow(tTagModel);
      final result = TagRemoteDatasourceImpl.fromSupabaseRow(row);

      expect(result.id, tTagModel.id);
      expect(result.name, tTagModel.name);
    });
  });
}
