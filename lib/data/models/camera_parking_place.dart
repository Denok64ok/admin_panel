import 'package:json_annotation/json_annotation.dart';

part 'camera_parking_place.g.dart';

@JsonSerializable()
class CameraParkingPlace {
  final int id;
  @JsonKey(name: 'camera_id')
  final int cameraId;
  @JsonKey(name: 'parking_place_id')
  final int parkingPlaceId;
  final List<List> location;

  CameraParkingPlace({
    required this.id,
    required this.cameraId,
    required this.parkingPlaceId,
    required this.location,
  });

  factory CameraParkingPlace.fromJson(Map<String, dynamic> json) =>
      _$CameraParkingPlaceFromJson(json);
  Map<String, dynamic> toJson() => _$CameraParkingPlaceToJson(this);
}
