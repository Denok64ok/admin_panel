import 'package:json_annotation/json_annotation.dart';

part 'parking_place.g.dart';

@JsonSerializable()
class ParkingPlace {
  final int id;
  @JsonKey(name: 'place_number')
  final int placeNumber;
  @JsonKey(name: 'parking_zone_id')
  final int parkingZoneId;

  ParkingPlace({
    required this.id,
    required this.placeNumber,
    required this.parkingZoneId,
  });

  factory ParkingPlace.fromJson(Map<String, dynamic> json) =>
      _$ParkingPlaceFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingPlaceToJson(this);
}
