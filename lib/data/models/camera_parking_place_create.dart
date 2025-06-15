import 'package:json_annotation/json_annotation.dart';

part 'camera_parking_place_create.g.dart';

@JsonSerializable()
class CameraParkingPlaceCreate {
  @JsonKey(name: 'camera_id')
  final int cameraId;
  @JsonKey(name: 'parking_place_id')
  final int parkingPlaceId;
  final List<List<int>> location;

  CameraParkingPlaceCreate({
    required this.cameraId,
    required this.parkingPlaceId,
    required this.location,
  });

  factory CameraParkingPlaceCreate.fromJson(Map<String, dynamic> json) =>
      _$CameraParkingPlaceCreateFromJson(json);
  Map<String, dynamic> toJson() => _$CameraParkingPlaceCreateToJson(this);
}
