import 'package:json_annotation/json_annotation.dart';

part 'camera.g.dart';

@JsonSerializable()
class Camera {
  final int id;
  @JsonKey(name: 'camera_name')
  final String cameraName;
  final String url;
  @JsonKey(name: 'parking_zone_id')
  final int parkingZoneId;

  Camera({
    required this.id,
    required this.cameraName,
    required this.url,
    required this.parkingZoneId,
  });

  factory Camera.fromJson(Map<String, dynamic> json) => _$CameraFromJson(json);
  Map<String, dynamic> toJson() => _$CameraToJson(this);
}
