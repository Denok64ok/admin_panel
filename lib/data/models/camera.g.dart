// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Camera _$CameraFromJson(Map<String, dynamic> json) => Camera(
  id: (json['id'] as num).toInt(),
  cameraName: json['camera_name'] as String,
  url: json['url'] as String,
  parkingZoneId: (json['parking_zone_id'] as num).toInt(),
);

Map<String, dynamic> _$CameraToJson(Camera instance) => <String, dynamic>{
  'id': instance.id,
  'camera_name': instance.cameraName,
  'url': instance.url,
  'parking_zone_id': instance.parkingZoneId,
};
