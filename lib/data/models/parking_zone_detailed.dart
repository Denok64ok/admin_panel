import 'package:json_annotation/json_annotation.dart';

part 'parking_zone_detailed.g.dart';

@JsonSerializable()
class ParkingZoneDetailed {
  final int id;
  @JsonKey(name: 'zone_name')
  final String zoneName;
  @JsonKey(name: 'type_name')
  final String typeName;
  final String address;
  @JsonKey(name: 'start_time')
  final String startTime;
  @JsonKey(name: 'end_time')
  final String endTime;
  @JsonKey(name: 'price_per_minute')
  final int pricePerMinute;
  @JsonKey(name: 'total_places')
  final int totalPlaces;
  @JsonKey(name: 'total_cameras')
  final int totalCameras;
  final List<List> location;

  ParkingZoneDetailed({
    required this.id,
    required this.zoneName,
    required this.typeName,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.pricePerMinute,
    required this.totalPlaces,
    required this.totalCameras,
    required this.location,
  });

  factory ParkingZoneDetailed.fromJson(Map<String, dynamic> json) =>
      _$ParkingZoneDetailedFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingZoneDetailedToJson(this);
}
