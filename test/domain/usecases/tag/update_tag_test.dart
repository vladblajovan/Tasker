import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tasker/core/error/failures.dart';
import 'package:tasker/domain/entities/tag.dart';
import 'package:tasker/domain/repositories/tag_repository.dart';
import 'package:tasker/domain/usecases/tag/update_tag.dart';

class MockTagRepository extends Mock implements TagRepository {}

void main() {
  late UpdateTag useCase;
  late MockTagRepository mockTagRepository;

  setUp(() {
    mockTagRepository = MockTagRepository();
    useCase = UpdateTag(mockTagRepository);
  });

  final tTag = Tag(
    id: 'tag-1',
    name: 'urgent',
    createdAt: DateTime(2026, 1, 1),
  );

  group('UpdateTag', () {
    test('should update a tag via the repository', () async {
      when(() => mockTagRepository.updateTag(tTag)).thenAnswer((_) async {});

      await useCase.call(tTag);

      verify(() => mockTagRepository.updateTag(tTag)).called(1);
      verifyNoMoreInteractions(mockTagRepository);
    });

    test('should throw ValidationFailure when name is empty', () async {
      final invalidTag = tTag.copyWith(name: '');

      expect(() => useCase.call(invalidTag), throwsA(isA<ValidationFailure>()));

      verifyZeroInteractions(mockTagRepository);
    });

    test(
      'should throw ValidationFailure when name is only whitespace',
      () async {
        final invalidTag = tTag.copyWith(name: '   ');

        expect(
          () => useCase.call(invalidTag),
          throwsA(isA<ValidationFailure>()),
        );

        verifyZeroInteractions(mockTagRepository);
      },
    );
  });
}
