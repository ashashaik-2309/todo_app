import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/todos/cubit/todo_cubit.dart';
import 'package:todo_app/features/todos/data/todo_repository.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

class FakeTodo extends Fake implements Todo {}

Future<void> _pumpLoaded(
  TodoCubit cubit,
  StreamController<List<Todo>> controller, {
  List<Todo> todos = const [],
}) async {
  cubit.load();
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
    when(() => repo.syncFromApi()).thenAnswer((_) async {});
  });

  tearDown(() => controller.close());

  test('initial state is TodoInitial', () {
    final cubit = TodoCubit(repo);
    expect(cubit.state, isA<TodoInitial>());
    cubit.close();
  });

  test('emits Loading then Loaded when load() called', () async {
    final cubit = TodoCubit(repo);
    final states = <TodoState>[];
    final sub = cubit.stream.listen(states.add);

    await _pumpLoaded(cubit, controller);

    expect(states.first, isA<TodoLoading>());
    expect(states.last, isA<TodoLoaded>());
    await sub.cancel();
    await cubit.close();
  });

  test('searchChanged updates filter query', () async {
    final cubit = TodoCubit(repo);
    await _pumpLoaded(cubit, controller);

    cubit.searchChanged('flutter');
    await Future.delayed(const Duration(milliseconds: 50));

    expect((cubit.state as TodoLoaded).filter.searchQuery, 'flutter');
    await cubit.close();
  });

  test('priorityFilterChanged sets priority', () async {
    final cubit = TodoCubit(repo);
    await _pumpLoaded(cubit, controller);

    cubit.priorityFilterChanged(Priority.high);
    await Future.delayed(const Duration(milliseconds: 50));

    expect((cubit.state as TodoLoaded).filter.priority, Priority.high);
    await cubit.close();
  });

  test('categoryFilterChanged sets categoryId', () async {
    final cubit = TodoCubit(repo);
    await _pumpLoaded(cubit, controller);

    cubit.categoryFilterChanged(3);
    await Future.delayed(const Duration(milliseconds: 50));

    expect((cubit.state as TodoLoaded).filter.categoryId, 3);
    await cubit.close();
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
