import 'package:tasker/core/error/failures.dart';
import 'package:tasker/domain/entities/tag.dart';
import 'package:tasker/domain/repositories/tag_repository.dart';

class CreateTag {
  CreateTag(this._tagRepository);

  final TagRepository _tagRepository;

  Future<void> call(Tag tag) async {
    if (tag.name.trim().isEmpty) {
      throw const ValidationFailure('Tag name cannot be empty');
    }

    await _tagRepository.createTag(tag);
  }
}
