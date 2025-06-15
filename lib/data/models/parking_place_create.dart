import 'package:json_annotation/json_annotation.dart';

part 'parking_place_create.g.dart';

@JsonSerializable()
class ParkingPlaceCreate {
  @JsonKey(name: 'place_number')
  final int placeNumber;
  @JsonKey(name: 'parking_zone_id')
  final int parkingZoneId;

  ParkingPlaceCreate({required this.placeNumber, required this.parkingZoneId});

  factory ParkingPlaceCreate.fromJson(Map<String, dynamic> json) =>
      _$ParkingPlaceCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingPlaceCreateToJson(this);
}
