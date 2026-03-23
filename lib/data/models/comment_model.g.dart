// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
      name: json['name'] as String,
      uid: json['uid'] as String?,
      rowStatus: json['rowStatus'] as String?,
      creator: json['creator'] as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      displayTime: json['displayTime'] as String?,
      content: json['content'] as String,
      visibility: json['visibility'] as String?,
      parent: json['parent'] == null
          ? null
          : MemoParentForComment.fromJson(
              json['parent'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'uid': instance.uid,
      'rowStatus': instance.rowStatus,
      'creator': instance.creator,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'displayTime': instance.displayTime,
      'content': instance.content,
      'visibility': instance.visibility,
      'parent': instance.parent,
    };

MemoParentForComment _$MemoParentForCommentFromJson(
        Map<String, dynamic> json) =>
    MemoParentForComment(
      name: json['name'] as String,
    );

Map<String, dynamic> _$MemoParentForCommentToJson(
        MemoParentForComment instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

ListCommentsResponse _$ListCommentsResponseFromJson(
        Map<String, dynamic> json) =>
    ListCommentsResponse(
      memos: (json['memos'] as List<dynamic>)
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListCommentsResponseToJson(
        ListCommentsResponse instance) =>
    <String, dynamic>{
      'memos': instance.memos,
    };
