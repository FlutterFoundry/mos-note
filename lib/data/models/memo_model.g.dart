// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemoModel _$MemoModelFromJson(Map<String, dynamic> json) => MemoModel(
      name: json['name'] as String,
      uid: json['uid'] as String?,
      rowStatus: json['rowStatus'] as String?,
      creator: json['creator'] as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      displayTime: json['displayTime'] as String?,
      content: json['content'] as String,
      visibility: json['visibility'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pinned: json['pinned'] as bool?,
      resources: (json['resources'] as List<dynamic>?)
          ?.map((e) => ResourceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      relations: (json['relations'] as List<dynamic>?)
          ?.map((e) => RelationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => ReactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      property: json['property'] == null
          ? null
          : MemoPropertyModel.fromJson(
              json['property'] as Map<String, dynamic>),
      parent: json['parent'] == null
          ? null
          : MemoParentModel.fromJson(json['parent'] as Map<String, dynamic>),
      nodes: json['nodes'] as List<dynamic>?,
      snippet: json['snippet'] as String?,
    );

Map<String, dynamic> _$MemoModelToJson(MemoModel instance) => <String, dynamic>{
      'name': instance.name,
      'uid': instance.uid,
      'rowStatus': instance.rowStatus,
      'creator': instance.creator,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'displayTime': instance.displayTime,
      'content': instance.content,
      'visibility': instance.visibility,
      'tags': instance.tags,
      'pinned': instance.pinned,
      'resources': instance.resources,
      'relations': instance.relations,
      'reactions': instance.reactions,
      'property': instance.property,
      'parent': instance.parent,
      'nodes': instance.nodes,
      'snippet': instance.snippet,
    };

TagModel _$TagModelFromJson(Map<String, dynamic> json) => TagModel(
      name: json['name'] as String,
    );

Map<String, dynamic> _$TagModelToJson(TagModel instance) => <String, dynamic>{
      'name': instance.name,
    };

ResourceModel _$ResourceModelFromJson(Map<String, dynamic> json) =>
    ResourceModel(
      name: json['name'] as String,
      uid: json['uid'] as String?,
      createTime: json['createTime'] as String?,
      filename: json['filename'] as String?,
      content: json['content'] as String?,
      externalLink: json['externalLink'] as String?,
      type: json['type'] as String?,
      size: (json['size'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResourceModelToJson(ResourceModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'uid': instance.uid,
      'createTime': instance.createTime,
      'filename': instance.filename,
      'content': instance.content,
      'externalLink': instance.externalLink,
      'type': instance.type,
      'size': instance.size,
    };

RelationModel _$RelationModelFromJson(Map<String, dynamic> json) =>
    RelationModel(
      memo: json['memo'] as String,
      relatedMemo: json['relatedMemo'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$RelationModelToJson(RelationModel instance) =>
    <String, dynamic>{
      'memo': instance.memo,
      'relatedMemo': instance.relatedMemo,
      'type': instance.type,
    };

ReactionModel _$ReactionModelFromJson(Map<String, dynamic> json) =>
    ReactionModel(
      id: (json['id'] as num?)?.toInt(),
      creator: json['creator'] as String?,
      contentId: json['contentId'] as String?,
      reactionType: json['reactionType'] as String?,
    );

Map<String, dynamic> _$ReactionModelToJson(ReactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator': instance.creator,
      'contentId': instance.contentId,
      'reactionType': instance.reactionType,
    };

MemoPropertyModel _$MemoPropertyModelFromJson(Map<String, dynamic> json) =>
    MemoPropertyModel(
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      hasLink: json['hasLink'] as bool?,
      hasTaskList: json['hasTaskList'] as bool?,
      hasCode: json['hasCode'] as bool?,
      hasIncompleteTasks: json['hasIncompleteTasks'] as bool?,
    );

Map<String, dynamic> _$MemoPropertyModelToJson(MemoPropertyModel instance) =>
    <String, dynamic>{
      'tags': instance.tags,
      'hasLink': instance.hasLink,
      'hasTaskList': instance.hasTaskList,
      'hasCode': instance.hasCode,
      'hasIncompleteTasks': instance.hasIncompleteTasks,
    };

MemoParentModel _$MemoParentModelFromJson(Map<String, dynamic> json) =>
    MemoParentModel(
      name: json['name'] as String,
    );

Map<String, dynamic> _$MemoParentModelToJson(MemoParentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

ListMemosResponse _$ListMemosResponseFromJson(Map<String, dynamic> json) =>
    ListMemosResponse(
      memos: (json['memos'] as List<dynamic>)
          .map((e) => MemoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageToken: json['nextPageToken'] as String?,
    );

Map<String, dynamic> _$ListMemosResponseToJson(ListMemosResponse instance) =>
    <String, dynamic>{
      'memos': instance.memos,
      'nextPageToken': instance.nextPageToken,
    };
