// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      name: json['name'] as String,
      id: json['id'] as String?,
      rowStatus: json['rowStatus'] as String?,
      createTime: json['createTime'] as String?,
      updateTime: json['updateTime'] as String?,
      role: json['role'] as String?,
      username: json['username'] as String,
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'rowStatus': instance.rowStatus,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'role': instance.role,
      'username': instance.username,
      'email': instance.email,
      'nickname': instance.nickname,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'description': instance.description,
    };

SignInRequest _$SignInRequestFromJson(Map<String, dynamic> json) =>
    SignInRequest(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$SignInRequestToJson(SignInRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };

SignInResponse _$SignInResponseFromJson(Map<String, dynamic> json) =>
    SignInResponse(
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String?,
      accessTokenExpiresAt: json['accessTokenExpiresAt'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$SignInResponseToJson(SignInResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'accessToken': instance.accessToken,
      'accessTokenExpiresAt': instance.accessTokenExpiresAt,
      'error': instance.error,
    };
