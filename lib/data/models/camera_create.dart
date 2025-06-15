import 'package:json_annotation/json_annotation.dart';

part 'camera_create.g.dart';

@JsonSerializable()
class CameraCreate {
  @JsonKey(name: 'camera_name')
  final String cameraName;
  final String url;
  @JsonKey(name: 'parking_zone_id')
  final int parkingZoneId;

  CameraCreate({
    required this.cameraName,
    required this.url,
    required this.parkingZoneId,
  });

  factory CameraCreate.fromJson(Map<String, dynamic> json) =>
      _$CameraCreateFromJson(json);
  Map<String, dynamic> toJson() => _$CameraCreateToJson(this);
}
