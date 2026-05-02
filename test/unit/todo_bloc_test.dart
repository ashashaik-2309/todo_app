import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/todos/data/todo_repository.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';
import 'package:todo_app/features/todos/bloc/todo_bloc.dart';
import 'package:todo_app/features/todos/bloc/todo_event.dart';
import 'package:todo_app/features/todos/bloc/todo_state.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

class FakeTodo extends Fake implements Todo {}

Future<void> _pumpLoaded(
  TodoBloc bloc,
  StreamController<List<Todo>> controller, {
  List<Todo> todos = const [],
}) async {
  bloc.add(const LoadTodos());
  await Future.microtask(() {});
  controller.add(todos);
  await Future.delayed(const Duration(milliseconds: 50));
}

void main() {
  setUpAll(() => registerFallbackValue(FakeTodo()));

  late MockTodoRepository repo;
  late StreamController<List<Todo>> controller;

  setUp(() {
    repo = MockTodoRepository();
    controller = StreamController<List<Todo>>.broadcast();
    when(() => repo.watchAll()).thenAnswer((_) => controller.stream);
    when(() => repo.create(any())).thenAnswer((_) async {});
    when(() => repo.update(any())).thenAnswer((_) async {});
    when(() => repo.delete(any())).thenAnswer((_) async {});
    when(() => repo.toggleComplete(any())).thenAnswer((_) async {});
  });

  tearDown(() => controller.close());

  test('initial state is TodoInitial', () {
    final bloc = TodoBloc(repo);
    expect(bloc.state, isA<TodoInitial>());
    bloc.close();
  });

  test('emits Loading then Loaded when LoadTodos dispatched', () async {
    final bloc = TodoBloc(repo);
    final states = <TodoState>[];
    final sub = bloc.stream.listen(states.add);

    await _pumpLoaded(bloc, controller);

    expect(states.first, isA<TodoLoading>());
    expect(states.last, isA<TodoLoaded>());
    await sub.cancel();
    await bloc.close();
  });

  test('SearchChanged updates filter query', () async {
    final bloc = TodoBloc(repo);
    await _pumpLoaded(bloc, controller);

    bloc.add(const SearchChanged('flutter'));
    await Future.delayed(const Duration(milliseconds: 50));

    expect((bloc.state as TodoLoaded).filter.searchQuery, 'flutter');
    await bloc.close();
  });

  test('PriorityFilterChanged sets priority', () async {
    final bloc = TodoBloc(repo);
    await _pumpLoaded(bloc, controller);

    bloc.add(const PriorityFilterChanged(Priority.high));
    await Future.delayed(const Duration(milliseconds: 50));

    expect((bloc.state as TodoLoaded).filter.priority, Priority.high);
    await bloc.close();
  });

  test('CategoryFilterChanged sets categoryId', () async {
    final bloc = TodoBloc(repo);
    await _pumpLoaded(bloc, controller);

    bloc.add(const CategoryFilterChanged(3));
    await Future.delayed(const Duration(milliseconds: 50));

    expect((bloc.state as TodoLoaded).filter.categoryId, 3);
    await bloc.close();
  });

  test('activeTodos and completedTodos partition correctly', () {
    final active = Todo()
      ..title = 'Active'
      ..isCompleted = false;
    final done = Todo()
      ..title = 'Done'
      ..isCompleted = true;

    final state = TodoLoaded(allTodos: [active, done]);

    expect(state.activeTodos.length, 1);
    expect(state.completedTodos.length, 1);
    expect(state.activeTodos.first.title, 'Active');
    expect(state.completedTodos.first.title, 'Done');
  });

  test('FilterState.searchQuery filters active todos', () {
    final t1 = Todo()
      ..title = 'Buy milk'
      ..isCompleted = false;
    final t2 = Todo()
      ..title = 'Call doctor'
      ..isCompleted = false;

    final state = TodoLoaded(
      allTodos: [t1, t2],
      filter: const FilterState(searchQuery: 'milk'),
    );

    expect(state.activeTodos.length, 1);
    expect(state.activeTodos.first.title, 'Buy milk');
  });

  test('FilterState.priority filters by priority', () {
    final high = Todo()
      ..title = 'High'
      ..priority = Priority.high
      ..isCompleted = false;
    final low = Todo()
      ..title = 'Low'
      ..priority = Priority.low
      ..isCompleted = false;

    final state = TodoLoaded(
      allTodos: [high, low],
      filter: const FilterState(priority: Priority.high),
    );

    expect(state.activeTodos.length, 1);
    expect(state.activeTodos.first.priority, Priority.high);
  });
}
