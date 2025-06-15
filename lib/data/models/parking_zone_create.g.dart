// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parking_zone_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParkingZoneCreate _$ParkingZoneCreateFromJson(Map<String, dynamic> json) =>
    ParkingZoneCreate(
      adminId: (json['admin_id'] as num).toInt(),
      zoneName: json['zone_name'] as String,
      zoneTypeId: (json['zone_type_id'] as num).toInt(),
      address: json['address'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      pricePerMinute: (json['price_per_minute'] as num).toInt(),
      location:
          (json['location'] as List<dynamic>)
              .map((e) => e as List<dynamic>)
              .toList(),
    );

Map<String, dynamic> _$ParkingZoneCreateToJson(ParkingZoneCreate instance) =>
    <String, dynamic>{
      'admin_id': instance.adminId,
      'zone_name': instance.zoneName,
      'zone_type_id': instance.zoneTypeId,
      'address': instance.address,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'price_per_minute': instance.pricePerMinute,
      'location': instance.location,
    };
