// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_snapshots_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZoneSnapshotsResponse _$ZoneSnapshotsResponseFromJson(
  Map<String, dynamic> json,
) => ZoneSnapshotsResponse(
  zoneId: (json['zone_id'] as num).toInt(),
  snapshots:
      (json['snapshots'] as List<dynamic>)
          .map((e) => CameraSnapshot.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ZoneSnapshotsResponseToJson(
  ZoneSnapshotsResponse instance,
) => <String, dynamic>{
  'zone_id': instance.zoneId,
  'snapshots': instance.snapshots,
};
