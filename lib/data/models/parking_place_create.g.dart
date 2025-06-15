// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_place_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingPlaceCreate _$ParkingPlaceCreateFromJson(Map<String, dynamic> json) =>
    ParkingPlaceCreate(
      placeNumber: (json['place_number'] as num).toInt(),
      parkingZoneId: (json['parking_zone_id'] as num).toInt(),
    );

Map<String, dynamic> _$ParkingPlaceCreateToJson(ParkingPlaceCreate instance) =>
    <String, dynamic>{
      'place_number': instance.placeNumber,
      'parking_zone_id': instance.parkingZoneId,
    };
