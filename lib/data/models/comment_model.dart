import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final String name;
  final String? uid;
  final String? rowStatus;
  final String? creator;
  final String? createTime;
  final String? updateTime;
  final String? displayTime;
  final String content;
  final String? visibility;
  final MemoParentForComment? parent;

  const CommentModel({
    required this.name,
    this.uid,
    this.rowStatus,
    this.creator,
    this.createTime,
    this.updateTime,
    this.displayTime,
    required this.content,
    this.visibility,
    this.parent,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);
  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  String get id => name.split('/').last;
}

@JsonSerializable()
class MemoParentForComment {
  final String name;
  const MemoParentForComment({required this.name});
  factory MemoParentForComment.fromJson(Map<String, dynamic> json) =>
      _$MemoParentForCommentFromJson(json);
  Map<String, dynamic> toJson() => _$MemoParentForCommentToJson(this);
}

@JsonSerializable()
class ListCommentsResponse {
  final List<CommentModel> memos;
  const ListCommentsResponse({required this.memos});
  factory ListCommentsResponse.fromJson(Map<String, dynamic> json) =>
      _$ListCommentsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ListCommentsResponseToJson(this);
}
