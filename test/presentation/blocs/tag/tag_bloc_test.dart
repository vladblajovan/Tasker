import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_app/domain/entities/tag.dart';
import 'package:test_app/domain/usecases/tag/create_tag.dart';
import 'package:test_app/domain/usecases/tag/delete_tag.dart';
import 'package:test_app/domain/usecases/tag/get_tags.dart';
import 'package:test_app/domain/usecases/tag/update_tag.dart';
import 'package:test_app/presentation/blocs/tag/tag_bloc.dart';
import 'package:test_app/presentation/blocs/tag/tag_event.dart';
import 'package:test_app/presentation/blocs/tag/tag_state.dart';

class MockGetTags extends Mock implements GetTags {}

class MockCreateTag extends Mock implements CreateTag {}

class MockUpdateTag extends Mock implements UpdateTag {}

class MockDeleteTag extends Mock implements DeleteTag {}

class FakeTag extends Fake implements Tag {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTag());
  });

  late MockGetTags mockGetTags;
  late MockCreateTag mockCreateTag;
  late MockUpdateTag mockUpdateTag;
  late MockDeleteTag mockDeleteTag;

  final now = DateTime(2026, 3, 14);

  final tTag1 = Tag(id: 'tag-1', name: 'Flutter', createdAt: now);
  final tTag2 = Tag(id: 'tag-2', name: 'Dart', createdAt: now);

  TagBloc buildBloc() => TagBloc(
        getTags: mockGetTags,
        createTag: mockCreateTag,
        updateTag: mockUpdateTag,
        deleteTag: mockDeleteTag,
      );

  setUp(() {
    mockGetTags = MockGetTags();
    mockCreateTag = MockCreateTag();
    mockUpdateTag = MockUpdateTag();
    mockDeleteTag = MockDeleteTag();
  });

  group('TagBloc', () {
    test('initial state is TagInitial', () {
      expect(buildBloc().state, const TagInitial());
    });

    group('LoadTags', () {
      blocTest<TagBloc, TagState>(
        'emits [TagLoading, TagLoaded] with tags',
        build: buildBloc,
        setUp: () {
          when(() => mockGetTags()).thenAnswer(
            (_) async => [tTag1, tTag2],
          );
        },
        act: (bloc) => bloc.add(const LoadTags()),
        expect: () => [
          const TagLoading(),
          isA<TagLoaded>().having((s) => s.tags.length, 'tags length', 2),
        ],
      );

      blocTest<TagBloc, TagState>(
        'emits TagError when getTags throws',
        build: buildBloc,
        setUp: () {
          when(() => mockGetTags()).thenThrow(Exception('DB error'));
        },
        act: (bloc) => bloc.add(const LoadTags()),
        expect: () => [
          const TagLoading(),
          isA<TagError>(),
        ],
      );
    });

    group('CreateTagEvent', () {
      blocTest<TagBloc, TagState>(
        'calls createTag and reloads tags',
        build: buildBloc,
        setUp: () {
          when(() => mockCreateTag(tTag1)).thenAnswer((_) async {});
          when(() => mockGetTags()).thenAnswer((_) async => [tTag1]);
        },
        act: (bloc) => bloc.add(CreateTagEvent(tTag1)),
        expect: () => [
          const TagLoading(),
          isA<TagLoaded>(),
        ],
        verify: (_) {
          verify(() => mockCreateTag(tTag1)).called(1);
        },
      );

      blocTest<TagBloc, TagState>(
        'emits TagError when createTag throws',
        build: buildBloc,
        setUp: () {
          when(() => mockCreateTag(tTag1)).thenThrow(Exception('error'));
        },
        act: (bloc) => bloc.add(CreateTagEvent(tTag1)),
        expect: () => [isA<TagError>()],
      );
    });

    group('UpdateTagEvent', () {
      blocTest<TagBloc, TagState>(
        'calls updateTag and reloads tags',
        build: buildBloc,
        setUp: () {
          when(() => mockUpdateTag(tTag1)).thenAnswer((_) async {});
          when(() => mockGetTags()).thenAnswer((_) async => [tTag1]);
        },
        act: (bloc) => bloc.add(UpdateTagEvent(tTag1)),
        expect: () => [
          const TagLoading(),
          isA<TagLoaded>(),
        ],
        verify: (_) {
          verify(() => mockUpdateTag(tTag1)).called(1);
        },
      );

      blocTest<TagBloc, TagState>(
        'emits TagError when updateTag throws',
        build: buildBloc,
        setUp: () {
          when(() => mockUpdateTag(tTag1)).thenThrow(Exception('error'));
        },
        act: (bloc) => bloc.add(UpdateTagEvent(tTag1)),
        expect: () => [isA<TagError>()],
      );
    });

    group('DeleteTagEvent', () {
      blocTest<TagBloc, TagState>(
        'calls deleteTag and reloads tags',
        build: buildBloc,
        setUp: () {
          when(() => mockDeleteTag('tag-1')).thenAnswer((_) async {});
          when(() => mockGetTags()).thenAnswer((_) async => [tTag2]);
        },
        act: (bloc) => bloc.add(const DeleteTagEvent('tag-1')),
        expect: () => [
          const TagLoading(),
          isA<TagLoaded>().having((s) => s.tags.length, 'tags length', 1),
        ],
        verify: (_) {
          verify(() => mockDeleteTag('tag-1')).called(1);
        },
      );

      blocTest<TagBloc, TagState>(
        'emits TagError when deleteTag throws',
        build: buildBloc,
        setUp: () {
          when(() => mockDeleteTag('tag-1')).thenThrow(Exception('error'));
        },
        act: (bloc) => bloc.add(const DeleteTagEvent('tag-1')),
        expect: () => [isA<TagError>()],
      );
    });
  });
}
