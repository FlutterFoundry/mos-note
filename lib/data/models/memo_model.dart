import 'package:json_annotation/json_annotation.dart';

part 'memo_model.g.dart';

@JsonSerializable()
class MemoModel {
  final String name;
  final String? uid;
  final String? rowStatus;
  final String? creator;
  final String? createTime;
  final String? updateTime;
  final String? displayTime;
  final String content;
  final String? visibility;
  final List<TagModel>? tags;
  final bool? pinned;
  final List<ResourceModel>? resources;
  final List<RelationModel>? relations;
  final List<ReactionModel>? reactions;
  final MemoPropertyModel? property;
  final MemoParentModel? parent;
  final List<dynamic>? nodes;
  final String? snippet;

  const MemoModel({
    required this.name,
    this.uid,
    this.rowStatus,
    this.creator,
    this.createTime,
    this.updateTime,
    this.displayTime,
    required this.content,
    this.visibility,
    this.tags,
    this.pinned,
    this.resources,
    this.relations,
    this.reactions,
    this.property,
    this.parent,
    this.nodes,
    this.snippet,
  });

  factory MemoModel.fromJson(Map<String, dynamic> json) =>
      _$MemoModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemoModelToJson(this);

  String get id => name.split('/').last;
}

@JsonSerializable()
class TagModel {
  final String name;
  const TagModel({required this.name});
  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);
  Map<String, dynamic> toJson() => _$TagModelToJson(this);
}

@JsonSerializable()
class ResourceModel {
  final String name;
  final String? uid;
  final String? createTime;
  final String? filename;
  final String? content;
  final String? externalLink;
  final String? type;
  final int? size;
  const ResourceModel({
    required this.name,
    this.uid,
    this.createTime,
    this.filename,
    this.content,
    this.externalLink,
    this.type,
    this.size,
  });
  factory ResourceModel.fromJson(Map<String, dynamic> json) =>
      _$ResourceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ResourceModelToJson(this);
}

@JsonSerializable()
class RelationModel {
  final String memo;
  final String relatedMemo;
  final String type;
  const RelationModel({
    required this.memo,
    required this.relatedMemo,
    required this.type,
  });
  factory RelationModel.fromJson(Map<String, dynamic> json) =>
      _$RelationModelFromJson(json);
  Map<String, dynamic> toJson() => _$RelationModelToJson(this);
}

@JsonSerializable()
class ReactionModel {
  final int? id;
  final String? creator;
  final String? contentId;
  final String? reactionType;
  const ReactionModel({
    this.id,
    this.creator,
    this.contentId,
    this.reactionType,
  });
  factory ReactionModel.fromJson(Map<String, dynamic> json) =>
      _$ReactionModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReactionModelToJson(this);
}

@JsonSerializable()
class MemoPropertyModel {
  final List<String>? tags;
  final bool? hasLink;
  final bool? hasTaskList;
  final bool? hasCode;
  final bool? hasIncompleteTasks;
  const MemoPropertyModel({
    this.tags,
    this.hasLink,
    this.hasTaskList,
    this.hasCode,
    this.hasIncompleteTasks,
  });
  factory MemoPropertyModel.fromJson(Map<String, dynamic> json) =>
      _$MemoPropertyModelFromJson(json);
  Map<String, dynamic> toJson() => _$MemoPropertyModelToJson(this);
}

@JsonSerializable()
class MemoParentModel {
  final String name;
  const MemoParentModel({required this.name});
  factory MemoParentModel.fromJson(Map<String, dynamic> json) =>
      _$MemoParentModelFromJson(json);
  Map<String, dynamic> toJson() => _$MemoParentModelToJson(this);
}

@JsonSerializable()
class ListMemosResponse {
  final List<MemoModel> memos;
  final String? nextPageToken;
  const ListMemosResponse({required this.memos, this.nextPageToken});
  factory ListMemosResponse.fromJson(Map<String, dynamic> json) =>
      _$ListMemosResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ListMemosResponseToJson(this);
}
