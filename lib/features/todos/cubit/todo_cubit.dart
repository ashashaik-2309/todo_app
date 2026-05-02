import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/todos/cubit/todo_state.dart';
import 'package:todo_app/features/todos/data/todo_repository.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

export 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  TodoCubit(this._repository) : super(const TodoInitial());
  final TodoRepository _repository;
  StreamSubscription<List<Todo>>? _subscription;

  void load() {
    emit(const TodoLoading());
    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      _onStreamUpdate,
      onError: (e) => emit(TodoError(e.toString())),
    );
    syncFromApi();
  }

  void _onStreamUpdate(List<Todo> todos) {
    final filter = state is TodoLoaded ? (state as TodoLoaded).filter : const FilterState();
    final isSyncing = state is TodoLoaded ? (state as TodoLoaded).isSyncing : false;
    emit(TodoLoaded(allTodos: todos, filter: filter, isSyncing: isSyncing));
  }

  Future<void> addTodo(Todo todo) async {
    try {
      await _repository.create(todo);
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      await _repository.update(todo);
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _repository.delete(id);
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> toggleComplete(int id) async {
    try {
      await _repository.toggleComplete(id);
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  void searchChanged(String query) {
    if (state is TodoLoaded) {
      final s = state as TodoLoaded;
      emit(s.copyWith(filter: s.filter.copyWith(searchQuery: query)));
    }
  }

  void priorityFilterChanged(Priority? priority) {
    if (state is TodoLoaded) {
      final s = state as TodoLoaded;
      emit(s.copyWith(filter: s.filter.copyWith(priority: priority)));
    }
  }

  void categoryFilterChanged(int? categoryId) {
    if (state is TodoLoaded) {
      final s = state as TodoLoaded;
      emit(s.copyWith(filter: s.filter.copyWith(categoryId: categoryId)));
    }
  }

  Future<void> syncFromApi() async {
    if (state is TodoLoaded) {
      emit((state as TodoLoaded).copyWith(isSyncing: true));
    }
    try {
      await _repository.syncFromApi();
    } catch (_) {
      // silent
    } finally {
      if (state is TodoLoaded) {
        emit((state as TodoLoaded).copyWith(isSyncing: false));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
