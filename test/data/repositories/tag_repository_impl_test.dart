import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/data/datasources/tag_local_datasource.dart';
import 'package:tasker/data/models/tag_model.dart';
import 'package:tasker/data/repositories/tag_repository_impl.dart';
import 'package:tasker/domain/entities/tag.dart';

class MockTagLocalDatasource extends Mock implements TagLocalDatasource {}

class FakeTagModel extends Fake implements TagModel {}

void main() {
  late TagRepositoryImpl repository;
  late MockTagLocalDatasource mockDatasource;

  setUpAll(() {
    registerFallbackValue(FakeTagModel());
  });

  setUp(() {
    mockDatasource = MockTagLocalDatasource();
    repository = TagRepositoryImpl(mockDatasource);
  });

  final tTagModel = TagModel(
    id: 'tag-1',
    name: 'urgent',
    createdAt: DateTime(2026, 1, 1),
  );

  final tTag = Tag(
    id: 'tag-1',
    name: 'urgent',
    createdAt: DateTime(2026, 1, 1),
  );

  group('getAllTags', () {
    test('should return list of tags from datasource', () async {
      when(
        () => mockDatasource.getAllTags(),
      ).thenAnswer((_) async => [tTagModel]);

      final result = await repository.getAllTags();

      expect(result.length, 1);
      expect(result.first.id, tTag.id);
      expect(result.first.name, tTag.name);
      verify(() => mockDatasource.getAllTags()).called(1);
    });
  });

  group('getTagById', () {
    test('should return tag when found', () async {
      when(
        () => mockDatasource.getTagById('tag-1'),
      ).thenAnswer((_) async => tTagModel);

      final result = await repository.getTagById('tag-1');

      expect(result, isNotNull);
      expect(result!.id, tTag.id);
      verify(() => mockDatasource.getTagById('tag-1')).called(1);
    });

    test('should return null when not found', () async {
      when(
        () => mockDatasource.getTagById('tag-1'),
      ).thenAnswer((_) async => null);

      final result = await repository.getTagById('tag-1');

      expect(result, isNull);
    });
  });

  group('createTag', () {
    test('should create tag via datasource using fromEntity mapping', () async {
      when(() => mockDatasource.createTag(any())).thenAnswer((_) async {});

      await repository.createTag(tTag);

      final captured = verify(
        () => mockDatasource.createTag(captureAny()),
      ).captured;
      final model = captured.first as TagModel;
      expect(model.id, tTag.id);
      expect(model.name, tTag.name);
    });
  });

  group('updateTag', () {
    test('should update tag via datasource using fromEntity mapping', () async {
      when(() => mockDatasource.updateTag(any())).thenAnswer((_) async {});

      await repository.updateTag(tTag);

      final captured = verify(
        () => mockDatasource.updateTag(captureAny()),
      ).captured;
      final model = captured.first as TagModel;
      expect(model.id, tTag.id);
      expect(model.name, tTag.name);
    });
  });

  group('deleteTag', () {
    test('should delete tag via datasource', () async {
      when(() => mockDatasource.deleteTag('tag-1')).thenAnswer((_) async {});

      await repository.deleteTag('tag-1');

      verify(() => mockDatasource.deleteTag('tag-1')).called(1);
    });
  });
}
