// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoCreateRequest _$TodoCreateRequestFromJson(Map<String, dynamic> json) =>
    TodoCreateRequest(
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
      userId: (json['userId'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$TodoCreateRequestToJson(TodoCreateRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'completed': instance.completed,
      'userId': instance.userId,
    };
