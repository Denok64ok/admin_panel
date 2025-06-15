import '../../data/models/zone_snapshots_response.dart';
import '../../data/repositories/auth_repository.dart';

class GetZoneSnapshotsUseCase {
  final AuthRepository repository;

  GetZoneSnapshotsUseCase(this.repository);

  Future<ZoneSnapshotsResponse> execute(int zoneId, String token) async {
    return await repository.getZoneSnapshots(zoneId, token);
  }
}
