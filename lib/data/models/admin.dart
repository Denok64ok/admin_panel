import 'package:json_annotation/json_annotation.dart';

part 'admin.g.dart';

@JsonSerializable()
class Admin {
  final int id;
  @JsonKey(name: 'admin_name')
  final String adminName;
  final String email;

  Admin({required this.id, required this.adminName, required this.email});

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);
  Map<String, dynamic> toJson() => _$AdminToJson(this);
}
