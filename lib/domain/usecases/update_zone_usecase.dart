import '../../data/models/parking_zone.dart';
import '../../data/models/parking_zone_create.dart';
import '../../data/repositories/auth_repository.dart';

class UpdateZoneUseCase {
  final AuthRepository repository;

  UpdateZoneUseCase(this.repository);

  Future<ParkingZone> execute(
    int zoneId,
    ParkingZoneCreate data,
    String token,
  ) async {
    return await repository.updateZone(zoneId, data, token);
  }
}
