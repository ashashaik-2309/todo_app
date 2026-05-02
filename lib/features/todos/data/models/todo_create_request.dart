import 'package:json_annotation/json_annotation.dart';

part 'todo_create_request.g.dart';

@JsonSerializable()
class TodoCreateRequest {
  const TodoCreateRequest({
    required this.title,
    this.completed = false,
    this.userId = 1,
  });

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'completed')
  final bool completed;

  @JsonKey(name: 'userId')
  final int userId;

  factory TodoCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$TodoCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TodoCreateRequestToJson(this);
}
