import 'package:equatable/equatable.dart';
import 'package:test_app/domain/entities/tag.dart';

abstract class TagState extends Equatable {
  const TagState();

  @override
  List<Object?> get props => [];
}

class TagInitial extends TagState {
  const TagInitial();
}

class TagLoading extends TagState {
  const TagLoading();
}

class TagLoaded extends TagState {
  const TagLoaded(this.tags);

  final List<Tag> tags;

  @override
  List<Object?> get props => [tags];
}

class TagError extends TagState {
  const TagError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
