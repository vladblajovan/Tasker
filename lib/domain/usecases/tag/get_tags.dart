import 'package:tasker/domain/entities/tag.dart';
import 'package:tasker/domain/repositories/tag_repository.dart';

class GetTags {
  GetTags(this._tagRepository);

  final TagRepository _tagRepository;

  Future<List<Tag>> call() async {
    return _tagRepository.getAllTags();
  }
}
