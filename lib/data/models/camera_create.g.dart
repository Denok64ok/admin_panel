// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraCreate _$CameraCreateFromJson(Map<String, dynamic> json) => CameraCreate(
  cameraName: json['camera_name'] as String,
  url: json['url'] as String,
  parkingZoneId: (json['parking_zone_id'] as num).toInt(),
);

Map<String, dynamic> _$CameraCreateToJson(CameraCreate instance) =>
    <String, dynamic>{
      'camera_name': instance.cameraName,
      'url': instance.url,
      'parking_zone_id': instance.parkingZoneId,
    };
