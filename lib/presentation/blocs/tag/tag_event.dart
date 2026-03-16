import 'package:equatable/equatable.dart';
import 'package:tasker/domain/entities/tag.dart';

abstract class TagEvent extends Equatable {
  const TagEvent();

  @override
  List<Object?> get props => [];
}

class LoadTags extends TagEvent {
  const LoadTags();
}

class CreateTagEvent extends TagEvent {
  const CreateTagEvent(this.tag);

  final Tag tag;

  @override
  List<Object?> get props => [tag];
}

class UpdateTagEvent extends TagEvent {
  const UpdateTagEvent(this.tag);

  final Tag tag;

  @override
  List<Object?> get props => [tag];
}

class DeleteTagEvent extends TagEvent {
  const DeleteTagEvent(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
