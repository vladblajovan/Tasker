import 'package:test_app/domain/entities/tag.dart';
import 'package:test_app/domain/repositories/tag_repository.dart';

class GetTags {
  GetTags(this._tagRepository);

  final TagRepository _tagRepository;

  Future<List<Tag>> call() async {
    return _tagRepository.getAllTags();
  }
}
