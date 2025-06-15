// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_zone_detailed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingZoneDetailed _$ParkingZoneDetailedFromJson(Map<String, dynamic> json) =>
    ParkingZoneDetailed(
      id: (json['id'] as num).toInt(),
      zoneName: json['zone_name'] as String,
      typeName: json['type_name'] as String,
      address: json['address'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      pricePerMinute: (json['price_per_minute'] as num).toInt(),
      totalPlaces: (json['total_places'] as num).toInt(),
      totalCameras: (json['total_cameras'] as num).toInt(),
      location:
          (json['location'] as List<dynamic>)
              .map((e) => e as List<dynamic>)
              .toList(),
    );

Map<String, dynamic> _$ParkingZoneDetailedToJson(
  ParkingZoneDetailed instance,
) => <String, dynamic>{
  'id': instance.id,
  'zone_name': instance.zoneName,
  'type_name': instance.typeName,
  'address': instance.address,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'price_per_minute': instance.pricePerMinute,
  'total_places': instance.totalPlaces,
  'total_cameras': instance.totalCameras,
  'location': instance.location,
};
