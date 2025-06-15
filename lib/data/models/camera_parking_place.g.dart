// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_parking_place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraParkingPlace _$CameraParkingPlaceFromJson(Map<String, dynamic> json) =>
    CameraParkingPlace(
      id: (json['id'] as num).toInt(),
      cameraId: (json['camera_id'] as num).toInt(),
      parkingPlaceId: (json['parking_place_id'] as num).toInt(),
      location:
          (json['location'] as List<dynamic>)
              .map((e) => e as List<dynamic>)
              .toList(),
    );

Map<String, dynamic> _$CameraParkingPlaceToJson(CameraParkingPlace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'camera_id': instance.cameraId,
      'parking_place_id': instance.parkingPlaceId,
      'location': instance.location,
    };
