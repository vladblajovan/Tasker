import 'package:equatable/equatable.dart';
import 'package:test_app/domain/entities/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

class CreateCategoryEvent extends CategoryEvent {
  const CreateCategoryEvent(this.category);

  final Category category;

  @override
  List<Object?> get props => [category];
}

class UpdateCategoryEvent extends CategoryEvent {
  const UpdateCategoryEvent(this.category);

  final Category category;

  @override
  List<Object?> get props => [category];
}

class DeleteCategoryEvent extends CategoryEvent {
  const DeleteCategoryEvent(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class ReorderCategories extends CategoryEvent {
  const ReorderCategories(this.orderedIds);

  final List<String> orderedIds;

  @override
  List<Object?> get props => [orderedIds];
}
