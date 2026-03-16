import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasker/domain/usecases/tag/create_tag.dart';
import 'package:tasker/domain/usecases/tag/delete_tag.dart';
import 'package:tasker/domain/usecases/tag/get_tags.dart';
import 'package:tasker/domain/usecases/tag/update_tag.dart';
import 'package:tasker/presentation/blocs/tag/tag_event.dart';
import 'package:tasker/presentation/blocs/tag/tag_state.dart';

class TagBloc extends Bloc<TagEvent, TagState> {
  TagBloc({
    required GetTags getTags,
    required CreateTag createTag,
    required UpdateTag updateTag,
    required DeleteTag deleteTag,
  }) : _getTags = getTags,
       _createTag = createTag,
       _updateTag = updateTag,
       _deleteTag = deleteTag,
       super(const TagInitial()) {
    on<LoadTags>(_onLoadTags);
    on<CreateTagEvent>(_onCreateTag);
    on<UpdateTagEvent>(_onUpdateTag);
    on<DeleteTagEvent>(_onDeleteTag);
  }

  final GetTags _getTags;
  final CreateTag _createTag;
  final UpdateTag _updateTag;
  final DeleteTag _deleteTag;

  Future<void> _onLoadTags(LoadTags event, Emitter<TagState> emit) async {
    emit(const TagLoading());
    try {
      final tags = await _getTags();
      emit(TagLoaded(tags));
    } catch (e) {
      emit(TagError(e.toString()));
    }
  }

  Future<void> _onCreateTag(
    CreateTagEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      await _createTag(event.tag);
      add(const LoadTags());
    } catch (e) {
      emit(TagError(e.toString()));
    }
  }

  Future<void> _onUpdateTag(
    UpdateTagEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      await _updateTag(event.tag);
      add(const LoadTags());
    } catch (e) {
      emit(TagError(e.toString()));
    }
  }

  Future<void> _onDeleteTag(
    DeleteTagEvent event,
    Emitter<TagState> emit,
  ) async {
    try {
      await _deleteTag(event.id);
      add(const LoadTags());
    } catch (e) {
      emit(TagError(e.toString()));
    }
  }
}
