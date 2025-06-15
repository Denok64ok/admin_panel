import 'package:json_annotation/json_annotation.dart';
import 'camera_snapshot.dart';

part 'zone_snapshots_response.g.dart';

@JsonSerializable()
class ZoneSnapshotsResponse {
  @JsonKey(name: 'zone_id')
  final int zoneId;
  final List<CameraSnapshot> snapshots;

  ZoneSnapshotsResponse({required this.zoneId, required this.snapshots});

  factory ZoneSnapshotsResponse.fromJson(Map<String, dynamic> json) =>
      _$ZoneSnapshotsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ZoneSnapshotsResponseToJson(this);
}
