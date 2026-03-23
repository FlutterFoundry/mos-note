import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String name;
  final String? id;
  final String? rowStatus;
  final String? createTime;
  final String? updateTime;
  final String? role;
  final String username;
  final String? email;
  final String? nickname;
  final String? avatarUrl;
  final String? description;

  const UserModel({
    required this.name,
    this.id,
    this.rowStatus,
    this.createTime,
    this.updateTime,
    this.role,
    required this.username,
    this.email,
    this.nickname,
    this.avatarUrl,
    this.description,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get displayName => nickname?.isNotEmpty == true ? nickname! : username;
  String get userId => name.split('/').last;
}

@JsonSerializable()
class SignInRequest {
  final String username;
  final String password;
  const SignInRequest({required this.username, required this.password});
  factory SignInRequest.fromJson(Map<String, dynamic> json) =>
      _$SignInRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SignInRequestToJson(this);
}

@JsonSerializable()
class SignInResponse {
  final UserModel? user;
  final String? error;
  const SignInResponse({this.user, this.error});
  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SignInResponseToJson(this);
}
