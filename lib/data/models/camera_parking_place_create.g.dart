// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_parking_place_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CameraParkingPlaceCreate _$CameraParkingPlaceCreateFromJson(
  Map<String, dynamic> json,
) => CameraParkingPlaceCreate(
  cameraId: (json['camera_id'] as num).toInt(),
  parkingPlaceId: (json['parking_place_id'] as num).toInt(),
  location:
      (json['location'] as List<dynamic>)
          .map(
            (e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
          )
          .toList(),
);

Map<String, dynamic> _$CameraParkingPlaceCreateToJson(
  CameraParkingPlaceCreate instance,
) => <String, dynamic>{
  'camera_id': instance.cameraId,
  'parking_place_id': instance.parkingPlaceId,
  'location': instance.location,
};
