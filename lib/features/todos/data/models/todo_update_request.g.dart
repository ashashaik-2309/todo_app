// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoUpdateRequest _$TodoUpdateRequestFromJson(Map<String, dynamic> json) =>
    TodoUpdateRequest(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      completed: json['completed'] as bool,
      userId: (json['userId'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$TodoUpdateRequestToJson(TodoUpdateRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'completed': instance.completed,
      'userId': instance.userId,
    };
