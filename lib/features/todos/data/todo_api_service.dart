import 'package:dio/dio.dart';
import 'package:todo_app/features/todos/data/models/models.dart';

class TodoApiService {
  TodoApiService(this._dio);
  final Dio _dio;

  Future<List<TodoResponse>> fetchTodos() async {
    final response = await _dio.get(
      '/todos',
      queryParameters: {'userId': 1, '_limit': 20},
    );
    return (response.data as List)
        .cast<Map<String, dynamic>>()
        .map(TodoResponse.fromJson)
        .toList();
  }

  Future<TodoResponse> createTodo(TodoCreateRequest request) async {
    final response = await _dio.post('/todos', data: request.toJson());
    return TodoResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TodoResponse> updateTodo(TodoUpdateRequest request) async {
    final response = await _dio.put('/todos/${request.id}', data: request.toJson());
    return TodoResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteTodo(int apiId) async {
    await _dio.delete('/todos/$apiId');
  }
}
