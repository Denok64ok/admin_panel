import 'package:json_annotation/json_annotation.dart';

part 'camera_snapshot.g.dart';

@JsonSerializable()
class CameraSnapshot {
  @JsonKey(name: 'camera_id')
  final int cameraId;
  @JsonKey(name: 'image_base64')
  final String imageBase64;
  @JsonKey(name: 'content_type')
  final String contentType;

  CameraSnapshot({
    required this.cameraId,
    required this.imageBase64,
    required this.contentType,
  });

  factory CameraSnapshot.fromJson(Map<String, dynamic> json) =>
      _$CameraSnapshotFromJson(json);
  Map<String, dynamic> toJson() => _$CameraSnapshotToJson(this);
}
