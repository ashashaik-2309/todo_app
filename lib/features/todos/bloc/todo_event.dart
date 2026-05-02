import 'package:equatable/equatable.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

sealed class TodoEvent extends Equatable {
  const TodoEvent();
  @override
  List<Object?> get props => [];
}

final class LoadTodos extends TodoEvent {
  const LoadTodos();
}

final class AddTodo extends TodoEvent {
  final Todo todo;
  const AddTodo(this.todo);
  @override
  List<Object?> get props => [todo];
}

final class UpdateTodo extends TodoEvent {
  final Todo todo;
  const UpdateTodo(this.todo);
  @override
  List<Object?> get props => [todo];
}

final class DeleteTodo extends TodoEvent {
  final int id;
  const DeleteTodo(this.id);
  @override
  List<Object?> get props => [id];
}

final class ToggleComplete extends TodoEvent {
  final int id;
  const ToggleComplete(this.id);
  @override
  List<Object?> get props => [id];
}

final class SearchChanged extends TodoEvent {
  final String query;
  const SearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

final class PriorityFilterChanged extends TodoEvent {
  final Priority? priority;
  const PriorityFilterChanged(this.priority);
  @override
  List<Object?> get props => [priority];
}

final class CategoryFilterChanged extends TodoEvent {
  final int? categoryId;
  const CategoryFilterChanged(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

// Internal event — not for external use
final class TodosStreamUpdated extends TodoEvent {
  final List<Todo> todos;
  const TodosStreamUpdated(this.todos);
  @override
  List<Object?> get props => [todos];
}
