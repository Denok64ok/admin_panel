// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraSnapshot _$CameraSnapshotFromJson(Map<String, dynamic> json) =>
    CameraSnapshot(
      cameraId: (json['camera_id'] as num).toInt(),
      imageBase64: json['image_base64'] as String,
      contentType: json['content_type'] as String,
    );

Map<String, dynamic> _$CameraSnapshotToJson(CameraSnapshot instance) =>
    <String, dynamic>{
      'camera_id': instance.cameraId,
      'image_base64': instance.imageBase64,
      'content_type': instance.contentType,
    };
