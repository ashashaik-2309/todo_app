import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/todos/data/todo_repository.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';
import 'package:todo_app/features/todos/presentation/bloc/todo_event.dart';
import 'package:todo_app/features/todos/presentation/bloc/todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repository;
  StreamSubscription<List<Todo>>? _subscription;

  TodoBloc(this._repository) : super(const TodoInitial()) {
    on<LoadTodos>(_onLoad);
    on<AddTodo>(_onAdd);
    on<UpdateTodo>(_onUpdate);
    on<DeleteTodo>(_onDelete);
    on<ToggleComplete>(_onToggleComplete);
    on<SearchChanged>(_onSearchChanged);
    on<PriorityFilterChanged>(_onPriorityFilterChanged);
    on<CategoryFilterChanged>(_onCategoryFilterChanged);
    on<TodosStreamUpdated>(_onStreamUpdated);
  }

  void _onLoad(LoadTodos event, Emitter<TodoState> emit) {
    emit(const TodoLoading());
    _subscription?.cancel();
    _subscription = _repository.watchAll().listen(
      (todos) => add(TodosStreamUpdated(todos)),
      onError: (e) => emit(TodoError(e.toString())),
    );
  }

  void _onStreamUpdated(TodosStreamUpdated event, Emitter<TodoState> emit) {
    final filter = state is TodoLoaded ? (state as TodoLoaded).filter : const FilterState();
    emit(TodoLoaded(allTodos: event.todos, filter: filter));
  }

  Future<void> _onAdd(AddTodo event, Emitter<TodoState> emit) async {
    try {
      await _repository.create(event.todo);
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      await _repository.update(event.todo);
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await _repository.delete(event.id);
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> _onToggleComplete(ToggleComplete event, Emitter<TodoState> emit) async {
    try {
      await _repository.toggleComplete(event.id);
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  void _onSearchChanged(SearchChanged event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final s = state as TodoLoaded;
      emit(s.copyWith(filter: s.filter.copyWith(searchQuery: event.query)));
    }
  }

  void _onPriorityFilterChanged(PriorityFilterChanged event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final s = state as TodoLoaded;
      emit(s.copyWith(filter: s.filter.copyWith(priority: event.priority)));
    }
  }

  void _onCategoryFilterChanged(CategoryFilterChanged event, Emitter<TodoState> emit) {
    if (state is TodoLoaded) {
      final s = state as TodoLoaded;
      emit(s.copyWith(filter: s.filter.copyWith(categoryId: event.categoryId)));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
