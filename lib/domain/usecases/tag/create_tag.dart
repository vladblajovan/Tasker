import 'package:test_app/core/error/failures.dart';
import 'package:test_app/domain/entities/tag.dart';
import 'package:test_app/domain/repositories/tag_repository.dart';

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
