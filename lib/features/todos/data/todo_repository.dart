import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/features/todos/data/models/models.dart';
import 'package:todo_app/features/todos/data/todo_api_service.dart';
import 'package:todo_app/features/todos/domain/todo_model.dart';

class TodoRepository {
  TodoRepository({TodoApiService? apiService}) : _apiService = apiService;
  final TodoApiService? _apiService;

  Box<Todo> get _box => Hive.box<Todo>('todos');
  Box<int> get _apiIds => Hive.box<int>('todo_api_ids');

  Stream<List<Todo>> watchAll() async* {
    yield _box.values.toList();
    await for (final _ in _box.watch()) {
      yield _box.values.toList();
    }
  }

  Future<List<Todo>> getAll() async => _box.values.toList();
  Future<Todo?> getById(int id) async => _box.get(id);

  Future<void> create(Todo todo) async {
    await _box.add(todo);
    _apiService
        ?.createTodo(TodoCreateRequest(title: todo.title))
        .then((r) => _apiIds.put(todo.key, r.id))
        .ignore();
  }

  Future<void> update(Todo todo) async {
    todo.updatedAt = DateTime.now();
    await todo.save();
    final apiId = _apiIds.get(todo.key);
    if (apiId != null) {
      _apiService
          ?.updateTodo(TodoUpdateRequest(
            id: apiId,
            title: todo.title,
            completed: todo.isCompleted,
          ))
          .ignore();
    }
  }

  Future<void> delete(int id) async {
    final apiId = _apiIds.get(id);
    await _box.delete(id);
    await _apiIds.delete(id);
    if (apiId != null) {
      _apiService?.deleteTodo(apiId).ignore();
    }
  }

  Future<void> toggleComplete(int id) async {
    final todo = _box.get(id);
    if (todo == null) return;
    todo.isCompleted = !todo.isCompleted;
    todo.updatedAt = DateTime.now();
    await todo.save();
    final apiId = _apiIds.get(id);
    if (apiId != null) {
      _apiService
          ?.updateTodo(TodoUpdateRequest(
            id: apiId,
            title: todo.title,
            completed: todo.isCompleted,
          ))
          .ignore();
    }
  }

  /// Fetches todos from the remote API and upserts them into local storage.
  /// - On initial sync (empty box): adds all remote todos.
  /// - On subsequent syncs: updates titles of already-mapped todos so the
  ///   Hive stream fires and the UI reflects the latest server state.
  Future<void> syncFromApi() async {
    final service = _apiService;
    if (service == null) return;
    final remoteTodos = await service.fetchTodos();
    // Reverse map: apiId → Hive box key
    final apiIdToKey = <int, dynamic>{
      for (final e in _apiIds.toMap().entries) e.value: e.key,
    };
    final isInitialSync = _box.isEmpty;
    for (final r in remoteTodos) {
      final key = apiIdToKey[r.id];
      if (key != null) {
        // Update title from server → triggers watchAll stream
        final todo = _box.get(key);
        if (todo != null) {
          final serverTitle = _capitalize(r.title);
          if (todo.title != serverTitle) {
            todo.title = serverTitle;
            await todo.save();
          }
        }
      } else if (isInitialSync) {
        final todo = Todo()
          ..title = _capitalize(r.title)
          ..isCompleted = r.completed
          ..priorityIndex = r.id % 3;
        await _box.add(todo);
        await _apiIds.put(todo.key, r.id);
      }
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
