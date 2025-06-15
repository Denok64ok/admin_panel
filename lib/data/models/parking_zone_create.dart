import 'package:json_annotation/json_annotation.dart';

part 'parking_zone_create.g.dart';

@JsonSerializable()
class ParkingZoneCreate {
  @JsonKey(name: 'admin_id')
  final int adminId;
  @JsonKey(name: 'zone_name')
  final String zoneName;
  @JsonKey(name: 'zone_type_id')
  final int zoneTypeId;
  final String address;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  @JsonKey(name: 'price_per_minute')
  final int pricePerMinute;
  final List<List> location;

  ParkingZoneCreate({
    required this.adminId,
    required this.zoneName,
    required this.zoneTypeId,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.pricePerMinute,
    required this.location,
  });

  factory ParkingZoneCreate.fromJson(Map<String, dynamic> json) =>
      _$ParkingZoneCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingZoneCreateToJson(this);
}
