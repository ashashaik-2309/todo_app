import 'package:json_annotation/json_annotation.dart';

part 'todo_response.g.dart';

@JsonSerializable()
class TodoResponse {
  const TodoResponse({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'userId')
  final int userId;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'completed')
  final bool completed;

  factory TodoResponse.fromJson(Map<String, dynamic> json) =>
      _$TodoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TodoResponseToJson(this);
}
