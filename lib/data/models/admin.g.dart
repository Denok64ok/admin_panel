// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Admin _$AdminFromJson(Map<String, dynamic> json) => Admin(
  id: (json['id'] as num).toInt(),
  adminName: json['admin_name'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$AdminToJson(Admin instance) => <String, dynamic>{
  'id': instance.id,
  'admin_name': instance.adminName,
  'email': instance.email,
};
