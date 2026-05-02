import 'package:equatable/equatable.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

class FilterState extends Equatable {
  final String searchQuery;
  final Priority? priority;
  final int? categoryId;

  const FilterState({
    this.searchQuery = '',
    this.priority,
    this.categoryId,
  });

  FilterState copyWith({
    String? searchQuery,
    Object? priority = _sentinel,
    Object? categoryId = _sentinel,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      priority: priority == _sentinel ? this.priority : priority as Priority?,
      categoryId: categoryId == _sentinel ? this.categoryId : categoryId as int?,
    );
  }

  @override
  List<Object?> get props => [searchQuery, priority, categoryId];
}

const _sentinel = Object();

sealed class TodoState extends Equatable {
  const TodoState();
  @override
  List<Object?> get props => [];
}

final class TodoInitial extends TodoState {
  const TodoInitial();
}

final class TodoLoading extends TodoState {
  const TodoLoading();
}

final class TodoLoaded extends TodoState {
  final List<Todo> allTodos;
  final FilterState filter;
  final bool isSyncing;

  const TodoLoaded({
    required this.allTodos,
    this.filter = const FilterState(),
    this.isSyncing = false,
  });

  List<Todo> get activeTodos => _applyFilter(false);
  List<Todo> get completedTodos => _applyFilter(true);

  List<Todo> _applyFilter(bool completed) {
    return allTodos.where((t) {
      if (t.isCompleted != completed) return false;
      if (filter.searchQuery.isNotEmpty &&
          !t.title.toLowerCase().contains(filter.searchQuery.toLowerCase())) {
        return false;
      }
      if (filter.priority != null && t.priority != filter.priority) return false;
      if (filter.categoryId != null && t.categoryId != filter.categoryId) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        final priorityOrder = {Priority.high: 0, Priority.medium: 1, Priority.low: 2};
        final cmp = priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
        if (cmp != 0) return cmp;
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }
        if (a.dueDate != null) return -1;
        if (b.dueDate != null) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  TodoLoaded copyWith({List<Todo>? allTodos, FilterState? filter, bool? isSyncing}) {
    return TodoLoaded(
      allTodos: allTodos ?? this.allTodos,
      filter: filter ?? this.filter,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [allTodos, filter, isSyncing];
}

final class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);
  @override
  List<Object?> get props => [message];
}
