import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/domain/entities/tag.dart';
import 'package:tasker/domain/repositories/tag_repository.dart';
import 'package:tasker/domain/usecases/tag/get_tags.dart';

class MockTagRepository extends Mock implements TagRepository {}

void main() {
  late GetTags useCase;
  late MockTagRepository mockTagRepository;

  setUp(() {
    mockTagRepository = MockTagRepository();
    useCase = GetTags(mockTagRepository);
  });

  final tTags = [
    Tag(id: 'tag-1', name: 'urgent', createdAt: DateTime(2026, 1, 1)),
    Tag(id: 'tag-2', name: 'review', createdAt: DateTime(2026, 1, 2)),
  ];

  group('GetTags', () {
    test('should get all tags from the repository', () async {
      when(() => mockTagRepository.getAllTags()).thenAnswer((_) async => tTags);

      final result = await useCase.call();

      expect(result, tTags);
      verify(() => mockTagRepository.getAllTags()).called(1);
      verifyNoMoreInteractions(mockTagRepository);
    });

    test('should return empty list when no tags exist', () async {
      when(() => mockTagRepository.getAllTags()).thenAnswer((_) async => []);

      final result = await useCase.call();

      expect(result, isEmpty);
      verify(() => mockTagRepository.getAllTags()).called(1);
    });
  });
}
