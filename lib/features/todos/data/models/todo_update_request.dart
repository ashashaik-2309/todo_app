import 'package:json_annotation/json_annotation.dart';

part 'todo_update_request.g.dart';

@JsonSerializable()
class TodoUpdateRequest {
  const TodoUpdateRequest({
    required this.id,
    required this.title,
    required this.completed,
    this.userId = 1,
  });

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'completed')
  final bool completed;

  @JsonKey(name: 'userId')
  final int userId;

  factory TodoUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$TodoUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TodoUpdateRequestToJson(this);
}
